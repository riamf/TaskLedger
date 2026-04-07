import SwiftUI

struct CostInputView: View {
    @Binding var inputTaskName: String
    @Binding var amount: Double

    var body: some View {
        MoneyInputView(
            inputTaskName: $inputTaskName,
            amount: $amount,
            amountLabel: "enter_cost_amount_label"
        )
    }
}

#Preview {
    @Previewable @State var inputTaskName: String = ""
    @Previewable @State var amount: Double = 0.0
    CostInputView(inputTaskName: $inputTaskName, amount: $amount)
}
