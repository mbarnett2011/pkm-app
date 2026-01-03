import SwiftUI

struct SearchView: View {
    var body: some View {
        VStack {
            Text("Search View")
                .font(.title)
            Text("Full-text vault search will appear here")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
