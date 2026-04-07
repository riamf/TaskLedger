import SwiftUI

struct MoneyInputView: View {
    @Binding var inputTaskName: String
    @Binding var amount: Double
    let amountLabel: LocalizedStringKey

    var body: some View {
        VStack(spacing: 8) {
            Text("task_name_label").padding(.leading, 16).frame(maxWidth: .infinity, alignment: .leading)
                .font(.headline)
            TextField("", text: $inputTaskName, prompt: Text("enter_task_name_prompt"))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 16)
            Text(amountLabel)
                .font(.headline)
                .padding(.leading, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                TextField("", value: $amount, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 16)
                Text(MoneyFormatter.localeCurrencyCode).padding(.trailing, 16)
            }
        }
    }
}

#Preview {
    @Previewable @State var inputTaskName: String = ""
    @Previewable @State var amount: Double = 0.0
    MoneyInputView(inputTaskName: $inputTaskName, amount: $amount, amountLabel: "enter_cost_amount_label")
}
