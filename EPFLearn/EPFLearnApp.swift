//
//  EPFLearnApp.swift
//  EPFLearn
//
//  Created by Mat on 08.04.2026.
//

import SwiftUI
import SwiftData

@main
struct EPFLearnApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: QuizResult.self)
    }
}
