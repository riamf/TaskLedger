import SwiftUI

struct AddTaskButton: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPulsing = false

    var showsOnboardingPulse: Bool = false
    let action: () -> Void

    private let buttonSize: CGFloat = 68

    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        if showsOnboardingPulse {
                            Circle()
                                .fill(Color.blue.opacity(colorScheme == .light ? 0.14 : 0.2))
                                .blur(radius: isPulsing ? 14 : 6)
                                .scaleEffect(isPulsing ? 1.08 : 0.98)
                        }
                    }
                
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
        .overlay {
            if showsOnboardingPulse {
                Circle()
                    .stroke(Color.blue.opacity(colorScheme == .light ? 0.28 : 0.36), lineWidth: 2)
                    .scaleEffect(isPulsing ? 1.32 : 1.02)
                    .opacity(isPulsing ? 0 : 0.75)
                    .allowsHitTesting(false)
            }
        }
        .accessibilityLabel("Add task")
        .accessibilityIdentifier("day-view-add-task-button")
        .buttonStyle(ModernAddTaskButtonStyle())
        .onAppear {
            updatePulseAnimation()
        }
        .onChange(of: showsOnboardingPulse) { _, _ in
            updatePulseAnimation()
        }
    }

    private func updatePulseAnimation() {
        guard showsOnboardingPulse else {
            isPulsing = false
            return
        }

        isPulsing = false
        withAnimation(.easeOut(duration: 1.8).repeatForever(autoreverses: false)) {
            isPulsing = true
        }
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

#Preview("Light - Pulse") {
    ZStack {
        Color.blue.opacity(0.1).ignoresSafeArea()
        AddTaskButton(showsOnboardingPulse: true, action: {})
    }
}

#Preview("Dark") {
    ZStack {
        Color.black.ignoresSafeArea()
        AddTaskButton(action: {})
    }
    .preferredColorScheme(.dark)
}
