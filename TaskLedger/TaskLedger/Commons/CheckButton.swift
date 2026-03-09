import SwiftUI

struct CheckButton<T>: View {
    @Environment(\.colorScheme) var colorScheme
    var title: String
    var isChecked: Bool
    var value: T
    var action: ((T) -> Void)
    
    var body: some View {
        Button {
            action(value)
        } label: {
            if isChecked {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.secondary)
                    Text(title)
                        .strikethrough()
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "circle")
                    Text(title)
                        .fontWeight(.regular)
                        .lineLimit(1)
                }.tint(colorScheme == .light ? .black : .white)
            }
        }
    }
}
