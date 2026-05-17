import SwiftUI

struct TaskTypeSwitcherView: View {
    @Binding var taskType: TaskType
    
    var body: some View {
        VStack {
            Text("select_event_type_label")
                .fontWeight(.semibold)
                .padding(.vertical, .spacing)
            HStack(alignment: .top, spacing: .spacingSmall) {
                ForEach(TaskType.allCases, id: \.self) { type in
                    Button {
                        self.taskType = type
                    } label: {
                        TaskTypeButtonLabel(
                            taskType: type,
                            isSelected: taskType == type
                        )
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .contentShape(RoundedRectangle(cornerRadius: 18))
                    .accessibilityAddTraits(taskType == type ? [.isSelected] : [])
                    .accessibilityIdentifier("add-task-type-\(type.rawValue)")
                }
            }
        }
    }
}

#Preview {
    TaskTypeSwitcherView(taskType: .constant(.counter))
        .environment(\.colorScheme, .dark)
}
