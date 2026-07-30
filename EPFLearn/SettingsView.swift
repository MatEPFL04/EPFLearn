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

    @Query private var allRecords: [QuizResultRecord]

    private var myRecordCount: Int {
        allRecords.filter { $0.userID == profile.id }.count
    }

    private var appVersion: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "—"
        let build   = info?["CFBundleVersion"] as? String ?? "—"
        return "\(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent("Quizzes completed", value: "\(myRecordCount)")
                } header: {
                    Text("Your data")
                } footer: {
                    Text("LearnViz has no accounts. Everything you do stays on this device and is never uploaded.")
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
                    Text("Permanently erases every quiz result stored on this device. This cannot be undone.")
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
                Text("All your quiz history will be erased. This cannot be undone.")
            }
            .alert("Couldn't reset your progress", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
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
