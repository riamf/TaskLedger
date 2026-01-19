import SwiftUI

struct TaskTypeCircleIcon: View {
    let task: EventTask
    
    var body: some View {
        Image(systemName: task.taskType.imageName)
            .frame(width: 44, height: 44)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(task.taskType.color, lineWidth: 5)
            )
    }
}


#Preview {
    TaskTypeCircleIcon(task: EventTask.example(.counter))
}
