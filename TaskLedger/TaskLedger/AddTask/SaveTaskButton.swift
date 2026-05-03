import SwiftUI

struct SaveTaskButton: View {
    var isEnabled: Bool = true
    var onSave: () -> Void
    
    var body: some View {
        Button {
            onSave()
        } label: {
            HStack {
                Spacer()
                Text("save_button_title")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                Spacer()
            }
            .frame(height: 50)
            .glassPillButtonChrome(cornerRadius: 25, horizontalPadding: 0, verticalPadding: 0)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1 : 0.45)
        .padding(.horizontal, 16)
    }
}

#Preview {
    SaveTaskButton(onSave: {})
}
