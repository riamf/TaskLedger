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
            DI.instance.fetcher.fetchSummary(for: month).first(where: { $0.task.id == task.id })
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

    @MainActor
    @Test func summaryShowsTemplateTasksIndividuallyByDefaultAndGroupedOnDemand() throws {
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
        let firstDate = DateComponents(
            calendar: calendar,
            year: 2026,
            month: 5,
            day: 8,
            hour: 9
        ).date!
        let secondDate = DateComponents(
            calendar: calendar,
            year: 2026,
            month: 5,
            day: 8,
            hour: 10
        ).date!

        let sharedGroupID = "template-group"
        let task1 = EventTask(
            timestamp: firstDate,
            name: "T1",
            taskType: .counter,
            repeatingPattern: .daily(weekdays: Weekdays.allCases),
            days: Weekdays.allCases,
            groupId: sharedGroupID
        )
        let task2 = EventTask(
            timestamp: calendar.date(byAdding: .day, value: 1, to: firstDate)!,
            name: "T2",
            taskType: .counter,
            repeatingPattern: .daily(weekdays: Weekdays.allCases),
            days: Weekdays.allCases,
            groupId: sharedGroupID
        )

        context.insert(task1)
        context.insert(task2)
        context.insert(EventMark(date: firstDate, task: task1))
        context.insert(EventMark(date: secondDate, task: task2))
        try context.save()

        let individualSummaries = DI.instance.fetcher.fetchSummary(for: month)
        #expect(individualSummaries.count == 2)
        #expect(Set(individualSummaries.map(\.displayName)) == Set(["T1", "T2"]))
        #expect(individualSummaries.allSatisfy { $0.counterSummary == 1 })

        let groupedSummaries = DI.instance.fetcher.fetchSummary(for: month, mode: .templateGroup)
        #expect(groupedSummaries.count == 1)

        let groupedSummary = try #require(groupedSummaries.first)
        #expect(groupedSummary.displayName == "T1 + T2")
        #expect(groupedSummary.counterSummary == 2)
        #expect(groupedSummary.tasks.count == 2)
    }

    @MainActor
    @Test func groupedSummaryModeIsHiddenWhenNothingWouldBeCollapsed() throws {
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
        let eventDate = DateComponents(
            calendar: calendar,
            year: 2026,
            month: 5,
            day: 8,
            hour: 9
        ).date!

        let task = EventTask(
            timestamp: eventDate,
            name: "Solo",
            taskType: .counter,
            repeatingPattern: .daily(weekdays: Weekdays.allCases),
            days: Weekdays.allCases
        )

        context.insert(task)
        context.insert(EventMark(date: eventDate, task: task))
        try context.save()

        let viewModel = SummaryViewModel()
        viewModel.currentMonthDate = month
        viewModel.fetchData()

        #expect(!viewModel.showsGroupingModePicker)
        #expect(viewModel.groupingMode == .individual)
        #expect(viewModel.summaries.count == 1)
        #expect(viewModel.summaries.first?.displayName == "Solo")

        viewModel.groupingMode = .templateGroup

        #expect(viewModel.groupingMode == .individual)
        #expect(!viewModel.showsGroupingModePicker)
        #expect(viewModel.summaries.count == 1)
        #expect(viewModel.summaries.first?.displayName == "Solo")
    }

    @MainActor
    @Test func historyTemplatesExcludeTasksCreatedFromHistory() throws {
        let schema = Schema([EventTask.self, EventMark.self])
        let container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        let context = container.mainContext
        DI.instance.initalize(modelContext: context)

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let rootDate = DateComponents(
            calendar: calendar,
            year: 2026,
            month: 5,
            day: 1,
            hour: 9
        ).date!
        let derivedDate = DateComponents(
            calendar: calendar,
            year: 2026,
            month: 5,
            day: 2,
            hour: 9
        ).date!
        let independentDate = DateComponents(
            calendar: calendar,
            year: 2026,
            month: 5,
            day: 3,
            hour: 9
        ).date!

        let sharedGroupID = "history-template-group"
        let rootTask = EventTask(
            timestamp: rootDate,
            name: "T1",
            taskType: .counter,
            repeatingPattern: .daily(weekdays: Weekdays.allCases),
            days: Weekdays.allCases,
            groupId: sharedGroupID
        )
        let derivedTask = EventTask(
            timestamp: derivedDate,
            name: "T2",
            taskType: .counter,
            repeatingPattern: .daily(weekdays: Weekdays.allCases),
            days: Weekdays.allCases,
            groupId: sharedGroupID
        )
        let independentTask = EventTask(
            timestamp: independentDate,
            name: "Independent",
            taskType: .counter,
            repeatingPattern: .daily(weekdays: Weekdays.allCases),
            days: Weekdays.allCases
        )

        context.insert(rootTask)
        context.insert(derivedTask)
        context.insert(independentTask)
        try context.save()

        let templates = DI.instance.fetcher.fetchUniqueTaskTemplates()

        #expect(templates.count == 2)
        #expect(Set(templates.map(\.name)) == Set(["T1", "Independent"]))
        #expect(!templates.contains(where: { $0.name == "T2" }))
        #expect(templates.contains(where: { $0.id == rootTask.id }))
    }

    @MainActor
    @Test func addTaskValidationBlocksDuplicateNamesIgnoringCaseAndWhitespace() throws {
        let schema = Schema([EventTask.self, EventMark.self])
        let container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        let context = container.mainContext
        DI.instance.initalize(modelContext: context)

        let existingTask = EventTask(
            timestamp: Date(),
            name: "Morning Run",
            taskType: .counter,
            repeatingPattern: .daily(weekdays: Weekdays.allCases),
            days: Weekdays.allCases
        )
        context.insert(existingTask)
        try context.save()

        let viewModel = AddTaskViewModel()
        viewModel.loadTemplates()
        viewModel.taskFrequency = .daily
        viewModel.inputTaskName = "  morning run  "

        #expect(viewModel.showsDuplicateNameWarning)
        #expect(viewModel.doesTaskNameAlreadyExist)
        #expect(!viewModel.isFormValid)
        #expect(!viewModel.saveTask())
        #expect(try context.fetch(FetchDescriptor<EventTask>()).count == 1)
    }

}
