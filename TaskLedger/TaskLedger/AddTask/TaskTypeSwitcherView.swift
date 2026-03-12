import SwiftUI

struct TaskTypeSwitcherView: View {
    @Binding var taskType: TaskType
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Text("Select event type:")
                .fontWeight(.semibold)
                .padding(.vertical, .spacing)
            HStack(alignment: .top, spacing: .spacingSmall) {
                ForEach(TaskType.allCases, id: \.self) { type in
                    Button {
                        self.taskType = type
                    } label: {
                        TaskTypeButtonLabel(
                            systemImageName: type == taskType ? type.imageNameMarked: type.imageName,
                            title: type.taskName,
                            summary: type.summary,
                            color: taskType == type ? type.color : type.color.opacity(0.5)
                        )
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

#Preview {
    TaskTypeSwitcherView(taskType: .constant(.counter))
        .environment(\.colorScheme, .dark)
}
