//
//  EPFLearnApp.swift
//  EPFLearn
//
//  Created by Mat on 08.04.2026.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct EPFLearnApp: App {
    init() {
        // Set before any notification can be tapped, including a cold
        // launch straight from one.
        UNUserNotificationCenter.current().delegate = RateAppNotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: QuizResultRecord.self)
    }
}
