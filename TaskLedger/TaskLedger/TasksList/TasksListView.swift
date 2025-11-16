//
//  TasksListView.swift
//  TaskLedger
//
//  Created by Pawel Kowalczuk on 20/10/2025.
//

import Foundation
import SwiftUI
import SwiftData

struct TasksListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State var showAlertView = false
    
    @Query var tasks: [EventTask]
    
    var body: some View {
        VStack {
            HStack {
                CloseModalView(dismiss: dismiss)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                Spacer()
            }.padding(.vertical, 8)
            Spacer()
            if tasks.isEmpty {
                Text("No tasks, add some!")
                    .foregroundStyle(.gray)
                Spacer()
            } else {
                Text("All available Tasks")
                    .font(.headline)
                Spacer()
                List {
                    ForEach(tasks) { task in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(task.name)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                HStack {
//                                    ForEach(task.days, id: \.self) { day in
//                                        Text(DaysCalculator.dayName(from: day))
//                                            .font(.caption)
//                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                            Spacer()
                            Button() {
                                
                            } label: {
                                HStack {
                                    Text("Edit")
                                    Image(systemName: "pencil")
                                }.tint(.black)
                            }
                        }
                    }.onDelete { indexSet in
                        indexSet.forEach { index in
                            let task = tasks[index]
                            modelContext.delete(task)
                            do {
                                try modelContext.save()
                            } catch {
                                showAlertView.toggle()
                            }
                        }
                    }
                }
                Spacer()
            }
        }
        .alert(isPresented: $showAlertView) {
            Alert(
                title: Text("Error"),
                message: Text("Failed to delete task. Please try again."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
