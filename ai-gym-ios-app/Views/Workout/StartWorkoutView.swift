import SwiftUI

struct StartWorkoutView: View {
    var body: some View {
        FadeInView {
            VStack {
                Text("开始训练页面")
                    .font(.largeTitle)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemBackground))
        }
    }
}

#Preview {
    StartWorkoutView()
} 