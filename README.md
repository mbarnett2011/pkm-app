# PKM Menu Bar App

A native macOS menu bar application for Personal Knowledge Management, built with Swift + SwiftUI.

PKM App integrates with a markdown-based PKM vault to provide quick access to daily notes, goals, and automated briefings from [Assistant Hub](https://github.com/mbarnett2011/assistant-hub).

---

## Status

**Phase 1: Complete** ✅
Foundation and menu bar UI are built. Phase 2 (Data Models & File Operations) is next.

See [ROADMAP.md](ROADMAP.md) for the full development plan.

---

## Features

### Current (Phase 1)
- ✅ Menu bar app with native macOS integration
- ✅ SwiftUI-based UI architecture
- ✅ Basic project structure and scaffolding

### Planned
- **Phase 2:** Data models (DailyNote, Goal, Project) and file I/O
- **Phase 3:** Assistant Hub integration (display daily briefings)
- **Phase 4:** Goal hierarchy visualization and timeline
- **Phase 5:** Quick capture, search, and advanced features

See [ROADMAP.md](ROADMAP.md) for details.

---

## Installation

### Prerequisites

- **macOS 13.0+** (Ventura or later)
- **Xcode 15.0+** (includes Swift 5.9+)
- **PKM Vault** at `~/Workspace/Projects/PKM/` (or configure custom path)

### Build from Source

```bash
# Clone the repository
git clone https://github.com/mbarnett2011/pkm-app.git
cd pkm-app

# Build the app
swift build

# Run the app
swift run
```

The app will appear in your macOS menu bar.

### Building for Release

```bash
swift build -c release
```

The optimized executable will be at `.build/release/PKMApp`.

For creating a macOS `.app` bundle, use Xcode (future work).

---

## Quick Start

### Running the App

```bash
swift run
```

The PKM icon will appear in your menu bar. Click it to open the menu.

### Running Tests

```bash
swift test
```

---

## Architecture

PKM App is part of a three-component PKM ecosystem:

```
┌─────────────────┐
│  Assistant Hub  │ (Python, cron on droplet)
│  Daily briefings │
└────────┬────────┘
         │ writes
         ▼
┌─────────────────┐
│   PKM Vault     │ (Markdown + YAML frontmatter)
│ ~/Workspace/    │
│   Projects/PKM/ │
└────────┬────────┘
         │ reads
         ▼
┌─────────────────┐
│   pkm-app       │ (Swift, macOS menu bar)
│  This project   │
└─────────────────┘
```

**Design Principles:**
- **MVVM Pattern:** SwiftUI views use view models
- **Actors for I/O:** File operations are actor-isolated for thread safety
- **Append-Only:** Never overwrite existing PKM content
- **YAML Preservation:** Parse and serialize frontmatter without corruption

See [DEVELOPMENT.md](DEVELOPMENT.md) for architecture details.

---

## Development

See [DEVELOPMENT.md](DEVELOPMENT.md) for:
- Development environment setup
- Project structure
- Testing guidelines
- Debugging tips
- Contributing guidelines

---

## Roadmap

See [ROADMAP.md](ROADMAP.md) for the complete development plan, including:
- **Phase 2:** Data Models & File Operations (next)
- **Phase 3:** Assistant Hub Integration
- **Phase 4:** Goal Hierarchy & Timeline
- **Phase 5:** Advanced Features

---

## Integration

### PKM Vault

PKM App reads from and (in future phases) writes to a markdown-based vault:

- **Daily Notes:** `~/Workspace/Projects/PKM/Daily Notes/YYYY-MM-DD.md`
- **Goals:** `~/Workspace/Projects/PKM/Goals/`
- **Projects:** `~/Workspace/Projects/PKM/Projects/`

All files use YAML frontmatter for metadata.

### Assistant Hub

[Assistant Hub](https://github.com/mbarnett2011/assistant-hub) generates daily briefings (calendar + email + AI summary) and appends them to PKM Vault daily notes at 6 AM UTC.

PKM App (in Phase 3) will display these briefings in the menu bar.

### Raycast Integration

Works alongside existing Raycast scripts:
- `pkm today` - Open today's daily note
- `pkm capture [text]` - Quick capture
- `pkm sync [message]` - Commit and sync to droplet

---

## Project Structure

```
pkm-app/
├── Package.swift              # SPM manifest
├── Sources/
│   └── PKMApp/
│       ├── PKMApp.swift      # Main entry point (@main)
│       ├── AppDelegate.swift # AppKit app delegate
│       ├── MenuBarController.swift # Menu bar UI
│       ├── Views/            # SwiftUI views
│       ├── Models/           # Data models (Phase 2)
│       └── Services/         # File I/O, parsing (Phase 2)
├── Tests/
│   └── PKMAppTests/          # Unit tests
├── README.md                 # This file
├── DEVELOPMENT.md            # Developer guide
└── ROADMAP.md                # Development plan
```

---

## Dependencies

Managed via Swift Package Manager:

- **[Yams](https://github.com/jpsim/Yams)** - YAML frontmatter parsing
- **[swift-markdown](https://github.com/apple/swift-markdown)** - Markdown parsing (planned)

---

## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make changes and add tests
4. Open a Pull Request

See `.github/PULL_REQUEST_TEMPLATE.md` for PR guidelines.

For bugs or feature requests, open an issue using `.github/ISSUE_TEMPLATE.md`.

---

## License

MIT License (or specify your license)

---

## Links

- **GitHub Repository:** https://github.com/mbarnett2011/pkm-app
- **Development Guide:** [DEVELOPMENT.md](DEVELOPMENT.md)
- **Roadmap:** [ROADMAP.md](ROADMAP.md)
- **Assistant Hub:** https://github.com/mbarnett2011/assistant-hub

---

## Acknowledgments

Built with Swift, SwiftUI, and the power of native macOS development.
