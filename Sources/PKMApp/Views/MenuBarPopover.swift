import SwiftUI

struct MenuBarPopover: View {
    @State private var selectedTab: Tab = .today

    enum Tab {
        case today, timeline, search, appleNotes
    }

    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            HStack(spacing: 0) {
                TabButton(
                    icon: "house.fill",
                    title: "Today",
                    isSelected: selectedTab == .today
                ) {
                    selectedTab = .today
                }

                TabButton(
                    icon: "calendar",
                    title: "Timeline",
                    isSelected: selectedTab == .timeline
                ) {
                    selectedTab = .timeline
                }

                TabButton(
                    icon: "magnifyingglass",
                    title: "Search",
                    isSelected: selectedTab == .search
                ) {
                    selectedTab = .search
                }

                TabButton(
                    icon: "note.text",
                    title: "Notes",
                    isSelected: selectedTab == .appleNotes
                ) {
                    selectedTab = .appleNotes
                }
            }
            .frame(height: 44)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Content area
            Group {
                switch selectedTab {
                case .today:
                    TodayView()
                case .timeline:
                    TimelineView()
                case .search:
                    SearchView()
                case .appleNotes:
                    AppleNotesView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 480, height: 640)
    }
}

struct TabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(isSelected ? .accentColor : .secondary)
        }
        .buttonStyle(.plain)
    }
}
