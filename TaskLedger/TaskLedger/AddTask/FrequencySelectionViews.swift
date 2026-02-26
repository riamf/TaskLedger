import SwiftUI

struct WeeklySelectionView: View {
    @ObservedObject var viewModel: AddTaskViewModel
    
    var body: some View {
        DaySelectionView(viewModel: viewModel)
    }
}

struct MonthlySelectionView: View {
    @ObservedObject var viewModel: AddTaskViewModel
    @State private var visibleMonth = Date()
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacing) {
            Text("Repeats on day:")
                .fontWeight(.semibold)
                .padding(.horizontal, .spacing)
                .padding(.top, .spacing)
            
            CalendarMonthView(visibleMonth: $visibleMonth) { date in
                let day = Calendar.current.component(.day, from: date)
                CalendarDayButton(
                    dayNumber: day,
                    isSelected: viewModel.selectedDayOfMonth == day,
                    color: nil
                ) {
                    viewModel.selectedDayOfMonth = day
                }
            }
            .padding(.horizontal, .spacing)
        }
    }
}

struct OneTimeSelectionView: View {
    @ObservedObject var viewModel: AddTaskViewModel
    @State private var visibleMonth = Date()
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacing) {
            Text("Select Date:")
                .fontWeight(.semibold)
                .padding(.horizontal, .spacing)
                .padding(.top, .spacing)
            
            CalendarMonthView(visibleMonth: $visibleMonth) { date in
                let day = Calendar.current.component(.day, from: date)
                CalendarDayButton(
                    dayNumber: day,
                    isSelected: Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate),
                    color: nil
                ) {
                    viewModel.selectedDate = date
                }
            }
            .padding(.horizontal, .spacing)
        }
        .onAppear {
            visibleMonth = viewModel.selectedDate
        }
    }
}
