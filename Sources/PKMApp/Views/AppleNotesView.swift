import SwiftUI

struct AppleNotesView: View {
    var body: some View {
        VStack {
            Text("Apple Notes")
                .font(.title)
            Text("Side-by-side Apple Notes search will appear here")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
