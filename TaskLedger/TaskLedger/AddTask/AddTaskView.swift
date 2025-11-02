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
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                HStack(spacing: 16) {
                    CloseModalView(dismiss: dismiss)
                    Spacer()
                }
            }.padding(.vertical, 32).padding(.horizontal, 16)
            VStack(spacing: 8) {
                TaskTypeSwitcherView(taskType: $viewModel.taskType).padding(.horizontal, 16)
                Text("Task name:").padding(.leading, 16).frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $viewModel.inputTaskName, prompt: Text("Enter task name"))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 16)
                
                if viewModel.taskType == .income || viewModel.taskType == .cost {
                    Text("Enter \(viewModel.taskType == .income ? "income" : "cost") amount:")
                        .padding(.leading, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField("", value: $viewModel.amount, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 16)
                } else if viewModel.taskType == .time {
                    Text("Enter time time spend:")
                    HStack {
                        TextField("Hours", value: $viewModel.timeHours, format: .number, prompt: Text("Hours"))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                        TextField("Minutes", value: $viewModel.timeMinutes, format: .number, prompt: Text("Minutes"))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                        TextField("Seconds", value: $viewModel.timeSeconds, format: .number, prompt: Text("Seconds"))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                    }.padding(.horizontal, 16)
                        
                }
                VStack {
//                    ForEach(dayNames, id: \.self) { day in
//                        Button {
//                            if daysSelected.contains(day) {
//                                daysSelected.removeAll(where: { $0 == day })
//                            } else {
//                                daysSelected.append(day)
//                            }
//                        } label: {
//                            HStack {
//                                if daysSelected.contains(day) {
//                                    Image(systemName: "checkmark.circle")
//                                        .tint(.black)
//                                } else {
//                                    Image(systemName: "circle")
//                                        .tint(.black)
//                                }
//                                    
//                                Text(day)
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .padding(.leading, 8)
//                                    .tint(.black)
//                            }
//                            .padding(.leading, 16)
//                            .padding(.top, 16)
//                        }
//                            
//                    }
                    Text("Enter task notes:")
                        .padding(.horizontal, 16)
                    TextEditor(text: $viewModel.notes)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                       .stroke(.black, lineWidth: 2)
                        }
                        .padding(.horizontal, 16)
                    Spacer()
                    Button {
////                        let task = EventTask(
////                            timestamp: Date(),
////                            name: inputTaskName,
////                            taskType: taskType,
////                            amount: amount,
////                            days: daysSelected.compactMap { dayNames.firstIndex(of: $0) },
////                            notes: notes
////                        )
////                        modelContext.insert(task)
//                        do {
//                            try modelContext.save()
//                            dismiss()
//                        } catch {
//                            viewModel.saveAlert = true
//                        }
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
        }
        .alert(isPresented: $viewModel.saveAlert) {
            Alert(
                title: Text("Error"),
                message: Text("Failed to save task. Please try again."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
