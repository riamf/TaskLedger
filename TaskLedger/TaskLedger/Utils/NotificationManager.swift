import Foundation
import UserNotifications

protocol NotificationService {
    func requestAuthorization(completion: @escaping (Bool) -> Void)
    func scheduleTaskNotification(for task: EventTask, referenceDate: Date)
    func removeNotification(for taskId: String)
}

extension NotificationService {
    func syncNotifications(for tasks: [EventTask], referenceDate: Date = Date()) {
        tasks.forEach { scheduleTaskNotification(for: $0, referenceDate: referenceDate) }
    }
}

final class NotificationManager: NotificationService {

    private let center = UNUserNotificationCenter.current()

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func scheduleTaskNotification(for task: EventTask, referenceDate: Date = Date()) {
        guard task.notificationEnabled, let notificationTime = task.notificationTime else { return }

        removeNotification(for: task.id)

        let content = UNMutableNotificationContent()
        content.title = String(localized: "notification_title")
        content.body = task.name
        content.sound = .default

        for item in notificationScheduleItems(
            for: task,
            notificationTime: notificationTime,
            referenceDate: referenceDate
        ) {
            let trigger = UNCalendarNotificationTrigger(dateMatching: item.dateComponents, repeats: item.repeats)
            let request = UNNotificationRequest(identifier: item.identifier, content: content, trigger: trigger)
            center.add(request)
        }
    }

    func removeNotification(for taskId: String) {
        center.getPendingNotificationRequests { requests in
            let ids = requests.filter { $0.identifier.hasPrefix(taskId) }.map(\.identifier)
            self.center.removePendingNotificationRequests(withIdentifiers: ids)
            self.center.removeDeliveredNotifications(withIdentifiers: ids)
        }
    }
}

struct NotificationScheduleItem: Equatable {
    let identifier: String
    let dateComponents: DateComponents
    let repeats: Bool
}

func notificationScheduleItems(
    for task: EventTask,
    notificationTime: Date,
    referenceDate: Date = Date(),
    calendar: Calendar = .current
) -> [NotificationScheduleItem] {
    guard task.notificationEnabled else { return [] }

    if isTaskNotificationSnoozed(task, relativeTo: referenceDate, calendar: calendar) {
        guard let nextDate = nextNotificationDate(
            for: task,
            notificationTime: notificationTime,
            referenceDate: referenceDate,
            calendar: calendar
        ) else {
            return []
        }

        return [
            NotificationScheduleItem(
                identifier: "\(task.id)-resume",
                dateComponents: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: nextDate),
                repeats: false
            )
        ]
    }

    let timeComponents = calendar.dateComponents([.hour, .minute], from: notificationTime)

    if let pattern = task.repeatingPattern {
        switch pattern {
        case .daily(let days):
            if days.count == 7 {
                var match = DateComponents()
                match.hour = timeComponents.hour
                match.minute = timeComponents.minute
                return [NotificationScheduleItem(identifier: "\(task.id)-daily", dateComponents: match, repeats: true)]
            }

            return days.map { day in
                var match = DateComponents()
                match.hour = timeComponents.hour
                match.minute = timeComponents.minute
                match.weekday = day.calendarWeekday
                return NotificationScheduleItem(
                    identifier: "\(task.id)-\(day.rawValue)",
                    dateComponents: match,
                    repeats: true
                )
            }

        case .monthly(let dayOfMonth):
            var match = DateComponents()
            match.day = dayOfMonth
            match.hour = timeComponents.hour
            match.minute = timeComponents.minute
            return [NotificationScheduleItem(identifier: "\(task.id)-monthly", dateComponents: match, repeats: true)]

        case .yearly(let day, let month):
            var match = DateComponents()
            match.month = month
            match.day = day
            match.hour = timeComponents.hour
            match.minute = timeComponents.minute
            return [NotificationScheduleItem(identifier: "\(task.id)-yearly", dateComponents: match, repeats: true)]
        }
    }

    guard let nextDate = nextNotificationDate(
        for: task,
        notificationTime: notificationTime,
        referenceDate: referenceDate,
        calendar: calendar
    ) else {
        return []
    }

    return [
        NotificationScheduleItem(
            identifier: "\(task.id)-onetime",
            dateComponents: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: nextDate),
            repeats: false
        )
    ]
}

func nextNotificationDate(
    for task: EventTask,
    notificationTime: Date,
    referenceDate: Date = Date(),
    calendar: Calendar = .current
) -> Date? {
    let searchStart = calendar.startOfDay(for: max(referenceDate, task.timestamp))

    for offset in 0..<400 {
        guard let day = calendar.date(byAdding: .day, value: offset, to: searchStart),
              task.occurs(on: day, calendar: calendar)
        else {
            continue
        }

        var dateComponents = calendar.dateComponents([.year, .month, .day], from: day)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: notificationTime)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute

        guard let candidate = calendar.date(from: dateComponents), candidate >= referenceDate else {
            continue
        }

        return candidate
    }

    return nil
}

func isTaskNotificationSnoozed(
    _ task: EventTask,
    relativeTo referenceDate: Date = Date(),
    calendar: Calendar = .current
) -> Bool {
    guard let snoozedUntil = task.snoozedUntil else { return false }
    return calendar.startOfDay(for: snoozedUntil) > calendar.startOfDay(for: referenceDate)
}
