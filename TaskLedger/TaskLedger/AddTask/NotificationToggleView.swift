import SwiftUI

struct NotificationToggleView: View {
    @Binding var isEnabled: Bool
    @Binding var notificationTime: Date
    let onToggle: () -> Void

    var body: some View {
        VStack(spacing: .spacingSmall) {
            HStack {
                Image(systemName: isEnabled ? "bell.fill" : "bell.slash")
                    .foregroundColor(isEnabled ? .blue : .gray)
                    .font(.title3)

                Text("notification_toggle_label")
                    .font(.headline)

                Spacer()

                Toggle("", isOn: Binding(
                    get: { isEnabled },
                    set: { _ in onToggle() }
                ))
                .labelsHidden()
            }

            if isEnabled {
                HStack {
                    Text("notification_time_label")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    DatePicker(
                        "",
                        selection: $notificationTime,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .animation(.easeInOut(duration: 0.25), value: isEnabled)
    }
}

#Preview {
    @Previewable @State var enabled = false
    @Previewable @State var time = Date()
    NotificationToggleView(isEnabled: $enabled, notificationTime: $time) {
        enabled.toggle()
    }
    .padding()
}
