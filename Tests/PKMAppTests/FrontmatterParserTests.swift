import XCTest
@testable import PKMApp

final class FrontmatterParserTests: XCTestCase {

    // MARK: - Parsing Tests

    func testParseValidFrontmatter() throws {
        let content = """
        ---
        date: "2026-01-04"
        type: daily
        tags: [work, planning]
        ---

        # Daily Note

        Some content here.
        """

        let result = try FrontmatterParser.parse(content)

        XCTAssertEqual(result.frontmatter["date"] as? String, "2026-01-04")
        XCTAssertEqual(result.frontmatter["type"] as? String, "daily")
        XCTAssertTrue(result.body.contains("# Daily Note"))
        XCTAssertTrue(result.body.contains("Some content here."))
    }

    func testParseEmptyFrontmatter() throws {
        let content = """
        ---
        ---

        # Content Only

        No frontmatter fields.
        """

        let result = try FrontmatterParser.parse(content)

        XCTAssertTrue(result.frontmatter.isEmpty)
        XCTAssertTrue(result.body.contains("# Content Only"))
    }

    func testParseNoFrontmatter() throws {
        let content = """
        # Just Content

        No frontmatter at all.
        """

        let result = try FrontmatterParser.parse(content)

        XCTAssertTrue(result.frontmatter.isEmpty)
        XCTAssertEqual(result.body, content)
    }

    func testParseMissingClosingDelimiter() {
        let content = """
        ---
        date: 2026-01-04

        # Content without closing delimiter
        """

        XCTAssertThrowsError(try FrontmatterParser.parse(content)) { error in
            guard case FrontmatterParser.ParseError.invalidFrontmatter = error else {
                XCTFail("Expected invalidFrontmatter error")
                return
            }
        }
    }

    func testParseMalformedYAML() {
        let content = """
        ---
        date: 2026-01-04
        invalid yaml syntax here: [ unclosed bracket
        ---

        # Content
        """

        XCTAssertThrowsError(try FrontmatterParser.parse(content)) { error in
            guard case FrontmatterParser.ParseError.malformedYAML = error else {
                XCTFail("Expected malformedYAML error")
                return
            }
        }
    }

    func testParsePreservesWhitespace() throws {
        let content = """
        ---
        date: 2026-01-04
        ---


        # Content with leading newlines

        Multiple paragraphs.

        With spacing.
        """

        let result = try FrontmatterParser.parse(content)

        // Body should preserve the structure
        XCTAssertTrue(result.body.hasPrefix("\n\n")) // Leading newlines preserved
        XCTAssertTrue(result.body.contains("Multiple paragraphs."))
    }

    // MARK: - Serialization Tests

    func testSerializeValidFrontmatter() throws {
        let frontmatter: [String: Any] = [
            "date": "2026-01-04",
            "type": "daily"
        ]
        let body = """
        # Daily Note

        Content here.
        """

        let result = try FrontmatterParser.serialize(frontmatter: frontmatter, body: body)

        XCTAssertTrue(result.hasPrefix("---\n"))
        XCTAssertTrue(result.contains("date: "))
        XCTAssertTrue(result.contains("type: daily"))
        XCTAssertTrue(result.contains("---\n"))
        XCTAssertTrue(result.contains("# Daily Note"))
    }

    func testSerializeEmptyFrontmatter() throws {
        let frontmatter: [String: Any] = [:]
        let body = "# Just content"

        let result = try FrontmatterParser.serialize(frontmatter: frontmatter, body: body)

        // Empty frontmatter should just return body
        XCTAssertEqual(result, body)
    }

    func testSerializeRoundTrip() throws {
        let original = """
        ---
        date: "2026-01-04"
        type: daily
        ---

        # Content

        Body text.
        """

        // Parse then serialize
        let parsed = try FrontmatterParser.parse(original)
        let serialized = try FrontmatterParser.serialize(
            frontmatter: parsed.frontmatter,
            body: parsed.body
        )

        // Parse the serialized version
        let reparsed = try FrontmatterParser.parse(serialized)

        // Should have same frontmatter
        XCTAssertEqual(reparsed.frontmatter["date"] as? String, "2026-01-04")
        XCTAssertEqual(reparsed.frontmatter["type"] as? String, "daily")

        // Body should be preserved
        XCTAssertTrue(reparsed.body.contains("# Content"))
        XCTAssertTrue(reparsed.body.contains("Body text."))
    }

    // MARK: - Update Tests

    func testUpdateFrontmatter() throws {
        let content = """
        ---
        date: "2026-01-04"
        type: daily
        ---

        # Content
        """

        let updates: [String: Any] = [
            "type": "weekly", // Update existing field
            "status": "complete" // Add new field
        ]

        let result = try FrontmatterParser.updateFrontmatter(content, updates: updates)
        let parsed = try FrontmatterParser.parse(result)

        // Original field preserved
        XCTAssertEqual(parsed.frontmatter["date"] as? String, "2026-01-04")

        // Updated field changed
        XCTAssertEqual(parsed.frontmatter["type"] as? String, "weekly")

        // New field added
        XCTAssertEqual(parsed.frontmatter["status"] as? String, "complete")

        // Body preserved
        XCTAssertTrue(parsed.body.contains("# Content"))
    }

    func testUpdatePreservesBody() throws {
        let content = """
        ---
        date: "2026-01-04"
        ---

        # Important Content

        Do not modify this.
        """

        let updates: [String: Any] = ["type": "daily"]

        let result = try FrontmatterParser.updateFrontmatter(content, updates: updates)
        let parsed = try FrontmatterParser.parse(result)

        // Body should be exactly the same
        XCTAssertTrue(parsed.body.contains("# Important Content"))
        XCTAssertTrue(parsed.body.contains("Do not modify this."))
    }

    // MARK: - Edge Cases

    func testParseMultipleDashesInContent() throws {
        let content = """
        ---
        date: "2026-01-04"
        ---

        # Content

        ---

        This line has dashes but isn't frontmatter.
        """

        let result = try FrontmatterParser.parse(content)

        XCTAssertEqual(result.frontmatter["date"] as? String, "2026-01-04")
        XCTAssertTrue(result.body.contains("This line has dashes"))
    }

    func testParseComplexYAML() throws {
        let content = """
        ---
        date: "2026-01-04"
        type: daily
        tags:
          - work
          - planning
        metadata:
          mood: good
          energy: high
        ---

        # Content
        """

        let result = try FrontmatterParser.parse(content)

        XCTAssertEqual(result.frontmatter["date"] as? String, "2026-01-04")
        XCTAssertNotNil(result.frontmatter["tags"])
        XCTAssertNotNil(result.frontmatter["metadata"])
    }
}
