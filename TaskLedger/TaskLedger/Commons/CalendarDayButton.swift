import SwiftUI

struct CalendarDayButton: View {
    let dayNumber: Int
    let isSelected: Bool
    let color: Color?
    let action: (() -> Void)?
    
    var body: some View {
        Button {
            action?()
        } label: {
            Text("\(dayNumber)")
                .font(.subheadline)
                .fontWeight(isSelected || color != nil ? .bold : .regular)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(backgroundView)
                .foregroundColor(foregroundColor)
                .clipShape(Circle())
        }
        .disabled(action == nil)
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        if isSelected {
            Color.blue
        } else if let color = color {
            color
        } else {
            Color.clear
        }
    }
    
    private var foregroundColor: Color {
        if isSelected || color != nil {
            return .white
        } else {
            return .primary
        }
    }
}

#Preview {
    HStack {
        CalendarDayButton(dayNumber: 5, isSelected: false, color: nil, action: {})
        CalendarDayButton(dayNumber: 5, isSelected: true, color: nil, action: {})
        CalendarDayButton(dayNumber: 5, isSelected: false, color: .red, action: {})
    }
}
