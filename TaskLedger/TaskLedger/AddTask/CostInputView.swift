import SwiftUI

struct CostInputView: View {
    @Binding var inputTaskName: String
    @Binding var amount: Double
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Task name:").padding(.leading, 16).frame(maxWidth: .infinity, alignment: .leading)
            TextField("", text: $inputTaskName, prompt: Text("Enter task name"))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 16)
            Text("Enter cost amount:")
                .padding(.leading, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("", value: $amount, format: .number)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 16)
        }
    }
}

#Preview {
    @Previewable @State var inputTaskName: String = ""
    @Previewable @State var amount: Double = 0.0
    CostInputView(inputTaskName: $inputTaskName, amount: $amount)
}
