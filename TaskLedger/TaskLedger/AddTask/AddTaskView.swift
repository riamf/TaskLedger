import SwiftData
import SwiftUI

struct AddTaskView: View {
    @Environment(\.colorScheme) var colorScheme
    var onAddAction: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = AddTaskViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: .spacing) {
                HStack(spacing: .spacing) {
                    HStack(spacing: .spacing) {
                        CloseModalButton()
                        Spacer()
                    }
                }.padding(.vertical, .bigSpacing).padding(.horizontal, .spacing)
                VStack(spacing: .spacingSmall) {
                    VStack(spacing: 8) {
                        ScrollViewReader { proxy in
                            TaskTypeSwitcherView(taskType: $viewModel.taskType).padding(.horizontal, 16)
                                .onChange(of: viewModel.taskType) { _, newValue in
                                    withAnimation {
                                        proxy.scrollTo(viewModel.taskType.number,
                                                       anchor: .center)
                                    }
                                }
                            ScrollView(.horizontal) {
                                HStack {
                                    CounterInputView(inputTaskName: $viewModel.inputTaskName)
                                        .frame(width: UIScreen.main.bounds.width - .spacingSmall)
                                        .id(TaskType.counter.number)
                                    CostInputView(inputTaskName: $viewModel.inputTaskName,
                                                  amount: $viewModel.amount)
                                    .frame(width: UIScreen.main.bounds.width - .spacingSmall )
                                    .id(TaskType.cost.number)
                                    IncomeInputView(inputTaskName: $viewModel.inputTaskName,
                                                    amount: $viewModel.amount)
                                    .frame(width: UIScreen.main.bounds.width - .spacingSmall)
                                    .id(TaskType.income.number)
                                    TimeInputView(
                                        inputTaskName: $viewModel.inputTaskName,
                                        hours: $viewModel.timeHours,
                                        minutes: $viewModel.timeMinutes,
                                        seconds: $viewModel.timeSeconds
                                    )
                                    .frame(width: UIScreen.main.bounds.width - .spacingSmall)
                                    .id(TaskType.time.number)
                                }
                            }
                            let columns = [
                                GridItem(.adaptive(minimum: 80))
                            ]
                            Text("Repeats on:").fontWeight(.semibold).padding(.vertical, .spacing)
                            LazyVGrid(columns: columns, spacing: .spacing) {
                                ForEach(Weekdays.allCases, id: \.self) { day in
                                    createDayCircle(day)
                                        .tint(day == .saturday || day == .sunday ? .red : .primary)
                                }
                            }
                            .padding(.horizontal, .spacing)
                        }
                        HStack {
                            Text("Task Notes:")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.spacing)
                        TextField("",
                                  text: $viewModel.notes,
                                  prompt: Text("Enter notes here..."),
                                  axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3, reservesSpace: true)
                        .padding(.horizontal, .spacing)
                        .padding(.vertical, .spacingSmall)
                        
                        
                    }
                    .scrollTargetBehavior(.paging)
                    .scrollIndicators(.never)
                    .scrollDisabled(true)
                    
                }.animation(.easeInOut(duration: 0.33), value: viewModel.taskType)
                
                VStack {
                    Spacer()
                    Button {
                        viewModel.saveTask()
                        onAddAction?()
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "square.and.arrow.down.on.square")
                            Spacer()
                        }
                        .tint(colorScheme == .light ? .black : .white)
                        
                    }
                    .frame(height: 44)
                    .cornerRadius(8)
                    .overlay( /// apply a rounded border
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(colorScheme == .light ? .black : .white, lineWidth: 2)
                    )
                    .padding(.horizontal, 16)
                }
            }
            Spacer()
        }
        .scrollDismissesKeyboard(.immediately)
        .alert(isPresented: $viewModel.saveAlert) {
            Alert(
                title: Text("Error"),
                message: Text("Failed to save task. Please try again."),
                dismissButton: .default(Text("OK"))
            )
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
    
    private func createDayCheckmark(_ day: Weekdays) -> some View {
        return CheckButton<Weekdays>(
            title: day.stringName,
            isChecked: viewModel.isDaySelected(day),
            value: day) { selected in
                if viewModel.isDaySelected(selected) {
                    viewModel.deselectDay(selected)
                } else {
                    viewModel.selectDay(selected)
                }
            }
    }
}

#Preview {
    AddTaskView()
}
