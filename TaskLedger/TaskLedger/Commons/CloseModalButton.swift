import SwiftUI

struct CloseModalButton: View {
    @Environment(\.dismiss) private var dismiss
    
    let dayNames = Calendar.current.weekdaySymbols
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            HStack(spacing: 4) {
                Image("close").renderingMode(.template)
                Text("cancel_button_title")
            }
            .glassPillButtonChrome(accentColor: .gray)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CloseModalButton()
}
