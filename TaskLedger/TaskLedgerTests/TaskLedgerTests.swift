//
//  TaskLedgerTests.swift
//  TaskLedgerTests
//
//  Created by Pawel Kowalczuk on 30/09/2025.
//

import Foundation
import SwiftData
import Testing
@testable import TaskLedger

struct TaskLedgerTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

    @Test func archivedTaskDisappearsImmediatelyFromArchivedDayButKeepsPastHistory() async throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let archivedDay = DateComponents(
            calendar: calendar,
            year: 2026,
            month: 5,
            day: 17,
            hour: 12
        ).date!
        let previousDay = calendar.date(byAdding: .day, value: -1, to: archivedDay)!

        let task = EventTask(
            timestamp: previousDay,
            name: "Archive Me",
            taskType: .counter,
            repeatingPattern: .daily(weekdays: Weekdays.allCases),
            days: Weekdays.allCases
        )

        #expect(task.occurs(on: archivedDay, calendar: calendar))
        #expect(task.occurs(on: previousDay, calendar: calendar))

        task.archivedAt = calendar.startOfDay(for: archivedDay).addingTimeInterval(-1)

        #expect(!task.occurs(on: archivedDay, calendar: calendar))
        #expect(task.occurs(on: previousDay, calendar: calendar))
    }

    @MainActor
    @Test func summaryDetailsRefreshesAfterEventChanges() throws {
        let schema = Schema([EventTask.self, EventMark.self])
        let container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        let context = container.mainContext
        DI.instance.initalize(modelContext: context)

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let month = DateComponents(
            calendar: calendar,
            year: 2026,
            month: 5,
            day: 1
        ).date!
        let firstDay = DateComponents(
            calendar: calendar,
            year: 2026,
            month: 5,
            day: 5,
            hour: 9
        ).date!
        let secondDay = DateComponents(
            calendar: calendar,
            year: 2026,
            month: 5,
            day: 7,
            hour: 9
        ).date!

        let task = EventTask(
            timestamp: firstDay,
            name: "Refresh Me",
            taskType: .counter,
            repeatingPattern: .daily(weekdays: Weekdays.allCases),
            days: Weekdays.allCases
        )
        context.insert(task)
        context.insert(EventMark(date: firstDay, task: task))
        try context.save()

        let initialSummary = try #require(
            DI.instance.fetcher.fetchSummary(for: month).values.first(where: { $0.task.id == task.id })
        )
        let viewModel = SummaryDetailsViewModel(eventSummary: initialSummary, visibleMonth: month)
        #expect(viewModel.filteredEvents.count == 1)

        context.insert(EventMark(date: secondDay, task: task))
        try context.save()

        viewModel.refreshData(for: month)
        #expect(viewModel.filteredEvents.count == 2)

        for event in task.events ?? [] {
            context.delete(event)
        }
        try context.save()

        viewModel.refreshData(for: month)
        #expect(viewModel.filteredEvents.isEmpty)
    }

}
