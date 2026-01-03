import SwiftUI

struct TodayView: View {
    var body: some View {
        VStack {
            Text("Today View")
                .font(.title)
            Text("Quick capture, daily note preview, and current goals will appear here")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
