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
            if colorScheme == .light {
                Image(systemName: "chevron.right").tint(.black)
            } else {
                Image(systemName: "chevron.right").tint(.white)
            }
        }
    }
}

#Preview {
    ButtonArrowRight(action: {})
        
}
