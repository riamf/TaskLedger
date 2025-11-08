import SwiftUI

struct RepetingTimeSelectorView: View {
    @State var pattern: RepeatingPattern = .daily(weekdays: [])
    
    var body: some View {
        RepetingSelectorView(repeating: $pattern)
            .tint(.black)
                switch pattern {
                case .daily(let weekdays):
                    DayPicker(values: Weekdays.allCases)
                case .monthly(let day):
                    DayPicker(values: ((0...31).map {
                        DayNumber(number: $0)
                    }))
                case .yearly(let day, let month):
                    HStack {
                        DayPicker(values: ((1...31).map {
                            DayNumber(number: $0)
                        }))
                        DayPicker(values: ((1...12).map {
                            DayNumber(number: $0)
                        }))
                    }
                }
        
    }
}

private struct DayNumber: Hashable, Identifiable, CustomStringConvertible {
    let number: Int
    var id: Int { number }
    var description: String {
        "\(number)"
    }
}

struct DayPicker<T: Hashable & Identifiable>: View {
    @State var values: [T]
    @State private var selected: Set<T> = []

    var body: some View {
        Picker("Select Values", selection: $selected) {
            ForEach(values) { value in
                Text("\(value)").tag(value)
            }
        }
        .pickerStyle(.inline) // Or .segmented, .menu
    }
}

#Preview {
    @Previewable @State var pattern: RepeatingPattern = .daily(weekdays: [])
    RepetingTimeSelectorView(pattern: pattern)
}
