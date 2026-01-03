import SwiftUI

struct TimelineView: View {
    var body: some View {
        VStack {
            Text("Timeline View")
                .font(.title)
            Text("Calendar navigation of daily notes will appear here")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
