import SwiftData
import SwiftUI

struct AddTaskView: View {
    @Environment(\.colorScheme) var colorScheme
    var onAddAction: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = AddTaskViewModel()
    @State private var didPersistTask = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: .spacing) {
                headerView
                    .padding(.top, .bigSpacing)
                    .padding(.horizontal, .spacing)
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
                    SaveTaskButton(isEnabled: viewModel.isFormValid) {
                        handleSave()
                    }
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
        .sheet(isPresented: $viewModel.showHistorySheet) {
            TaskHistoryListView(tasks: viewModel.taskTemplates) { task in
                viewModel.applyTemplate(task)
            }
            .presentationDetents([.medium, .large])
        }
        .onDisappear {
            if !didPersistTask {
                viewModel.trackCreationCancelled()
            }
        }
        .onAppear {
            viewModel.loadTemplates()
        }
    }

    @ViewBuilder
    private var headerView: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: .spacingSmall) {
                CloseModalButton()
                    .layoutPriority(2)

                Spacer(minLength: .spacingSmall)

                trailingHeaderActions
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: .spacingSmall) {
                HStack(alignment: .center, spacing: .spacingSmall) {
                    CloseModalButton()
                        .layoutPriority(2)

                    Spacer(minLength: .spacingSmall)

                    topSaveButton
                }

                if viewModel.hasTemplates {
                    HStack {
                        Spacer(minLength: 0)
                        historyButton
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var trailingHeaderActions: some View {
        HStack(alignment: .center, spacing: .spacingSmall) {
            if viewModel.hasTemplates {
                historyButton
            }

            topSaveButton
        }
    }

    private var historyButton: some View {
        Button {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                            to: nil, from: nil, for: nil)
            viewModel.showHistorySheet = true
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "clock.arrow.circlepath")
                Text("history_button_title")
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .foregroundStyle(colorScheme == .light ? .black : .white)
            .fixedSize(horizontal: true, vertical: false)
        }
        .buttonStyle(.plain)
    }

    private var topSaveButton: some View {
        Button {
            handleSave()
        } label: {
            HStack(spacing: 4) {
                Text("save_button_title")
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .foregroundStyle(colorScheme == .light ? .black : .white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(colorScheme == .light ? 0.6 : 0.3),
                                Color.white.opacity(colorScheme == .light ? 0.2 : 0.05),
                                Color.blue.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: .black.opacity(colorScheme == .light ? 0.08 : 0.2), radius: 8, x: 0, y: 4)
            .fixedSize(horizontal: true, vertical: false)
        }
        .opacity(viewModel.isFormValid ? 1 : 0.45)
        .buttonStyle(.plain)
    }

    private func handleSave() {
        guard viewModel.isFormValid else {
            viewModel.trackValidationFailure()
            return
        }

        guard viewModel.saveTask() else { return }

        didPersistTask = true
        onAddAction?()
        dismiss()
    }
}

#Preview {
    AddTaskView()
}
