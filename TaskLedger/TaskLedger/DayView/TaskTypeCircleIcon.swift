import SwiftUI

struct TaskTypeCircleIcon: View {
    let taskType: TaskType
    let systemImageName: String
    let iconColor: Color?
    let size: CGFloat
    let strokeOpacity: Double
    let lineWidth: CGFloat

    init(
        task: EventTask,
        systemImageName: String? = nil,
        iconColor: Color? = nil,
        size: CGFloat = 44,
        strokeOpacity: Double = 1,
        lineWidth: CGFloat = 5
    ) {
        self.init(
            taskType: task.taskType,
            systemImageName: systemImageName ?? task.taskType.imageName,
            iconColor: iconColor,
            size: size,
            strokeOpacity: strokeOpacity,
            lineWidth: lineWidth
        )
    }

    init(
        taskType: TaskType,
        systemImageName: String? = nil,
        iconColor: Color? = nil,
        size: CGFloat = 44,
        strokeOpacity: Double = 1,
        lineWidth: CGFloat = 5
    ) {
        self.taskType = taskType
        self.systemImageName = systemImageName ?? taskType.imageName
        self.iconColor = iconColor
        self.size = size
        self.strokeOpacity = strokeOpacity
        self.lineWidth = lineWidth
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(taskType.color.opacity(strokeOpacity), lineWidth: lineWidth)

            Image(systemName: systemImageName)
                .foregroundStyle(iconColor ?? .primary)
                .font(.system(size: size * 0.38, weight: .semibold))
        }
        .frame(width: size, height: size)
    }
}


#Preview {
    TaskTypeCircleIcon(task: EventTask.example())
}
