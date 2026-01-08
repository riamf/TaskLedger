import SwiftUI

struct ButtonArrowRight: View {
    @Environment(\.colorScheme) var colorScheme
    let action: () -> Void
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "chevron.right").tint(colorScheme == .dark ? .white : .black)
        }.background(Color.clear)
    }
}

#Preview {
    ButtonArrowRight(action: {})
}
