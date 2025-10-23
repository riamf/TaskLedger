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
    @Environment(\.modelContext) private var modelContext
    
    @State private var inputTaskName: String = ""
    @State private var daysSelected: [String] = []
    @State private var taskType: TaskType = .counter
    @State private var amount: Double = 0.0
    
    @State private var timeHours: Int = 0
    @State private var timeMinutes: Int = 0
    @State private var timeSeconds: Int = 0
    
    @State var days: [Int] = []
    @State var notes: String = ""
    @State var saveAlert = false
    
    let dayNames: [String] = {
        Calendar.current.weekdaySymbols
    }()
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                HStack(spacing: 16) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image("close").tint(.black)
                            Text("Cancel").foregroundStyle(.black)
                        }
                    }
                    Spacer()
                }
            }.padding(.vertical, 32).padding(.horizontal, 16)
            VStack(spacing: 8) {
                HStack {
                    ForEach(TaskType.allCases, id: \.self) { type in
                        Button {
                            taskType = type
                        } label: {
                            TaskTypeButtonLabel(systemImageName: type == taskType ? type.imageNameMarked : type.imageName, title: type.taskName)
                        }
                    }
                }.padding(.horizontal, 16)
                Text("Task name:").padding(.leading, 16).frame(maxWidth: .infinity, alignment: .leading)
                TextField("", text: $inputTaskName, prompt: Text("Enter task name"))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 16)
                if taskType == .income || taskType == .cost {
                    Text("Enter \(taskType == .income ? "income" : "cost") amount:")
                        .padding(.leading, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField("", value: $amount, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 16)
                } else if taskType == .time {
                    Text("Enter time time spend:")
                    HStack {
                        TextField("Hours", value: $timeHours, format: .number, prompt: Text("Hours"))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                        TextField("Minutes", value: $timeMinutes, format: .number, prompt: Text("Minutes"))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                        TextField("Seconds", value: $timeSeconds, format: .number, prompt: Text("Seconds"))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                    }.padding(.horizontal, 16)
                        
                }
                VStack {
                    ForEach(dayNames, id: \.self) { day in
                        Button {
                            if daysSelected.contains(day) {
                                daysSelected.removeAll(where: { $0 == day })
                            } else {
                                daysSelected.append(day)
                            }
                        } label: {
                            HStack {
                                if daysSelected.contains(day) {
                                    Image(systemName: "checkmark.circle")
                                        .tint(.black)
                                } else {
                                    Image(systemName: "circle")
                                        .tint(.black)
                                }
                                    
                                Text(day)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 8)
                                    .tint(.black)
                            }
                            .padding(.leading, 16)
                            .padding(.top, 16)
                        }
                            
                    }
                    Text("Enter task notes:")
                        .padding(.horizontal, 16)
                    TextEditor(text: $notes)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                       .stroke(.black, lineWidth: 2)
                        }
                        .padding(.horizontal, 16)
                    Spacer()
                    Button {
                        let task = EventTask(
                            timestamp: Date(),
                            name: inputTaskName,
                            taskType: taskType,
                            amount: amount,
                            days: daysSelected.compactMap { dayNames.firstIndex(of: $0) },
                            notes: notes
                        )
                        modelContext.insert(task)
                        do {
                            try modelContext.save()
                            dismiss()
                        } catch {
                            saveAlert = true
                        }
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
        .alert(isPresented: $saveAlert) {
            Alert(
                title: Text("Error"),
                message: Text("Failed to save task. Please try again."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
