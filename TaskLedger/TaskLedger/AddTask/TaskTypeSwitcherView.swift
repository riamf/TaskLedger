import SwiftUI

struct TaskTypeSwitcherView: View {
    @Binding var taskType: TaskType
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Text("Select event type:")
                .fontWeight(.semibold)
                .padding(.vertical, .spacing)
            HStack {
                ForEach(TaskType.allCases, id: \.self) { type in
                    Button {
                        self.taskType = type
                    } label: {
                        TaskTypeButtonLabel(
                            systemImageName: type == taskType ? type.imageNameMarked: type.imageName,
                            title: type.taskName,
                            color: type.color
                        )
                    }.padding(.horizontal, .spacing)
                }
            }
        }
    }
}

#Preview {
    TaskTypeSwitcherView(taskType: .constant(.counter))
        .environment(\.colorScheme, .dark)
}
