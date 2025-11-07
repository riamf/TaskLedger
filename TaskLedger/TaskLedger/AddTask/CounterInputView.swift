import SwiftUI

struct CounterInputView: View {
    @Binding var inputTaskName: String
    var body: some View {
        VStack(spacing: 8) {
            Text("Task name:").padding(.leading, 16).frame(maxWidth: .infinity, alignment: .leading)
            TextField("", text: $inputTaskName, prompt: Text("Enter task name"))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 16)
        }
    }
}
