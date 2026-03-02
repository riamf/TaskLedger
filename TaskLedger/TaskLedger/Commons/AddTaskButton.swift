import SwiftUI

struct AddTaskButton: View {
  let action: () -> Void
  var body: some View {
    Button {
      action()
    } label: {
      Image(systemName: "plus")
        .tint(.white)
        .background(.blue)
        .clipShape(Circle())
        .tint(.white)
        .background(Circle().fill(.blue).frame(width: 56, height: 56))
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  AddTaskButton(action: {})
}
    
