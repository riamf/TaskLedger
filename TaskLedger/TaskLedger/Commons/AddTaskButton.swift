import SwiftUI

struct AddTaskButton: View {
    @Environment(\.colorScheme) private var colorScheme

    let action: () -> Void

    private let buttonSize: CGFloat = 68

    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(colorScheme == .light ? 0.6 : 0.3),
                                Color.white.opacity(colorScheme == .light ? 0.2 : 0.05),
                                Color.blue.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )

                Image(systemName: "plus")
                    .font(.system(size: 26, weight: .semibold, design: .rounded))
                    .foregroundStyle(.blue)
            }
            .frame(width: buttonSize, height: buttonSize)
            .shadow(color: .black.opacity(colorScheme == .light ? 0.08 : 0.2), radius: 8, x: 0, y: 4)
            .contentShape(Circle())
        }
        .accessibilityLabel("Add task")
        .buttonStyle(ModernAddTaskButtonStyle())
    }
}

private struct ModernAddTaskButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.9), value: configuration.isPressed)
    }
}

#Preview("Light") {
    ZStack {
        Color.blue.opacity(0.1).ignoresSafeArea()
        AddTaskButton(action: {})
    }
}

#Preview("Dark") {
    ZStack {
        Color.black.ignoresSafeArea()
        AddTaskButton(action: {})
    }
    .preferredColorScheme(.dark)
}
