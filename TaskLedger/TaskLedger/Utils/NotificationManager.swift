import Foundation
import UserNotifications

protocol NotificationService {
    func requestAuthorization(completion: @escaping (Bool) -> Void)
    func scheduleTaskNotification(taskId: String, taskName: String, time: Date, repeatingPattern: RepeatingPattern?, fixedDate: Date?, weekdays: [Weekdays])
    func removeNotification(for taskId: String)
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

    func scheduleTaskNotification(
        taskId: String,
        taskName: String,
        time: Date,
        repeatingPattern: RepeatingPattern?,
        fixedDate: Date?,
        weekdays: [Weekdays]
    ) {
        // Remove any existing notifications for this task first
        removeNotification(for: taskId)

        let content = UNMutableNotificationContent()
        content.title = String(localized: "notification_title")
        content.body = taskName
        content.sound = .default

        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: time)

        if let pattern = repeatingPattern {
            switch pattern {
            case .daily(let days):
                if days.count == 7 {
                    // Every day at this time
                    var match = DateComponents()
                    match.hour = timeComponents.hour
                    match.minute = timeComponents.minute
                    let trigger = UNCalendarNotificationTrigger(dateMatching: match, repeats: true)
                    let request = UNNotificationRequest(identifier: "\(taskId)-daily", content: content, trigger: trigger)
                    center.add(request)
                } else {
                    // Specific weekdays
                    for day in days {
                        var match = DateComponents()
                        match.hour = timeComponents.hour
                        match.minute = timeComponents.minute
                        match.weekday = day.calendarWeekday
                        let trigger = UNCalendarNotificationTrigger(dateMatching: match, repeats: true)
                        let request = UNNotificationRequest(identifier: "\(taskId)-\(day.rawValue)", content: content, trigger: trigger)
                        center.add(request)
                    }
                }

            case .monthly(let dayOfMonth):
                var match = DateComponents()
                match.day = dayOfMonth
                match.hour = timeComponents.hour
                match.minute = timeComponents.minute
                let trigger = UNCalendarNotificationTrigger(dateMatching: match, repeats: true)
                let request = UNNotificationRequest(identifier: "\(taskId)-monthly", content: content, trigger: trigger)
                center.add(request)

            case .yearly(let day, let month):
                var match = DateComponents()
                match.month = month
                match.day = day
                match.hour = timeComponents.hour
                match.minute = timeComponents.minute
                let trigger = UNCalendarNotificationTrigger(dateMatching: match, repeats: true)
                let request = UNNotificationRequest(identifier: "\(taskId)-yearly", content: content, trigger: trigger)
                center.add(request)
            }
        } else if let fixedDate = fixedDate {
            // One-time notification
            var match = Calendar.current.dateComponents([.year, .month, .day], from: fixedDate)
            match.hour = timeComponents.hour
            match.minute = timeComponents.minute
            let trigger = UNCalendarNotificationTrigger(dateMatching: match, repeats: false)
            let request = UNNotificationRequest(identifier: "\(taskId)-onetime", content: content, trigger: trigger)
            center.add(request)
        }
    }

    func removeNotification(for taskId: String) {
        center.getPendingNotificationRequests { requests in
            let ids = requests.filter { $0.identifier.hasPrefix(taskId) }.map(\.identifier)
            self.center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }
}
