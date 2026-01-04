# Roadmap

This document outlines the development phases for pkm-app, a native macOS menu bar application for Personal Knowledge Management.

## Vision

Create a lightweight, native macOS menu bar app that integrates with a markdown-based PKM vault, providing:
- Quick access to daily notes and goals
- Assistant Hub integration for automated briefings
- Goal hierarchy visualization (3-year → quarterly → monthly)
- Timeline and progress tracking
- Append-only semantics (never overwrite user content)

## Phase 1: Foundation & Menu Bar UI ✅ COMPLETE

**Status:** Complete
**Duration:** Initial scaffolding phase

### Deliverables

- [x] Swift Package Manager project structure
- [x] Menu bar app appears in macOS status bar
- [x] Basic SwiftUI views and AppKit integration
- [x] `PKMApp.swift` - Main entry point (`@main`)
- [x] `AppDelegate.swift` - AppKit app delegate
- [x] `MenuBarController.swift` - Menu bar UI controller
- [x] Basic Views folder structure

### Architecture Decisions

- Menu bar-first design (not window-based)
- SwiftUI for views, AppKit for menu bar integration
- MVVM pattern for state management

---

## Phase 2: Data Models & File Operations 🚧 NEXT

**Status:** Planned
**Estimated Effort:** 20-30 hours

### Goals

Build the data layer and file I/O foundation for PKM integration.

### Deliverables

#### Data Models (`Sources/PKMApp/Models/`)

- [ ] `DailyNote.swift` - Daily note representation with frontmatter
- [ ] `Goal.swift` - Goal hierarchy (3-year → quarterly → monthly)
- [ ] `Project.swift` - Project files with next actions
- [ ] `Section.swift` - Markdown sections within notes

#### Services (`Sources/PKMApp/Services/`)

- [ ] `FileService.swift` (actor) - Thread-safe file read/write operations
- [ ] `FrontmatterParser.swift` - YAML frontmatter parsing using Yams
- [ ] `TemplateService.swift` - Template loading and rendering for new notes

#### Tests (`Tests/PKMAppTests/`)

- [ ] `FileServiceTests.swift` - File I/O edge cases
- [ ] `FrontmatterParserTests.swift` - YAML parsing (empty, malformed, missing)
- [ ] `TemplateServiceTests.swift` - Template rendering

### Implementation Order

1. **FrontmatterParser** - Foundation for all note parsing
2. **FileService** - Core I/O layer (actor-based for thread safety)
3. **Models** - Data shapes for DailyNote, Goal, Project
4. **TemplateService** - Create new notes from templates
5. **Tests** - Comprehensive test coverage

### Key Technical Challenges

- **YAML Frontmatter Preservation**: Parse and serialize without corruption
- **Thread Safety**: Use Swift actors to prevent data races
- **Append-Only Semantics**: Never overwrite existing note content
- **File Watching**: Detect external changes to vault (future enhancement)

### Success Criteria

- Can read daily note with YAML frontmatter
- Can append content to existing note without corruption
- Can create new daily note from template
- All file operations are thread-safe (actor-isolated)
- 90%+ test coverage on services and models

---

## Phase 3: Assistant Hub Integration & Views 📅 FUTURE

**Status:** Planned
**Estimated Effort:** 15-20 hours

### Goals

Integrate with Assistant Hub to display daily briefings in the menu bar app.

### Deliverables

#### Views (`Sources/PKMApp/Views/`)

- [ ] `DailyBriefingView.swift` - Display today's briefing from Assistant Hub
- [ ] `CalendarEventsView.swift` - Show upcoming calendar events
- [ ] `EmailSummaryView.swift` - Show priority emails
- [ ] `SettingsView.swift` - Configure PKM vault path, refresh intervals

#### Integration

- [ ] Read briefing from PKM vault daily note (## Daily Briefing section)
- [ ] Parse markdown sections within notes
- [ ] Display in menu bar dropdown
- [ ] Refresh on-demand or at intervals

### Success Criteria

- Menu bar shows today's briefing from Assistant Hub
- Clicking menu bar icon displays dropdown with events and emails
- Settings allow configuring vault path
- UI updates when daily note is modified externally

---

## Phase 4: Goal Hierarchy & Timeline 📅 FUTURE

**Status:** Planned
**Estimated Effort:** 25-35 hours

### Goals

Visualize goal hierarchy and progress over time.

### Deliverables

#### Views

- [ ] `GoalHierarchyView.swift` - 3-year → quarterly → monthly goal tree
- [ ] `TimelineView.swift` - Visual timeline of goals and milestones
- [ ] `ProgressView.swift` - Goal completion tracking

#### Features

- [ ] Parse goals from goal files (YAML frontmatter + markdown)
- [ ] Visualize goal dependencies and parent-child relationships
- [ ] Show progress toward quarterly and yearly goals
- [ ] Filter by time range (this month, this quarter, this year)

### Success Criteria

- Can visualize 3-year goal hierarchy
- Can see progress toward quarterly goals
- Timeline shows past and future milestones
- Goals are read-only (editing happens in vault)

---

## Phase 5: Advanced Features 📅 BACKLOG

**Status:** Backlog
**Priority:** Low

### Potential Features

- [ ] Quick capture to inbox from menu bar
- [ ] Search vault from menu bar
- [ ] Daily note creation from menu bar
- [ ] Project next actions view
- [ ] Notification for upcoming calendar events
- [ ] Integration with Raycast scripts
- [ ] Export goal progress reports

---

## Integration Architecture

### PKM Ecosystem

pkm-app integrates with two other components:

1. **PKM Vault** (`~/Workspace/Projects/PKM/`)
   - Markdown files with YAML frontmatter
   - Daily notes, goal files, project files
   - Single source of truth for all data

2. **Assistant Hub** (`~/Workspace/Projects/assistant-hub/`)
   - Generates daily briefings (calendar + email + AI summary)
   - Appends to PKM vault daily notes at 6 AM UTC
   - Runs on DigitalOcean droplet via cron

```
┌─────────────────┐
│  Assistant Hub  │ (Python, droplet)
│  (cron 6 AM)    │
└────────┬────────┘
         │ writes
         ▼
┌─────────────────┐
│   PKM Vault     │ (Markdown + YAML)
│ Daily Notes/    │
│ Goals/          │
│ Projects/       │
└────────┬────────┘
         │ reads
         ▼
┌─────────────────┐
│   pkm-app       │ (Swift, macOS)
│  (menu bar)     │
└─────────────────┘
```

### Data Flow

1. **Morning (6 AM UTC)**: Assistant Hub appends briefing to today's daily note
2. **User Opens Menu Bar**: pkm-app reads today's note and displays briefing
3. **User Edits Vault**: pkm-app detects changes (future: file watching)
4. **User Views Goals**: pkm-app parses goal files and displays hierarchy

---

## Dependencies

### Current (Phase 1)

- [Yams](https://github.com/jpsim/Yams) - YAML parsing
- [swift-markdown](https://github.com/apple/swift-markdown) - Markdown parsing (planned)

### Future Considerations

- **File Watching**: Use `FSEvents` or `DispatchSource.makeFileSystemObjectSource()`
- **Markdown Rendering**: Consider [Down](https://github.com/johnxnguyen/Down) or [cmark-gfm](https://github.com/github/cmark-gfm)
- **UI Components**: Explore SwiftUI Charts for timeline visualization

---

## Success Metrics

### Phase 2
- All file operations tested and thread-safe
- Can read/write daily notes without corruption
- YAML frontmatter preserved in all cases

### Phase 3
- Daily briefing visible in menu bar within 1 second of opening
- UI responsive (no blocking on file I/O)
- Settings persist across app restarts

### Phase 4
- Goal hierarchy renders for 50+ goals without performance issues
- Timeline loads in <500ms

---

## Timeline Estimates

| Phase | Effort | Calendar Time |
|-------|--------|---------------|
| Phase 1 (Complete) | 10 hours | 1 week |
| Phase 2 (Next) | 20-30 hours | 2-3 weeks |
| Phase 3 (Future) | 15-20 hours | 1-2 weeks |
| Phase 4 (Future) | 25-35 hours | 3-4 weeks |
| **Total** | **70-95 hours** | **7-10 weeks** |

*Note: Calendar time assumes part-time development (10-15 hours/week)*

---

## Current Focus

**Immediate Next Steps (Phase 2):**

1. Implement `FrontmatterParser.swift` with Yams integration
2. Create `FileService.swift` actor for file I/O
3. Define `DailyNote.swift` model
4. Write comprehensive tests for parsing and I/O
5. Verify append-only semantics with real PKM vault

See `DEVELOPMENT.md` for setup instructions and `README.md` for project overview.

---

## Contributing

Interested in contributing? See `.github/PULL_REQUEST_TEMPLATE.md` for guidelines.

For questions or suggestions about the roadmap, open an issue on GitHub.
