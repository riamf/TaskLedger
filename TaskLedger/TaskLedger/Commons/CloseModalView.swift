import SwiftUI

struct CloseModalView: View {
    @Environment(\.colorScheme) var colorScheme
    
    private var dismiss: DismissAction
    
    init(dismiss: DismissAction) {
        self.dismiss = dismiss
    }
    
    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 16) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image("close").tint(colorScheme == .light ? .black : .white)
                        Text("cancel_button_title").foregroundStyle(colorScheme == .light ? .black : .white)
                    }
                }
                Spacer()
            }
        }
    }
}
