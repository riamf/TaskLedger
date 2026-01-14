import SwiftUI

struct TaskTypeSwitcherView: View {
    @Binding var taskType: TaskType
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            ForEach(TaskType.allCases, id: \.self) { type in
                Button {
                    self.taskType = type
                } label: {
                    TaskTypeButtonLabel(systemImageName: type == taskType ? type.imageNameMarked : type.imageName, title: type.taskName)
                }
            }
        }
    }
}
