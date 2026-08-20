//
//  RateAppManager.swift
//  EPFLearn
//
//  A rating ask lands once, tied to a real positive moment (a short streak
//  or a handful of finished sessions), never on a repeating schedule: an app
//  that keeps asking is the fastest way to earn a bad review instead of a
//  good one. It also never requests its own notification permission - it
//  only rides whatever permission the daily reminder already obtained, so
//  turning this on never means a surprise system prompt out of context.
//

import Foundation
import UserNotifications
import UIKit

@MainActor
enum RateAppManager {
    static let identifier = "rateAppNudge"
    private static let hasFiredKey = "hasSentRatingNudge"

    /// LearnScope's own App Store product page, opened straight to the
    /// review screen: the only place a written review actually publishes.
    static let writeReviewURL = URL(string: "https://apps.apple.com/app/id6797223152?action=write-review")!

    /// Call after every completed run, in both study modes. A no-op once it
    /// has already fired once, or if notifications were never granted.
    static func maybeNudge(sessionCount: Int, streak: Int) {
        guard !UserDefaults.standard.bool(forKey: hasFiredKey) else { return }
        guard sessionCount >= 5 || streak >= 3 else { return }

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                schedule()
                UserDefaults.standard.set(true, forKey: hasFiredKey)
            }
        }
    }

    private static func schedule() {
        let content = UNMutableNotificationContent()
        content.title = "Enjoying LearnScope?"
        content.body = "A quick rating helps other students find it."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

/// Routes a tap on the rating nudge straight to the review screen; every
/// other notification (the daily reminder) keeps the OS default of simply
/// foregrounding the app.
final class RateAppNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = RateAppNotificationDelegate()

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 didReceive response: UNNotificationResponse,
                                 withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == RateAppManager.identifier {
            UIApplication.shared.open(RateAppManager.writeReviewURL)
        }
        completionHandler()
    }
}
