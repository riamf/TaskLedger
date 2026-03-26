import SwiftUI

enum TaskFrequencies: String, CaseIterable {
    case weekly
    case monthly
    case oneTime
    case daily
    
    var title: String {
        switch self {
        case .oneTime: return String(localized: "frequency_one_time")
        case .daily: return String(localized: "frequency_daily")
        case .weekly: return String(localized: "frequency_weekly")
        case .monthly: return String(localized: "frequency_monthly")
        }
    }
}

struct FrequencySwitcher: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selection: TaskFrequencies
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(TaskFrequencies.allCases, id: \.self) { frequency in
                Button {
                    selection = frequency
                } label: {
                    Text(frequency.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(
                            selection == frequency
                            ? (colorScheme == .light ? Color.black : Color.white)
                            : (colorScheme == .light ? Color.gray.opacity(0.2) : Color.white.opacity(0.2))
                        )
                        .foregroundColor(
                            selection == frequency
                            ? (colorScheme == .light ? .white : .black)
                            : .primary
                        )
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    FrequencySwitcher(selection: .constant(.weekly))
}
