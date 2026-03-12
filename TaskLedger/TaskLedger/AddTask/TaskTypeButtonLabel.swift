import SwiftUI

struct TaskTypeButtonLabel: View {
    @Environment(\.colorScheme) var colorScheme
    let systemImageName: String
    let title: String
    let summary: String
    let color: Color
    var body: some View {
        VStack {
            Image(systemName: systemImageName)
                .tint(colorScheme == .light ? .black : .white)
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(color, lineWidth: 5)
                )
            Text(title).tint(colorScheme == .light ? .black : .white)
                .font(Font.system(.caption))
                .multilineTextAlignment(.center)
                .padding(.top, .spacingSmall)
            Text(summary).tint(colorScheme == .light ? .black : .white)
                .font(Font.system(.caption))
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    let task = EventTask.example()
    TaskTypeButtonLabel(systemImageName: task.taskType.imageName, title: task.name, summary: task.taskType.summary, color: task.taskType.color)
}
