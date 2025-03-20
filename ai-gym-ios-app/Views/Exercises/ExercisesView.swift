import SwiftUI

struct ExercisesView: View {
    var body: some View {
        FadeInView {
            VStack {
                Text("动作页面")
                    .font(.largeTitle)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemBackground))
        }
    }
}

#Preview {
    ExercisesView()
} 