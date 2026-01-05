# PKM Menu Bar App

SwiftUI menu bar app for Personal Knowledge Management.

## Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI + AppKit (NSStatusItem)
- **Build System**: Swift Package Manager (not Xcode)
- **Data Layer**: Direct markdown file I/O (no database)
- **AI Integration**: Process() calls to Claude CLI via shell scripts

## File Locations

- **PKM Vault**: `~/Workspace/Projects/PKM/`
- **Claude CLI**: `/opt/homebrew/bin/claude`
- **Scripts**: `Sources/PKMApp/Resources/Scripts/`
- **GitHub Repo**: https://github.com/mbarnett2011/pkm-app
- **Plan**: `~/.claude/plans/keen-weaving-sloth.md`
- **Integration Plan**: `~/.claude/plans/cryptic-roaming-stearns.md`

## Build Commands

```bash
# Development build
swift build

# Run
swift run

# Release build
swift build -c release

# Run tests
swift test

# Generate Xcode project (if needed for debugging/signing)
swift package generate-xcodeproj
```

## Code Conventions

- SwiftUI views use MVVM pattern
- Services are actors for thread safety
- File I/O is async/await
- Error handling uses Result<T, Error> or throws
- All markdown operations preserve YAML frontmatter
- Daily notes are append-only (never overwrite)

## Dependencies

**Swift Packages:**
- [Yams](https://github.com/jpsim/Yams) - YAML frontmatter parsing
- [swift-markdown](https://github.com/apple/swift-markdown) - Markdown parsing/rendering

## PKM Ecosystem Integration

pkm-app integrates with two other components:

1. **Assistant Hub** (`~/Workspace/Projects/assistant-hub/`)
   - Python app that generates daily briefings (calendar + email + AI summary)
   - Runs on DigitalOcean droplet via cron (6 AM UTC daily)
   - Appends briefings to PKM Vault daily notes (## Daily Briefing section)
   - pkm-app will display these briefings in Phase 3

2. **PKM Vault** (`~/Workspace/Projects/PKM/`)
   - Markdown files with YAML frontmatter
   - Daily Notes/, Goals/, Projects/ directories
   - Single source of truth for all PKM data
   - pkm-app reads (and in future, writes) to this vault

## Development Workflow

1. **Claude Code writes Swift files** - Models, Views, Services
2. **Edit in VS Code** - Full LSP support
3. **Build from terminal** - `swift build`
4. **Test** - `swift run` to launch app
5. **Xcode only when needed** - Debugging, code signing, final .app bundle

## Key Implementation Notes

### Append-Only Daily Notes
```swift
// NEVER overwrite daily note content
func appendToSection(note: DailyNote, section: String, content: String) throws {
    var fullContent = try String(contentsOf: note.filePath)
    // Find section, append content
    try fullContent.write(to: note.filePath, atomically: true, encoding: .utf8)
}
```

### Frontmatter Preservation
```swift
// Always preserve existing frontmatter fields
func updateFrontmatter(url: URL, updates: [String: Any]) throws {
    let content = try String(contentsOf: url)
    var (frontmatter, body) = try FrontmatterParser.parse(content)

    // Merge updates (don't replace entire frontmatter)
    for (key, value) in updates {
        frontmatter[key] = value
    }

    let updated = try FrontmatterParser.serialize(frontmatter: frontmatter, body: body)
    try updated.write(to: url, atomically: true, encoding: .utf8)
}
```

## Current Phase

**Phase 1: Foundation** ✅
- SPM project structure
- Menu bar infrastructure
- Basic SwiftUI views

**Phase 3: GitHub Repository Setup** ✅ (Jan 4, 2026)
- GitHub repo created: mbarnett2011/pkm-app
- Documentation added: DEVELOPMENT.md, ROADMAP.md, README.md
- Templates: .github/ISSUE_TEMPLATE.md, PULL_REQUEST_TEMPLATE.md
- All documentation committed and pushed

**Next: Phase 2 - Data Models & File Operations**
- Create Swift models matching PKM markdown schema (DailyNote, Goal, Project)
- Implement FileService actor for thread-safe markdown I/O
- Build FrontmatterParser for YAML handling with Yams
- Create TemplateService for note creation from templates
- Comprehensive test coverage for all services

## Testing

Run tests:
```bash
swift test
```

Test individual modules:
```bash
swift test --filter FileServiceTests
swift test --filter FrontmatterParserTests
```
