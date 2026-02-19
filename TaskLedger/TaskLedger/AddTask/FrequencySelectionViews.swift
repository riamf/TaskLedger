import SwiftUI

struct WeeklySelectionView: View {
    @ObservedObject var viewModel: AddTaskViewModel
    
    var body: some View {
        DaySelectionView(viewModel: viewModel)
    }
}

struct MonthlySelectionView: View {
    @ObservedObject var viewModel: AddTaskViewModel
    
    let days = Array(1...31)
    let columns = [GridItem(.adaptive(minimum: 40))]
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacing) {
            Text("Repeats on day:")
                .fontWeight(.semibold)
                .padding(.horizontal, .spacing)
                .padding(.top, .spacing)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(days, id: \.self) { day in
                    Button {
                        viewModel.selectedDayOfMonth = day
                    } label: {
                        Text("\(day)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(viewModel.selectedDayOfMonth == day ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(viewModel.selectedDayOfMonth == day ? .white : .primary)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, .spacing)
        }
    }
}

struct OneTimeSelectionView: View {
    @ObservedObject var viewModel: AddTaskViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacing) {
            Text("Select Date:")
                .fontWeight(.semibold)
                .padding(.horizontal, .spacing)
                .padding(.top, .spacing)
            
            DatePicker(
                "Select Date",
                selection: $viewModel.selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .padding(.horizontal, .spacing)
        }
    }
}
