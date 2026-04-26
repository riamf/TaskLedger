import SwiftUI

struct TaskTypeButtonLabel: View {
    @Environment(\.colorScheme) var colorScheme
    let taskType: TaskType
    let isSelected: Bool

    var body: some View {
        VStack(spacing: .spacingSmall) {
            TaskTypeCircleIcon(
                taskType: taskType,
                systemImageName: isSelected ? taskType.imageNameMarked : taskType.imageName,
                iconColor: isSelected ? taskType.color : (colorScheme == .light ? .black : .white),
                size: 48,
                strokeOpacity: isSelected ? 1 : 0.45,
                lineWidth: isSelected ? 5 : 3
            )

            Text(taskType.taskName)
                .foregroundStyle(colorScheme == .light ? .black : .white)
                .font(.caption.weight(.semibold))
                .multilineTextAlignment(.center)

            Text(taskType.summary)
                .foregroundStyle((colorScheme == .light ? Color.black : Color.white).opacity(isSelected ? 0.8 : 0.65))
                .font(.caption2)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 128, alignment: .top)
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(isSelected ? taskType.color.opacity(colorScheme == .light ? 0.14 : 0.18) : Color(UIColor.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    isSelected ? taskType.color.opacity(0.95) : Color.primary.opacity(colorScheme == .light ? 0.12 : 0.22),
                    lineWidth: isSelected ? 2 : 1
                )
        )
        .shadow(
            color: isSelected ? taskType.color.opacity(colorScheme == .light ? 0.16 : 0.22) : .black.opacity(colorScheme == .light ? 0.04 : 0.1),
            radius: isSelected ? 8 : 4,
            x: 0,
            y: isSelected ? 4 : 2
        )
    }
}

#Preview {
    let task = EventTask.example()
    TaskTypeButtonLabel(
        taskType: task.taskType,
        isSelected: true
    )
}
