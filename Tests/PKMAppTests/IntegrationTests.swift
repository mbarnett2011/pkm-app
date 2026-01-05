import XCTest
@testable import PKMApp
import Foundation

/// Integration tests with real PKM vault
///
/// These tests use the actual PKM vault at ~/Workspace/Projects/PKM/
/// and verify that FileService works correctly with real daily notes.
final class IntegrationTests: XCTestCase {

    var vaultPath: URL!
    var fileService: FileService!

    override func setUp() async throws {
        try await super.setUp()

        // Real PKM vault path
        vaultPath = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Workspace/Projects/PKM")

        // Skip tests if vault doesn't exist
        guard FileManager.default.fileExists(atPath: vaultPath.path) else {
            throw XCTSkip("PKM vault not found at \(vaultPath.path)")
        }

        fileService = try FileService(vaultPath: vaultPath)
    }

    // MARK: - Real Vault Tests

    func testReadTodaysDailyNote() async throws {
        let today = Date()

        // Check if today's note exists
        let exists = await fileService.dailyNoteExists(for: today)

        if exists {
            // Read the note
            let note = try await fileService.readDailyNote(for: today)

            // Verify basic structure
            XCTAssertEqual(note.date, today)
            XCTAssertNotNil(note.frontmatter["date"])
            XCTAssertEqual(note.frontmatter["type"] as? String, "daily")

            // Should have at least the title
            XCTAssertTrue(note.body.contains("# "))

            print("✓ Successfully read today's daily note")
            print("  Date: \(note.frontmatter["date"] ?? "unknown")")
            print("  Type: \(note.frontmatter["type"] ?? "unknown")")
            print("  Has Daily Briefing: \(note.hasSection(.dailyBriefing))")
        } else {
            print("ℹ️  Today's note doesn't exist yet (this is okay)")
        }
    }

    func testListRealDailyNotes() async throws {
        let dates = try await fileService.listDailyNotes()

        // Should have at least one note (assuming vault is being used)
        XCTAssertGreaterThan(dates.count, 0, "Expected at least one daily note in vault")

        // Dates should be sorted
        for i in 0..<(dates.count - 1) {
            XCTAssertLessThan(dates[i], dates[i + 1], "Dates should be sorted")
        }

        print("✓ Found \(dates.count) daily notes in vault")
        if let first = dates.first, let last = dates.last {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            print("  Range: \(formatter.string(from: first)) to \(formatter.string(from: last))")
        }
    }

    func testReadNoteWithAssistantHubBriefing() async throws {
        // Read today's note (if it exists)
        let today = Date()
        let exists = await fileService.dailyNoteExists(for: today)

        guard exists else {
            throw XCTSkip("Today's note doesn't exist yet")
        }

        let note = try await fileService.readDailyNote(for: today)

        // Check if Assistant Hub has written a briefing
        if note.hasSection(.dailyBriefing) {
            let briefingContent = try note.sectionContent(.dailyBriefing)

            print("✓ Daily Briefing section found!")
            print("  Preview: \(briefingContent.prefix(200))...")

            // Verify it's not empty
            XCTAssertFalse(briefingContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        } else {
            print("ℹ️  No Daily Briefing section yet (Assistant Hub runs at 6 AM UTC)")
        }
    }

    func testFrontmatterParsing() async throws {
        // Read any existing note
        let dates = try await fileService.listDailyNotes()

        guard let mostRecent = dates.last else {
            throw XCTSkip("No daily notes found")
        }

        let note = try await fileService.readDailyNote(for: mostRecent)

        // Verify frontmatter is parsed correctly
        XCTAssertNotNil(note.frontmatter["date"], "Should have date field")
        XCTAssertEqual(note.frontmatter["type"] as? String, "daily", "Should be type: daily")

        // Verify frontmatter date helper works
        XCTAssertNotNil(note.frontmatterDate, "Should parse date from frontmatter")
        XCTAssertTrue(note.isDaily, "Should be identified as daily note")

        print("✓ Frontmatter parsed correctly")
        print("  Date: \(note.frontmatter["date"] ?? "unknown")")
        print("  Type: \(note.noteType ?? "unknown")")
    }

    // MARK: - Safe Write Tests

    func testAppendToTodaysNote() async throws {
        // This test is more careful - it only appends if today's note exists
        let today = Date()
        let exists = await fileService.dailyNoteExists(for: today)

        guard exists else {
            throw XCTSkip("Today's note doesn't exist yet - skipping write test")
        }

        // Read current state
        let beforeNote = try await fileService.readDailyNote(for: today)
        let beforeBody = beforeNote.body

        // Append a test marker
        let testMarker = "\n\n<!-- Integration test marker: \(Date().timeIntervalSince1970) -->"

        try await fileService.appendToSection(
            testMarker,
            section: .capture,
            date: today
        )

        // Read updated state
        let afterNote = try await fileService.readDailyNote(for: today)

        // Verify append worked
        XCTAssertTrue(afterNote.body.contains("Integration test marker"))

        // Verify original content preserved
        XCTAssertTrue(afterNote.body.contains(beforeBody.trimmingCharacters(in: .whitespacesAndNewlines).prefix(100)))

        print("✓ Successfully appended to today's note (append-only semantics verified)")

        // Clean up - remove test marker
        var cleanedNote = afterNote
        cleanedNote.body = cleanedNote.body.replacingOccurrences(of: testMarker, with: "")
        try await fileService.writeDailyNote(cleanedNote)

        print("✓ Cleaned up test marker")
    }
}
