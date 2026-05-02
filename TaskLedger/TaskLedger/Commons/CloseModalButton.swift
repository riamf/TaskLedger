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
                Image("close")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                Text("cancel_button_title")
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .foregroundStyle(colorScheme == .light ? .black : .white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(colorScheme == .light ? 0.6 : 0.3),
                                Color.white.opacity(colorScheme == .light ? 0.2 : 0.05),
                                Color.gray.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: .black.opacity(colorScheme == .light ? 0.08 : 0.2), radius: 8, x: 0, y: 4)
            .fixedSize(horizontal: true, vertical: false)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CloseModalButton()
}
