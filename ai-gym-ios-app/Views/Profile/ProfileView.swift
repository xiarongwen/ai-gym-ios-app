import SwiftUI

struct ProfileView: View {
    var body: some View {
        FadeInView {
            VStack {
                Text("我的页面")
                    .font(.largeTitle)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemBackground))
        }
    }
}

#Preview {
    ProfileView()
} 