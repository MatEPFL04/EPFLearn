//
//  ReminderManager.swift
//  EPFLearn
//
//  A single, always-rescheduled local notification rather than a repeating
//  daily trigger: a repeating trigger can't know whether today's quiz has
//  already happened, so it would nag on days the streak is already safe.
//  Instead, every reschedule cancels the pending one and books either today
//  (if that's still ahead and nothing's been done yet) or tomorrow.
//

import Foundation
import UserNotifications

@MainActor
enum ReminderManager {
    static let identifier = "dailyStreakReminder"
    static let hour = 19 // 7 PM local time

    static func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    /// Cancels any pending reminder and books the next one.
    static func reschedule(hasCompletedQuizToday: Bool) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let calendar = Calendar.current
        let now = Date.now
        var fireDate = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: now) ?? now
        if hasCompletedQuizToday || fireDate <= now {
            fireDate = calendar.date(byAdding: .day, value: 1, to: fireDate) ?? fireDate
        }

        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

        let content = UNMutableNotificationContent()
        content.title = "Keep your streak alive"
        content.body = "You haven't practiced today yet, a quick quiz keeps it going."
        content.sound = .default

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request)
    }

    static func cancel() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
