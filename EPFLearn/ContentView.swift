//
//  ContentView.swift
//  LearnViz
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var vm = QuizViewModel()
    @State private var profile = LocalProfile()
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \QuizResultRecord.date) private var allRecords: [QuizResultRecord]

    private var previousScores: [ResultQCM] {
        allRecords
            .filter { $0.userID == profile.id }
            .compactMap(\.asResultQCM)
    }

    var body: some View {
        TabView {
            QuizView(vm: $vm)
                .tabItem { Label("Quiz", systemImage: "questionmark.circle") }

            StatisticsView(scores: .constant(previousScores))
                .tabItem { Label("Progress", systemImage: "chart.bar") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .environment(profile)
        .onAppear { installQuizCompletionHandler() }
    }

    /// Persists a finished quiz under the current local profile.
    private func installQuizCompletionHandler() {
        vm.onComplete = { result in
            modelContext.insert(QuizResultRecord(result: result, userID: profile.id))
            try? modelContext.save()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: QuizResultRecord.self, inMemory: true)
}
