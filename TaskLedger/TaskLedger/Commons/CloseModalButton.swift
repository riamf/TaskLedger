import SwiftUI

struct CloseModalButton: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            HStack(spacing: 4) {
                Image("close").tint(.black)
                Text("Cancel").foregroundStyle(.black)
            }
        }
    }
}
