import SwiftUI

struct SaveTaskButton: View {
    var onSave: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button {
            onSave()
        } label: {
            HStack {
                Spacer()
                Image(systemName: "square.and.arrow.down.on.square")
                Spacer()
            }
            .tint(colorScheme == .light ? .black : .white)
        }
        .frame(height: 44)
        .buttonStyle(.plain)
        .cornerRadius(8)
        .overlay( /// apply a rounded border
            RoundedRectangle(cornerRadius: 20)
                .stroke(colorScheme == .light ? .black : .white, lineWidth: 2)
        )
        .padding(.horizontal, 16)
    }
}

#Preview {
    SaveTaskButton(onSave: {})
}
