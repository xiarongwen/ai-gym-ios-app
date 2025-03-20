import SwiftUI

struct HistoryView: View {
    var body: some View {
        FadeInView {
            VStack {
                Text("历史页面")
                    .font(.largeTitle)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemBackground))
        }
    }
}

#Preview {
    HistoryView()
} 