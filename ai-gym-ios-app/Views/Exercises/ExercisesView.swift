import SwiftUI

struct ExercisesView: View {
    @StateObject private var viewModel = ExerciseViewModel()
    
    var body: some View {
        FadeInView {
            NavigationView {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.exercises) { exercise in
                            ExerciseCard(exercise: exercise)
                                .padding(.horizontal)
                                .onAppear {
                                    if exercise.id == viewModel.exercises.last?.id {
                                        Task {
                                            await viewModel.fetchExercises()
                                        }
                                    }
                                }
                        }
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                }
                .refreshable {
                    await viewModel.refresh()
                }
                .navigationTitle("训练动作库")
                .background(Color(UIColor.systemGroupedBackground))
            }
        }
        .task {
            if viewModel.exercises.isEmpty {
                await viewModel.fetchExercises()
            }
        }
        .alert("加载失败", isPresented: .constant(viewModel.error != nil)) {
            Button("重试") {
                Task {
                    await viewModel.refresh()
                }
            }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
    }
}

#Preview {
    ExercisesView()
} 