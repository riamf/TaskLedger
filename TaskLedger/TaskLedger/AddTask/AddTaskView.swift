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
                            
                            DaySelectionView(viewModel: viewModel)
                        }
                        
                        NotesInputView(notes: $viewModel.notes)
                            .padding(.vertical, .spacingSmall)
                    }
                    .scrollTargetBehavior(.paging)
                    .scrollIndicators(.never)
                    .scrollDisabled(true)
                    
                }.animation(.easeInOut(duration: 0.33), value: viewModel.taskType)
                
                VStack {
                    Spacer()
                    SaveTaskButton {
                        viewModel.saveTask()
                        onAddAction?()
                        dismiss()
                    }
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
}

#Preview {
    AddTaskView()
}
