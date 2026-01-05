import Foundation

/// Actor-based file service for thread-safe PKM vault operations.
///
/// All file I/O is isolated to this actor to prevent data races.
/// Follows append-only semantics for daily notes - never overwrites existing content.
actor FileService {

    /// Path to the PKM vault root directory
    private let vaultPath: URL

    /// File manager for I/O operations
    private let fileManager: FileManager

    /// Errors that can occur during file operations
    enum FileServiceError: Error, LocalizedError {
        case vaultNotFound
        case fileNotFound(URL)
        case readError(URL, Error)
        case writeError(URL, Error)
        case invalidPath

        var errorDescription: String? {
            switch self {
            case .vaultNotFound:
                return "PKM vault directory not found"
            case .fileNotFound(let url):
                return "File not found: \(url.path)"
            case .readError(let url, let error):
                return "Failed to read \(url.lastPathComponent): \(error.localizedDescription)"
            case .writeError(let url, let error):
                return "Failed to write \(url.lastPathComponent): \(error.localizedDescription)"
            case .invalidPath:
                return "Invalid file path"
            }
        }
    }

    // MARK: - Initialization

    /// Create a new file service
    ///
    /// - Parameter vaultPath: Path to PKM vault root (e.g., ~/Workspace/Projects/PKM/)
    /// - Throws: FileServiceError.vaultNotFound if vault doesn't exist
    init(vaultPath: URL) throws {
        self.vaultPath = vaultPath
        self.fileManager = FileManager.default

        // Verify vault exists
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: vaultPath.path, isDirectory: &isDirectory),
              isDirectory.boolValue else {
            throw FileServiceError.vaultNotFound
        }
    }

    // MARK: - Daily Note Operations

    /// Read a daily note from disk
    ///
    /// - Parameter date: Date of the note to read
    /// - Returns: DailyNote parsed from file
    /// - Throws: FileServiceError if file doesn't exist or can't be read
    func readDailyNote(for date: Date) async throws -> DailyNote {
        let filePath = dailyNotePath(for: date)

        guard fileManager.fileExists(atPath: filePath.path) else {
            throw FileServiceError.fileNotFound(filePath)
        }

        do {
            let content = try String(contentsOf: filePath, encoding: .utf8)
            let parseResult = try FrontmatterParser.parse(content)

            return DailyNote(
                date: date,
                filePath: filePath,
                frontmatter: parseResult.frontmatter,
                body: parseResult.body
            )
        } catch let error as FrontmatterParser.ParseError {
            throw FileServiceError.readError(filePath, error)
        } catch {
            throw FileServiceError.readError(filePath, error)
        }
    }

    /// Write a daily note to disk
    ///
    /// **Important:** This uses atomic writes to prevent corruption.
    ///
    /// - Parameter note: DailyNote to write
    /// - Throws: FileServiceError if write fails
    func writeDailyNote(_ note: DailyNote) async throws {
        do {
            let content = try FrontmatterParser.serialize(
                frontmatter: note.frontmatter,
                body: note.body
            )

            // Ensure parent directory exists
            let parentDir = note.filePath.deletingLastPathComponent()
            if !fileManager.fileExists(atPath: parentDir.path) {
                try fileManager.createDirectory(
                    at: parentDir,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            }

            // Atomic write
            try content.write(to: note.filePath, atomically: true, encoding: .utf8)
        } catch {
            throw FileServiceError.writeError(note.filePath, error)
        }
    }

    /// Create a new daily note from template
    ///
    /// - Parameter date: Date for the new note
    /// - Returns: New DailyNote created from template
    /// - Throws: FileServiceError if creation fails
    func createDailyNote(for date: Date) async throws -> DailyNote {
        let filePath = dailyNotePath(for: date)

        // Check if note already exists
        if fileManager.fileExists(atPath: filePath.path) {
            return try await readDailyNote(for: date)
        }

        // Create from template
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)

        formatter.dateFormat = "EEEE"
        let weekday = formatter.string(from: date)

        let frontmatter: [String: Any] = [
            "date": dateString,
            "type": "daily"
        ]

        let body = """
# \(dateString) - \(weekday)

## Morning Intentions
- [ ]

## Focus Blocks
### Block 1 (Morning)

### Block 2 (Afternoon)

## Capture

## End of Day
### Wins

### What didn't work

### Tomorrow's priority
"""

        let note = DailyNote(
            date: date,
            filePath: filePath,
            frontmatter: frontmatter,
            body: body
        )

        try await writeDailyNote(note)
        return note
    }

    /// Append content to a daily note section (append-only)
    ///
    /// This is the safe way to add content to notes - never overwrites.
    ///
    /// - Parameters:
    ///   - content: Content to append
    ///   - section: Section to append to
    ///   - date: Date of the note
    /// - Throws: FileServiceError if operation fails
    func appendToSection(
        _ content: String,
        section: DailyNote.Section,
        date: Date
    ) async throws {
        var note = try await readDailyNote(for: date)
        note = note.appendingToSection(content, section: section)
        try await writeDailyNote(note)
    }

    // MARK: - Path Helpers

    /// Get the file path for a daily note
    ///
    /// - Parameter date: Date of the note
    /// - Returns: URL to the note file
    private func dailyNotePath(for date: Date) -> URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let filename = formatter.string(from: date) + ".md"

        return vaultPath
            .appendingPathComponent("Daily Notes")
            .appendingPathComponent(filename)
    }

    // MARK: - Vault Info

    /// Check if a daily note exists
    ///
    /// - Parameter date: Date to check
    /// - Returns: True if note exists
    func dailyNoteExists(for date: Date) async -> Bool {
        let filePath = dailyNotePath(for: date)
        return fileManager.fileExists(atPath: filePath.path)
    }

    /// List all daily notes in vault
    ///
    /// - Returns: Array of dates for all daily notes
    /// - Throws: FileServiceError if directory can't be read
    func listDailyNotes() async throws -> [Date] {
        let dailyNotesPath = vaultPath.appendingPathComponent("Daily Notes")

        guard fileManager.fileExists(atPath: dailyNotesPath.path) else {
            return []
        }

        do {
            let files = try fileManager.contentsOfDirectory(
                at: dailyNotesPath,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"

            return files.compactMap { url -> Date? in
                let filename = url.deletingPathExtension().lastPathComponent
                return formatter.date(from: filename)
            }.sorted()
        } catch {
            throw FileServiceError.readError(dailyNotesPath, error)
        }
    }
}
