import SwiftUI

struct DaySelectionView: View {
    @ObservedObject var viewModel: AddTaskViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacing) {
            Text("Repeats on:")
                .fontWeight(.semibold)
                .padding(.spacing)
            
            let columns = [
                GridItem(.adaptive(minimum: 80))
            ]
            
            LazyVGrid(columns: columns, spacing: .spacing) {
                ForEach(Weekdays.allCases, id: \.self) { day in
                    createDayCircle(day)
                        .tint(day == .saturday || day == .sunday ? .red : .primary)
                }
            }
            .padding(.horizontal, .spacing)
        }
    }
    
    private func createDayCircle(_ day: Weekdays) -> some View {
        let isSelected = viewModel.isDaySelected(day)
        let isWeekend = day == .saturday || day == .sunday
        let activeColor: Color = isWeekend ? .red : (colorScheme == .light ? .black : .white)
        
        return Button(action: {
            if isSelected {
                viewModel.deselectDay(day)
            } else {
                viewModel.selectDay(day)
            }
        }) {
            ZStack {
                Circle()
                    .fill(isSelected ? activeColor : Color.clear)
                    .stroke(activeColor, lineWidth: 2)
                
                Text(String(day.stringName.prefix(3)))
                    .font(.caption)
                    .bold()
                    .foregroundColor(isSelected ? (colorScheme == .light ? .white : .black) : activeColor)
            }
            .frame(width: 40, height: 40)
        }
    }
}

#Preview {
    DaySelectionView(viewModel: AddTaskViewModel())
}
