import SwiftUI

struct ButtonArrowLeft: View {
    @Environment(\.colorScheme) var colorScheme
    let action: () -> Void
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "chevron.left").tint(colorScheme == .light ? .black : .white)
        }.background(Color.clear)
    }
    
}
