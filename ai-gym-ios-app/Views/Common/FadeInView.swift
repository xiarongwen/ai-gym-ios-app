import SwiftUI

struct FadeInView<Content: View>: View {
    var content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        content()
            .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.3)))
    }
}

#Preview {
    FadeInView {
        Text("测试淡入淡出效果")
    }
} 