//
//  SettingsView.swift
//  LearnViz
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(LocalProfile.self) private var profile
    @Environment(\.modelContext) private var modelContext

    @State private var showResetConfirmation = false
    @State private var isResetting = false
    @State private var showError = false
    @State private var errorMessage = ""

    @AppStorage("dailyReminderEnabled") private var reminderEnabled = false
    @State private var showReminderDeniedAlert = false

    @Query private var allRecords: [QuizResultRecord]

    private var myRecordCount: Int {
        allRecords.filter { $0.userID == profile.id }.count
    }

    private var hasCompletedQuizToday: Bool {
        let today = Calendar.current.startOfDay(for: .now)
        return allRecords.contains {
            $0.userID == profile.id && Calendar.current.startOfDay(for: $0.date) == today
        }
    }

    private var appVersion: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "n/a"
        let build   = info?["CFBundleVersion"] as? String ?? "n/a"
        return "\(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent("Sessions completed", value: "\(myRecordCount)")
                } header: {
                    Text("Your data")
                } footer: {
                    Text("LearnScope has no accounts. Everything you do stays on this device and is never uploaded.")
                }

                Section {
                    Toggle("Daily reminder", isOn: $reminderEnabled)
                        .onChange(of: reminderEnabled) { _, isOn in
                            handleReminderToggle(isOn)
                        }
                } footer: {
                    Text("One evening nudge if you have not practiced yet, and never on a day you already have.")
                }

                Section {
                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        HStack {
                            Text("Reset my progress")
                            Spacer()
                            if isResetting { ProgressView() }
                        }
                    }
                    .disabled(isResetting || myRecordCount == 0)
                } footer: {
                    Text("Permanently erases every result stored on this device, from both study modes. This cannot be undone.")
                }

                Section {
                    NavigationLink {
                        FeedbackView()
                    } label: {
                        Label("Send Feedback", systemImage: "envelope.fill")
                    }
                } footer: {
                    Text("Bugs, ideas, or just how it's going: tell us directly.")
                }

                Section("About") {
                    LabeledContent("Version", value: appVersion)
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog(
                "Reset your progress?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Erase \(myRecordCount) result\(myRecordCount == 1 ? "" : "s")",
                       role: .destructive) {
                    resetProgress()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Your whole history will be erased, in both study modes. This cannot be undone.")
            }
            .alert("Couldn't reset your progress", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .alert("Notifications are off", isPresented: $showReminderDeniedAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Enable notifications for LearnScope in the Settings app to get a daily reminder.")
            }
        }
    }

    private func handleReminderToggle(_ isOn: Bool) {
        guard isOn else {
            ReminderManager.cancel()
            return
        }
        ReminderManager.requestAuthorization { granted in
            if granted {
                ReminderManager.reschedule(hasCompletedQuizToday: hasCompletedQuizToday)
            } else {
                reminderEnabled = false
                showReminderDeniedAlert = true
            }
        }
    }

    private func resetProgress() {
        isResetting = true
        defer { isResetting = false }

        do {
            // Wipe the whole store, not just this profile's rows: any records
            // orphaned by an earlier id go with it.
            try modelContext.delete(model: QuizResultRecord.self)
            try modelContext.save()
            profile.reset()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    SettingsView()
        .environment(LocalProfile())
        .modelContainer(for: QuizResultRecord.self, inMemory: true)
        .preferredColorScheme(.dark)
}
