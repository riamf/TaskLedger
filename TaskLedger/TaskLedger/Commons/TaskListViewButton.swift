import SwiftUI

struct TaskListViewButton: View {
  var body: some View {
    HStack(spacing: 16) {
      Button {
        //        showTasksListView.toggle()
      } label: {
        Image(systemName: "list.bullet")
          .tint(.black)
      }
    }
  }
}


#Preview(body: {
  TasksListView()
})
