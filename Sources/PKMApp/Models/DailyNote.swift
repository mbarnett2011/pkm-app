import Foundation

/// Represents a daily note in the PKM vault.
///
/// Daily notes follow the format:
/// ```
/// ---
/// date: 2026-01-04
/// type: daily
/// ---
///
/// # 2026-01-04 - Saturday
///
/// ## Daily Briefing
/// ...
///
/// ## Morning Intentions
/// ...
/// ```
struct DailyNote: Identifiable, Equatable {

    /// Unique identifier (uses date as ID)
    var id: Date { date }

    /// Date this note represents
    let date: Date

    /// File path to the note
    let filePath: URL

    /// YAML frontmatter metadata
    var frontmatter: [String: Any]

    /// Markdown body content (everything after frontmatter)
    var body: String

    /// Common sections found in daily notes
    enum Section: String, CaseIterable {
        case dailyBriefing = "## Daily Briefing"
        case morningIntentions = "## Morning Intentions"
        case focusBlocks = "## Focus Blocks"
        case capture = "## Capture"
        case endOfDay = "## End of Day"

        /// Returns the section title without the markdown header
        var title: String {
            String(rawValue.dropFirst(3)) // Remove "## "
        }
    }

    /// Errors that can occur when working with daily notes
    enum DailyNoteError: Error, LocalizedError {
        case invalidDate
        case invalidFilePath
        case sectionNotFound(String)

        var errorDescription: String? {
            switch self {
            case .invalidDate:
                return "Invalid date format in daily note"
            case .invalidFilePath:
                return "Invalid file path for daily note"
            case .sectionNotFound(let section):
                return "Section '\(section)' not found in daily note"
            }
        }
    }

    // MARK: - Initialization

    /// Create a daily note from file content
    ///
    /// - Parameters:
    ///   - date: Date this note represents
    ///   - filePath: Path to the note file
    ///   - frontmatter: YAML frontmatter dictionary
    ///   - body: Markdown body content
    init(date: Date, filePath: URL, frontmatter: [String: Any], body: String) {
        self.date = date
        self.filePath = filePath
        self.frontmatter = frontmatter
        self.body = body
    }

    // MARK: - Section Helpers

    /// Check if a section exists in the note
    ///
    /// - Parameter section: Section to check for
    /// - Returns: True if section exists
    func hasSection(_ section: Section) -> Bool {
        body.contains(section.rawValue)
    }

    /// Extract content from a specific section
    ///
    /// - Parameter section: Section to extract
    /// - Returns: Content of the section (excluding header)
    /// - Throws: DailyNoteError.sectionNotFound if section doesn't exist
    func sectionContent(_ section: Section) throws -> String {
        guard hasSection(section) else {
            throw DailyNoteError.sectionNotFound(section.title)
        }

        let lines = body.split(separator: "\n", omittingEmptySubsequences: false)
        guard let startIndex = lines.firstIndex(where: { $0 == section.rawValue }) else {
            throw DailyNoteError.sectionNotFound(section.title)
        }

        // Find next section or end of file
        let contentStart = lines.index(after: startIndex)
        var contentEnd = lines.endIndex

        for (index, line) in lines[contentStart...].enumerated() {
            if line.hasPrefix("## ") {
                contentEnd = lines.index(contentStart, offsetBy: index)
                break
            }
        }

        let sectionLines = lines[contentStart..<contentEnd]
        return sectionLines.joined(separator: "\n").trimmingCharacters(in: .newlines)
    }

    /// Append content to a specific section
    ///
    /// If section doesn't exist, it will be created at the end of the note.
    ///
    /// - Parameters:
    ///   - content: Content to append
    ///   - section: Section to append to
    /// - Returns: New DailyNote with updated body
    func appendingToSection(_ content: String, section: Section) -> DailyNote {
        var updatedBody = body

        if hasSection(section) {
            // Find section and append content
            let lines = body.split(separator: "\n", omittingEmptySubsequences: false)
            guard let startIndex = lines.firstIndex(where: { $0 == section.rawValue }) else {
                // Section header exists but couldn't find it (shouldn't happen)
                return self
            }

            // Find next section or end of file
            let contentStart = lines.index(after: startIndex)
            var insertIndex = lines.endIndex

            for (index, line) in lines[contentStart...].enumerated() {
                if line.hasPrefix("## ") {
                    insertIndex = lines.index(contentStart, offsetBy: index)
                    break
                }
            }

            // Insert content before next section
            var mutableLines = Array(lines)
            mutableLines.insert(contentsOf: content.split(separator: "\n", omittingEmptySubsequences: false), at: insertIndex)
            updatedBody = mutableLines.joined(separator: "\n")
        } else {
            // Section doesn't exist - create it at end
            updatedBody += "\n\n\(section.rawValue)\n\(content)"
        }

        return DailyNote(
            date: date,
            filePath: filePath,
            frontmatter: frontmatter,
            body: updatedBody
        )
    }

    // MARK: - Equatable

    static func == (lhs: DailyNote, rhs: DailyNote) -> Bool {
        lhs.date == rhs.date &&
        lhs.filePath == rhs.filePath &&
        lhs.body == rhs.body
        // Note: frontmatter comparison is complex due to [String: Any], so we skip it
    }
}

// MARK: - Convenience Helpers

extension DailyNote {

    /// Get the date from frontmatter, if available
    var frontmatterDate: Date? {
        guard let dateString = frontmatter["date"] as? String else {
            return nil
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter.date(from: dateString)
    }

    /// Get the note type from frontmatter
    var noteType: String? {
        frontmatter["type"] as? String
    }

    /// Check if this is a daily note (type: daily)
    var isDaily: Bool {
        noteType == "daily"
    }
}
