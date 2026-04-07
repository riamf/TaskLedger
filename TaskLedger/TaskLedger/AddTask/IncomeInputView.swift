import SwiftUI

struct IncomeInputView: View {
    @Binding var inputTaskName: String
    @Binding var amount: Double

    var body: some View {
        MoneyInputView(
            inputTaskName: $inputTaskName,
            amount: $amount,
            amountLabel: "enter_income_amount_label"
        )
    }
}

#Preview {
    @Previewable @State var inputTaskName: String = ""
    @Previewable @State var amount: Double = 0.0
    IncomeInputView(inputTaskName: $inputTaskName, amount: $amount)
}
