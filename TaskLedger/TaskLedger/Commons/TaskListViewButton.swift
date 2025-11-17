import SwiftUI

struct TaskListViewButton: View {
    
    @Binding var showTasksListView: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Button {
                showTasksListView.toggle()
            } label: {
                Image(systemName: "list.bullet")
                    .tint(.black)
            }
        }
    }
}

#Preview(body: {
    @Previewable @State var showTasksListView: Bool = false
    TaskListViewButton(showTasksListView: $showTasksListView)
})
