import SwiftUI

struct CounterInputView: View {
    @Binding var inputTaskName: String
    var body: some View {
        VStack(spacing: 8) {
            Text("task_name_label").padding(.leading, 16).frame(maxWidth: .infinity, alignment: .leading)
                .font(.headline)
            TextField("", text: $inputTaskName, prompt: Text("enter_task_name_prompt"))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 16)
        }
    }
}
