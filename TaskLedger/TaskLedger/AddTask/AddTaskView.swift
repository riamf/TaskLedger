//
//  AddTaskView.swift
//  TaskLedger
//
//  Created by Pawel Kowalczuk on 01/10/2025.
//

import SwiftData
import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = AddTaskViewModel()
    
    var body: some View {
        VStack(spacing: .spacing) {
            HStack(spacing: .spacing) {
                HStack(spacing: .spacing) {
                    CloseModalView(dismiss: dismiss)
                    Spacer()
                }
            }.padding(.vertical, .bigSpacing).padding(.horizontal, .spacing)
            VStack(spacing: .spacingSmall) {
                VStack(spacing: 8) {
                    ScrollViewReader { proxy in
                        TaskTypeSwitcherView(taskType: $viewModel.taskType).padding(.horizontal, 16)
                            .onChange(of: viewModel.taskType) { newValue in
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
                        VStack(spacing: .spacingSmall) {
                            HStack() {
                                createDayCheckmark(Weekdays.allCases[0])
                                createDayCheckmark(Weekdays.allCases[1])
                                createDayCheckmark(Weekdays.allCases[2])
                            }
                            HStack() {
                                createDayCheckmark(Weekdays.allCases[3])
                                createDayCheckmark(Weekdays.allCases[4])
                            }
                            HStack {
                                createDayCheckmark(Weekdays.allCases[5]).tint(.red)
                                createDayCheckmark(Weekdays.allCases[6]).tint(.red)
                            }
                        }
                        
                    }.tint(.black)
                    HStack {
                        Text("Task Notes:")
                        Spacer()
                    }.padding(.horizontal, .spacing)
                    TextField("",
                              text: $viewModel.notes,
                              prompt: Text("Enter notes here..."),
                              axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(5, reservesSpace: true)
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
                    dismiss()
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: "square.and.arrow.down.on.square").tint(.black)
                        Spacer()
                    }
                }
                .frame(height: 44)
                .cornerRadius(8)
                .overlay( /// apply a rounded border
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.black, lineWidth: 2)
                )
                .padding(.horizontal, 16)
            }
        }
        Spacer()
            .alert(isPresented: $viewModel.saveAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text("Failed to save task. Please try again."),
                    dismissButton: .default(Text("OK"))
                )
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
