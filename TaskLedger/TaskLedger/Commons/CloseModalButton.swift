import SwiftUI

struct CloseModalButton: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    let dayNames = Calendar.current.weekdaySymbols
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            HStack(spacing: 4) {
                Image("close").renderingMode(.template).tint(colorScheme == .light ? .black : .white)
                Text("Cancel").foregroundStyle(colorScheme == .light ? .black : .white)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CloseModalButton()
}
