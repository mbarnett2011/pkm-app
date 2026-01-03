# PKM Menu Bar App

Native macOS menu bar application for Personal Knowledge Management, built with Swift + SwiftUI.

## Features

- **Quick Capture** - Fast inbox capture with timestamp
- **Today's Overview** - Dashboard showing daily note, inbox count, current goals
- **Timeline View** - Calendar-based navigation of all daily notes
- **Search** - Full-text vault search via mdfind
- **Apple Notes Integration** - Side-by-side search view
- **Claude AI Features** - Weekly reviews, accountability checks
- **Goal Hierarchy** - Visual tree of cascading goals

## Requirements

- macOS 13.0+
- Swift 5.9+
- Claude Code CLI at `/opt/homebrew/bin/claude`
- PKM vault at `~/Workspace/Projects/PKM/`

## Build & Run

```bash
# Install dependencies and build
swift build

# Run the app
swift run

# Build for release
swift build -c release

# Generate Xcode project (if needed)
swift package generate-xcodeproj
```

## Development

Built using **Swift Package Manager** for CLI-first development in Claude Code / VS Code.

### Project Structure

```
pkm-app/
├── Package.swift              # SPM manifest
├── Sources/PKMApp/
│   ├── main.swift            # App entry point
│   ├── AppDelegate.swift     # Menu bar setup
│   ├── Models/               # Data models
│   ├── Services/             # File I/O, Claude CLI integration
│   ├── Views/                # SwiftUI views
│   └── ViewModels/           # View models
└── Tests/                    # Unit tests
```

### Architecture

- **Hybrid Integration**: Direct markdown file I/O + Claude CLI for AI features
- **No Database**: Markdown files are the source of truth
- **Menu Bar Only**: NSStatusItem, hidden from dock
- **Swift Package Manager**: CLI-friendly, git-friendly

## Integration

- Works with existing Raycast scripts
- Syncs via `~/Scripts/sync-droplet.sh pkm`
- Uses `~/.claude/agents/pkm.md` for AI features

## Current Status

**Phase 1 Complete** - Foundation
- ✅ SPM project structure
- ✅ Menu bar icon with popover
- ✅ Tab navigation (Today, Timeline, Search, Apple Notes)
- ✅ Placeholder views

**Next**: Phase 2 - Data models (DailyNote, Goal, etc.)
