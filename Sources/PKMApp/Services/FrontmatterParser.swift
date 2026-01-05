import Foundation
import Yams

/// Parser for YAML frontmatter in markdown files.
///
/// PKM vault files use YAML frontmatter for metadata:
/// ```
/// ---
/// date: 2026-01-04
/// type: daily
/// ---
///
/// # Content here
/// ```
///
/// This parser extracts frontmatter and body separately, allowing
/// safe modification without corrupting either section.
enum FrontmatterParser {

    /// Result of parsing a markdown file with frontmatter
    struct ParseResult {
        var frontmatter: [String: Any]
        let body: String
    }

    /// Errors that can occur during frontmatter parsing
    enum ParseError: Error, LocalizedError {
        case invalidFrontmatter(String)
        case malformedYAML(String)

        var errorDescription: String? {
            switch self {
            case .invalidFrontmatter(let message):
                return "Invalid frontmatter: \(message)"
            case .malformedYAML(let message):
                return "Malformed YAML: \(message)"
            }
        }
    }

    /// Parse markdown content with YAML frontmatter
    ///
    /// - Parameter content: Full markdown file content
    /// - Returns: ParseResult with frontmatter dictionary and body string
    /// - Throws: ParseError if frontmatter is malformed
    static func parse(_ content: String) throws -> ParseResult {
        let lines = content.split(separator: "\n", omittingEmptySubsequences: false)

        // Check if file starts with frontmatter delimiter
        guard lines.first == "---" else {
            // No frontmatter - return empty dict and full content as body
            return ParseResult(frontmatter: [:], body: content)
        }

        // Find closing delimiter
        guard let closingIndex = lines.dropFirst().firstIndex(of: "---") else {
            throw ParseError.invalidFrontmatter("Missing closing '---' delimiter")
        }

        // Extract YAML content between delimiters
        let yamlLines = lines[1..<closingIndex]
        let yamlString = yamlLines.joined(separator: "\n")

        // Parse YAML
        let frontmatter: [String: Any]
        if yamlString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // Empty frontmatter is valid
            frontmatter = [:]
        } else {
            do {
                guard let parsed = try Yams.load(yaml: yamlString) as? [String: Any] else {
                    throw ParseError.malformedYAML("YAML did not parse to dictionary")
                }
                frontmatter = parsed
            } catch {
                throw ParseError.malformedYAML(error.localizedDescription)
            }
        }

        // Extract body (everything after closing delimiter)
        let bodyStartIndex = lines.index(after: closingIndex)
        let bodyLines = lines[bodyStartIndex...]
        let body = bodyLines.joined(separator: "\n")

        return ParseResult(frontmatter: frontmatter, body: body)
    }

    /// Serialize frontmatter and body back to markdown content
    ///
    /// - Parameters:
    ///   - frontmatter: Dictionary of frontmatter key-value pairs
    ///   - body: Markdown body content
    /// - Returns: Full markdown content with frontmatter
    /// - Throws: ParseError if frontmatter cannot be serialized
    static func serialize(frontmatter: [String: Any], body: String) throws -> String {
        // If frontmatter is empty, just return body
        if frontmatter.isEmpty {
            return body
        }

        // Serialize frontmatter to YAML
        let yamlString: String
        do {
            yamlString = try Yams.dump(object: frontmatter)
        } catch {
            throw ParseError.malformedYAML("Failed to serialize frontmatter: \(error.localizedDescription)")
        }

        // Construct full markdown with frontmatter
        let trimmedYAML = yamlString.trimmingCharacters(in: .newlines)
        return "---\n\(trimmedYAML)\n---\n\(body)"
    }

    /// Update specific frontmatter fields while preserving others
    ///
    /// - Parameters:
    ///   - content: Original markdown content
    ///   - updates: Dictionary of fields to update/add
    /// - Returns: Updated markdown content
    /// - Throws: ParseError if parsing or serialization fails
    static func updateFrontmatter(_ content: String, updates: [String: Any]) throws -> String {
        var result = try parse(content)

        // Merge updates into existing frontmatter
        for (key, value) in updates {
            result.frontmatter[key] = value
        }

        return try serialize(frontmatter: result.frontmatter, body: result.body)
    }
}
