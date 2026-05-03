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
    @DInjected(\.analytics) private var analytics: AnalyticsService
    @DInjected(\.fetcher) private var fetcher: Fetcher
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
                Text("no_tasks_add_some")
                    .foregroundStyle(.gray)
                Spacer()
            } else {
                Text("all_available_tasks_header")
                    .font(.headline)
                Spacer()
                List {
                    ForEach(tasks) { task in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(task.name)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                .padding(.horizontal, 4)
                            }
                            Spacer()
                            Button() {
                                
                            } label: {
                                HStack {
                                    Text("edit_button_title")
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
                                analytics.logTaskFullyDeleted(taskType: task.taskType)
                                analytics.updateTotalTasksCount(fetcher.fetchActiveTaskCount())
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
                title: Text("error_title"),
                message: Text("delete_task_error_message"),
                dismissButton: .default(Text("ok_button"))
            )
        }
    }
}
