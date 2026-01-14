import SwiftUI

struct TaskTypeButtonLabel: View {
    @Environment(\.colorScheme) var colorScheme
    let systemImageName: String
    let title: String
    var body: some View {
        VStack {
            Image(systemName: systemImageName).tint(colorScheme == .light ? .black : .white)
            Text(title).tint(colorScheme == .light ? .black : .white).font(Font.system(.caption))
        }
    }
}

