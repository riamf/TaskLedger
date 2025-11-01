import SwiftUI

final class TaskListViewButtonViewModel: ObservableObject {
  @Published var showTasksListView: Bool
  
  init(showTasksListView: Bool) {
    self.showTasksListView = showTasksListView
  }
}

struct TaskListViewButton: View {
  
  @StateObject var viewModel: TaskListViewButtonViewModel
  
  init(showTasksListView: Bool) {
    _viewModel = StateObject(
      wrappedValue: TaskListViewButtonViewModel(showTasksListView: showTasksListView)
    )
  }
  
  var body: some View {
    HStack(spacing: 16) {
      Button {
        viewModel.showTasksListView.toggle()
      } label: {
        Image(systemName: "list.bullet")
          .tint(.black)
      }
    }
  }
}

#Preview(body: {
  TaskListViewButton(showTasksListView: true)
})
