# Development Guide

This guide covers setting up your development environment and contributing to pkm-app.

## Requirements

- **macOS 13.0+** (Ventura or later)
- **Swift 5.9+** (comes with Xcode 15+)
- **Xcode 15.0+** (recommended for development)
- **Swift Package Manager** (included with Swift)

## Getting Started

### Clone the Repository

```bash
git clone https://github.com/mbarnett2011/pkm-app.git
cd pkm-app
```

### Build the Project

```bash
swift build
```

This will:
1. Resolve dependencies (Yams, swift-markdown)
2. Compile all Swift sources
3. Generate the executable in `.build/debug/`

### Run the Application

```bash
swift run
```

This launches the menu bar application. You should see the PKM icon appear in your macOS menu bar.

### Run Tests

```bash
swift test
```

This runs the test suite in `Tests/PKMAppTests/`.

## Project Structure

```
pkm-app/
├── Sources/
│   └── PKMApp/
│       ├── PKMApp.swift           # Main entry point (@main)
│       ├── AppDelegate.swift      # AppKit app delegate
│       ├── MenuBarController.swift # Menu bar UI controller
│       ├── Views/                 # SwiftUI views
│       ├── Models/                # Data models (Phase 2)
│       └── Services/              # Business logic (Phase 2)
├── Tests/
│   └── PKMAppTests/               # Unit tests
├── Package.swift                  # SPM manifest
└── README.md                      # Project overview
```

## Architecture

### Design Patterns

- **MVVM (Model-View-ViewModel)**: SwiftUI views use view models for state management
- **Actor Isolation**: File I/O operations use Swift actors to prevent data races
- **Append-Only Semantics**: Never overwrite existing PKM content, only append
- **YAML Frontmatter Preservation**: Parse, modify, and serialize without corruption

### Key Architectural Decisions

1. **Swift Actors for File I/O**: All file system operations run in isolated actors to ensure thread safety
2. **Append-Only Daily Notes**: Briefings and content are appended, never overwriting user data
3. **YAML-Safe Parsing**: Uses Yams library to preserve frontmatter structure
4. **Menu Bar First**: Native macOS menu bar UI for quick access (not a window-based app)

## Dependencies

Managed via Swift Package Manager in `Package.swift`:

- **[Yams](https://github.com/jpsim/Yams)** - YAML parsing for frontmatter
- **[swift-markdown](https://github.com/apple/swift-markdown)** - Markdown parsing (planned for Phase 2)

To update dependencies:

```bash
swift package update
```

## Development Workflow

### Phase 1 (Complete)

Phase 1 focused on scaffolding and menu bar UI:
- Menu bar app appears in macOS status bar
- Basic SwiftUI views and AppKit integration
- Project structure and SPM configuration

### Phase 2 (Next)

Phase 2 will add data models and file operations:
- `DailyNote.swift` - Daily note representation
- `Goal.swift` - Goal hierarchy (3-year → quarterly → monthly)
- `FileService.swift` (actor) - Read/write markdown files
- `FrontmatterParser.swift` - YAML frontmatter parsing

See `ROADMAP.md` for full phase breakdown.

## Building for Release

```bash
swift build -c release
```

The optimized executable will be at `.build/release/PKMApp`.

To create a macOS app bundle (future work):
1. Use Xcode to build the app
2. Archive and export as .app bundle
3. Sign and notarize for distribution

## Testing Guidelines

- Write tests for all business logic in `Services/` and `Models/`
- Use `XCTest` framework (standard Swift testing)
- Mock file I/O using protocols and dependency injection
- Test YAML frontmatter parsing edge cases (empty, malformed, missing)

### Running Specific Tests

```bash
swift test --filter PKMAppTests.FileServiceTests
```

## Debugging

### Xcode Debugging

1. Open `Package.swift` in Xcode
2. Set breakpoints in Swift source files
3. Run via Product → Run (⌘R)
4. Use Xcode's debugger and console

### Command Line Debugging

```bash
lldb .build/debug/PKMApp
(lldb) run
```

## Code Style

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use SwiftLint (optional, not yet configured)
- Prefer `actor` over `DispatchQueue` for concurrency
- Use `async/await` over completion handlers
- Document public APIs with DocC-style comments

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Make changes and add tests
4. Run tests (`swift test`)
5. Commit with descriptive messages
6. Push and open a Pull Request

See `.github/PULL_REQUEST_TEMPLATE.md` for PR guidelines.

## Troubleshooting

### Build Errors

**Issue:** "error: manifest parse error(s)"

**Fix:** Check `Package.swift` syntax. Ensure Swift tools version matches your installation:
```bash
swift --version
```

**Issue:** "Cannot find 'Yams' in scope"

**Fix:** Resolve dependencies:
```bash
swift package resolve
swift build
```

### Runtime Errors

**Issue:** App doesn't appear in menu bar

**Fix:** Check `MenuBarController.swift` initialization. Ensure `NSStatusBar.system.statusItem(withLength:)` is called on main thread.

**Issue:** Permission errors reading PKM vault

**Fix:** Grant Full Disk Access to the app in System Preferences → Security & Privacy → Privacy → Full Disk Access.

## Resources

- [Swift Documentation](https://swift.org/documentation/)
- [Swift Package Manager Guide](https://swift.org/package-manager/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [Yams Documentation](https://github.com/jpsim/Yams)

## Questions?

Open an issue on GitHub or check existing issues for common questions.
