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
                }.padding(.top, .bigSpacing).padding(.horizontal, .spacing)
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
                            FrequencySwitcher(selection: $viewModel.taskFrequency.animation())
                            Group {
                                switch viewModel.taskFrequency {
                                case .weekly:
                                    WeeklySelectionView(viewModel: viewModel)
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .leading).combined(with: .opacity)
                                        ))
                                case .monthly:
                                    MonthlySelectionView(viewModel: viewModel)
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .leading).combined(with: .opacity)
                                        ))
                                case .oneTime:
                                    OneTimeSelectionView(viewModel: viewModel)
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .leading).combined(with: .opacity)
                                        ))
                                case .daily:
                                    Text("add_task_daily_repeat_message")
                                        .font(.headline)
                                        .padding(.vertical, .spacing)
                                        .frame(maxWidth: .infinity)
                                        .transition(.opacity)
                                }
                            }
                                
                            // Notification option
                            NotificationToggleView(
                                isEnabled: $viewModel.notificationEnabled,
                                notificationTime: $viewModel.notificationTime,
                                onToggle: { viewModel.toggleNotification() }
                            )
                            .padding(.horizontal, 16)
                            .padding(.top, .spacingSmall)
                        }
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
                    .disabled(!viewModel.isFormValid)
                }
            }
            Spacer()
        }
        .scrollDismissesKeyboard(.immediately)
        .alert(isPresented: $viewModel.saveAlert) {
            Alert(
                title: Text("error_title"),
                message: Text("save_task_error_message"),
                dismissButton: .default(Text("ok_button"))
            )
        }
        .alert("notification_permission_denied_title", isPresented: $viewModel.notificationPermissionDenied) {
            Button("ok_button", role: .cancel) { }
        } message: {
            Text("notification_permission_denied_message")
        }
    }
}

#Preview {
    AddTaskView()
}
