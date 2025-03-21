import SwiftUI

struct ExerciseCard: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 图片
            let imageUrl = exercise.gifUrl
         

            AsyncImage(url: URL(string: imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(height: 200)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                        .cornerRadius(10)
                case .failure(let error):
                    VStack {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                        Text("加载失败")
                            .font(.caption)
                        Text(error.localizedDescription)
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                    .frame(height: 200)
                @unknown default:
                    EmptyView()
                }
            }
            
            // 动作信息
            VStack(alignment: .leading, spacing: 8) {
                Text(exercise.name)
                    .font(.headline)
                
                HStack {
                    Tag(text: exercise.formattedBodyPart, color: .blue)
                    Tag(text: exercise.formattedTarget, color: .green)
                    Tag(text: exercise.formattedEquipment, color: .orange)
                }
                
                if !exercise.instructions.isEmpty {
                    Text(exercise.instructions[0])
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct Tag: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(8)
    }
} 
