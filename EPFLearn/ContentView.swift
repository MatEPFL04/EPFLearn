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

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showOnboarding = false
    @AppStorage("dailyReminderEnabled") private var reminderEnabled = false

    @State private var selectedTab = 0
    /// Set by StatisticsView's "focus review" button; QuizView watches it and
    /// jumps straight into a quiz for that subject.
    @State private var pendingSubject: Subject? = nil

    private var previousScores: [ResultQCM] {
        allRecords
            .filter { $0.userID == profile.id }
            .compactMap(\.asResultQCM)
    }

    /// Consecutive days with at least one completed quiz, counting back from
    /// today. If nothing's been done yet today the streak is still "alive"
    /// through yesterday - it only resets once a full day is skipped.
    private var currentStreak: Int {
        let calendar = Calendar.current
        let days = Set(allRecords
            .filter { $0.userID == profile.id }
            .map { calendar.startOfDay(for: $0.date) })
        guard !days.isEmpty else { return 0 }

        var streak = 0
        var cursor = calendar.startOfDay(for: .now)
        if !days.contains(cursor) {
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor)!
        }
        while days.contains(cursor) {
            streak += 1
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor)!
        }
        return streak
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            QuizView(vm: $vm, pendingSubject: $pendingSubject, onChallengeComplete: record)
                .tabItem { Label("Practice", systemImage: "questionmark.circle") }
                .tag(0)

            StatisticsView(scores: .constant(previousScores), streak: currentStreak) { subject in
                pendingSubject = subject
                selectedTab = 0
            }
            .tabItem { Label("Progress", systemImage: "chart.bar") }
            .tag(1)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(2)
        }
        .environment(profile)
        .onAppear {
            installQuizCompletionHandler()
            if !hasCompletedOnboarding { showOnboarding = true }
            if reminderEnabled { ReminderManager.reschedule(hasCompletedQuizToday: hasCompletedQuizToday) }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView {
                hasCompletedOnboarding = true
                showOnboarding = false
            }
        }
    }

    /// Persists a finished quiz under the current local profile.
    private func installQuizCompletionHandler() {
        vm.onComplete = record
    }

    /// Shared by both study modes: a finished run is a finished run.
    private func record(_ result: ResultQCM) {
        modelContext.insert(QuizResultRecord(result: result, userID: profile.id))
        try? modelContext.save()
        if reminderEnabled { ReminderManager.reschedule(hasCompletedQuizToday: true) }
        RateAppManager.maybeNudge(sessionCount: previousScores.count, streak: currentStreak)
    }

    private var hasCompletedQuizToday: Bool {
        let today = Calendar.current.startOfDay(for: .now)
        return allRecords.contains {
            $0.userID == profile.id && Calendar.current.startOfDay(for: $0.date) == today
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: QuizResultRecord.self, inMemory: true)
}
