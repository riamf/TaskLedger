import SwiftUI

struct ButtonArrowLeft: View {
    let action: () -> Void
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "chevron.left").tint(.black)
        }.background(Color.clear)
    }
    
}
