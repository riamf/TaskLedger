//
//  TaskLedgerApp.swift
//  TaskLedger
//
//  Created by Pawel Kowalczuk on 30/09/2025.
//

import SwiftUI
import SwiftData

@main
struct TaskLedgerApp: App {
    @Environment(\.modelContext) private var modelContext
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            EventTask.self,
            EventMark.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            let container =  try ModelContainer(for: schema, configurations: [modelConfiguration])
            DI.instance.initalize(modelContext: container.mainContext)
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            DayView()
        }
        .modelContainer(sharedModelContainer)
    }
}
