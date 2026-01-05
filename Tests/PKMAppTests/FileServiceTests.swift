import XCTest
@testable import PKMApp
import Foundation

final class FileServiceTests: XCTestCase {

    var tempVaultURL: URL!
    var fileService: FileService!

    override func setUp() async throws {
        try await super.setUp()

        // Create temporary vault directory
        let tempDir = FileManager.default.temporaryDirectory
        tempVaultURL = tempDir.appendingPathComponent("test-vault-\(UUID().uuidString)")

        // Create vault structure
        try FileManager.default.createDirectory(
            at: tempVaultURL.appendingPathComponent("Daily Notes"),
            withIntermediateDirectories: true,
            attributes: nil
        )

        // Initialize file service
        fileService = try FileService(vaultPath: tempVaultURL)
    }

    override func tearDown() async throws {
        // Clean up temp vault
        try? FileManager.default.removeItem(at: tempVaultURL)
        try await super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitWithValidVault() throws {
        let service = try FileService(vaultPath: tempVaultURL)
        XCTAssertNotNil(service)
    }

    func testInitWithInvalidVault() {
        let invalidPath = FileManager.default.temporaryDirectory
            .appendingPathComponent("nonexistent-\(UUID().uuidString)")

        XCTAssertThrowsError(try FileService(vaultPath: invalidPath)) { error in
            guard case FileService.FileServiceError.vaultNotFound = error else {
                XCTFail("Expected vaultNotFound error")
                return
            }
        }
    }

    // MARK: - Daily Note Creation Tests

    func testCreateDailyNote() async throws {
        let date = Date()
        let note = try await fileService.createDailyNote(for: date)

        // Verify note was created
        XCTAssertEqual(note.date, date)
        XCTAssertTrue(note.body.contains("# "))
        XCTAssertTrue(note.body.contains("## Morning Intentions"))
        XCTAssertTrue(note.body.contains("## Focus Blocks"))
        XCTAssertTrue(note.body.contains("## Capture"))

        // Verify frontmatter
        XCTAssertEqual(note.frontmatter["type"] as? String, "daily")
        XCTAssertNotNil(note.frontmatter["date"])

        // Verify file exists on disk
        let exists = await fileService.dailyNoteExists(for: date)
        XCTAssertTrue(exists)
    }

    func testCreateDailyNoteIdempotent() async throws {
        let date = Date()

        // Create note first time
        let note1 = try await fileService.createDailyNote(for: date)

        // Create again - should return existing note
        let note2 = try await fileService.createDailyNote(for: date)

        XCTAssertEqual(note1.filePath, note2.filePath)
    }

    // MARK: - Read/Write Tests

    func testWriteAndReadDailyNote() async throws {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)

        let frontmatter: [String: Any] = [
            "date": dateString,
            "type": "daily",
            "mood": "productive"
        ]

        let body = """
        # \(dateString)

        ## Morning Intentions
        - [ ] Test file I/O

        ## Capture
        Some notes here.
        """

        let dailyNotesPath = tempVaultURL
            .appendingPathComponent("Daily Notes")
            .appendingPathComponent("\(dateString).md")

        let note = DailyNote(
            date: date,
            filePath: dailyNotesPath,
            frontmatter: frontmatter,
            body: body
        )

        // Write note
        try await fileService.writeDailyNote(note)

        // Read it back
        let readNote = try await fileService.readDailyNote(for: date)

        XCTAssertEqual(readNote.date, date)
        XCTAssertEqual(readNote.frontmatter["type"] as? String, "daily")
        XCTAssertEqual(readNote.frontmatter["mood"] as? String, "productive")
        XCTAssertTrue(readNote.body.contains("Test file I/O"))
        XCTAssertTrue(readNote.body.contains("Some notes here."))
    }

    func testReadNonexistentNote() async {
        let date = Date()

        do {
            _ = try await fileService.readDailyNote(for: date)
            XCTFail("Expected fileNotFound error")
        } catch let error as FileService.FileServiceError {
            if case .fileNotFound = error {
                // Expected error
            } else {
                XCTFail("Expected fileNotFound, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testWriteAtomicity() async throws {
        let date = Date()
        let note = try await fileService.createDailyNote(for: date)

        // Modify and write multiple times rapidly
        for i in 1...5 {
            var updatedNote = note
            updatedNote.body += "\n\nIteration \(i)"
            try await fileService.writeDailyNote(updatedNote)
        }

        // Read final version
        let finalNote = try await fileService.readDailyNote(for: date)
        XCTAssertTrue(finalNote.body.contains("Iteration 5"))
    }

    // MARK: - Append Section Tests

    func testAppendToSection() async throws {
        let date = Date()
        _ = try await fileService.createDailyNote(for: date)

        let content = """

        - Meeting with team at 10am
        - Lunch with client at 12pm
        """

        try await fileService.appendToSection(
            content,
            section: .capture,
            date: date
        )

        let note = try await fileService.readDailyNote(for: date)
        XCTAssertTrue(note.body.contains("Meeting with team"))
        XCTAssertTrue(note.body.contains("Lunch with client"))
    }

    func testAppendToNonexistentSection() async throws {
        let date = Date()
        let note = try await fileService.createDailyNote(for: date)

        // Remove Daily Briefing section from template (it's not in default template)
        // Append should create the section
        let content = """

        Today's schedule looks busy.
        """

        try await fileService.appendToSection(
            content,
            section: .dailyBriefing,
            date: date
        )

        let updatedNote = try await fileService.readDailyNote(for: date)
        XCTAssertTrue(updatedNote.hasSection(.dailyBriefing))
        XCTAssertTrue(updatedNote.body.contains("Today's schedule looks busy"))
    }

    func testAppendPreservesExistingContent() async throws {
        let date = Date()
        _ = try await fileService.createDailyNote(for: date)

        // Append first content
        try await fileService.appendToSection(
            "\n\nFirst entry",
            section: .capture,
            date: date
        )

        // Append second content
        try await fileService.appendToSection(
            "\n\nSecond entry",
            section: .capture,
            date: date
        )

        let note = try await fileService.readDailyNote(for: date)
        XCTAssertTrue(note.body.contains("First entry"))
        XCTAssertTrue(note.body.contains("Second entry"))
    }

    // MARK: - List Notes Tests

    func testListDailyNotes() async throws {
        // Create multiple notes
        let today = Date()
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!

        _ = try await fileService.createDailyNote(for: today)
        _ = try await fileService.createDailyNote(for: yesterday)
        _ = try await fileService.createDailyNote(for: twoDaysAgo)

        let dates = try await fileService.listDailyNotes()

        XCTAssertEqual(dates.count, 3)
        // Should be sorted
        XCTAssertTrue(dates[0] < dates[1])
        XCTAssertTrue(dates[1] < dates[2])
    }

    func testListDailyNotesEmptyVault() async throws {
        let dates = try await fileService.listDailyNotes()
        XCTAssertTrue(dates.isEmpty)
    }

    func testListDailyNotesIgnoresNonDateFiles() async throws {
        // Create a valid note
        let today = Date()
        _ = try await fileService.createDailyNote(for: today)

        // Create an invalid file in Daily Notes
        let invalidFile = tempVaultURL
            .appendingPathComponent("Daily Notes")
            .appendingPathComponent("README.md")
        try "# Not a daily note".write(to: invalidFile, atomically: true, encoding: .utf8)

        let dates = try await fileService.listDailyNotes()

        // Should only find the valid note
        XCTAssertEqual(dates.count, 1)
    }

    // MARK: - Daily Note Exists Tests

    func testDailyNoteExists() async throws {
        let date = Date()

        // Initially doesn't exist
        var exists = await fileService.dailyNoteExists(for: date)
        XCTAssertFalse(exists)

        // Create note
        _ = try await fileService.createDailyNote(for: date)

        // Now exists
        exists = await fileService.dailyNoteExists(for: date)
        XCTAssertTrue(exists)
    }

    // MARK: - Frontmatter Preservation Tests

    func testFrontmatterPreservation() async throws {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)

        // Create note with custom frontmatter
        let frontmatter: [String: Any] = [
            "date": dateString,
            "type": "daily",
            "tags": ["work", "planning"],
            "mood": "focused"
        ]

        let body = "# Test"

        let dailyNotesPath = tempVaultURL
            .appendingPathComponent("Daily Notes")
            .appendingPathComponent("\(dateString).md")

        let note = DailyNote(
            date: date,
            filePath: dailyNotesPath,
            frontmatter: frontmatter,
            body: body
        )

        try await fileService.writeDailyNote(note)

        // Append to section (should preserve frontmatter)
        try await fileService.appendToSection(
            "\n\nNew content",
            section: .capture,
            date: date
        )

        // Read and verify frontmatter preserved
        let readNote = try await fileService.readDailyNote(for: date)
        XCTAssertEqual(readNote.frontmatter["type"] as? String, "daily")
        XCTAssertEqual(readNote.frontmatter["mood"] as? String, "focused")
        XCTAssertNotNil(readNote.frontmatter["tags"])
    }

    // MARK: - Edge Cases

    func testHandlesUTF8Content() async throws {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)

        let frontmatter: [String: Any] = [
            "date": dateString,
            "type": "daily"
        ]

        let body = """
        # Test Unicode

        Emoji: 🎉 🚀 ✅
        Chinese: 你好世界
        Arabic: مرحبا بالعالم
        """

        let dailyNotesPath = tempVaultURL
            .appendingPathComponent("Daily Notes")
            .appendingPathComponent("\(dateString).md")

        let note = DailyNote(
            date: date,
            filePath: dailyNotesPath,
            frontmatter: frontmatter,
            body: body
        )

        try await fileService.writeDailyNote(note)
        let readNote = try await fileService.readDailyNote(for: date)

        XCTAssertTrue(readNote.body.contains("🎉"))
        XCTAssertTrue(readNote.body.contains("你好世界"))
        XCTAssertTrue(readNote.body.contains("مرحبا بالعالم"))
    }

    func testConcurrentReads() async throws {
        let date = Date()
        _ = try await fileService.createDailyNote(for: date)

        // Perform multiple concurrent reads
        await withTaskGroup(of: Void.self) { group in
            for _ in 1...10 {
                group.addTask {
                    do {
                        let _ = try await self.fileService.readDailyNote(for: date)
                    } catch {
                        XCTFail("Concurrent read failed: \(error)")
                    }
                }
            }
        }
    }
}
