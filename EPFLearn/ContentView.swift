//
//  ContentView.swift
//  EPFLearn
//
//  Created by Mat on 08.04.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var vm = QuizViewModel()
    @State private var auth = AuthManager()
    @Environment(\.modelContext) private var modelContext
    @Query private var allRecords: [QuizResultRecord]
    
    var previousScores: [ResultQCM] {
        allRecords
            .filter { $0.userID == auth.userID }
            .compactMap { $0.asResultQCM }
    }
    
    var body: some View {
        Group {
            if auth.isSignedIn {
                TabView {
                    QuizView(vm: $vm)
                        .tabItem { Label("Quiz", systemImage: "questionmark.circle") }
                    StatisticsView(scores: .constant(previousScores))
                        .tabItem { Label("Home", systemImage: "house") }
                }
                .preferredColorScheme(.dark)
                .onAppear {
                    vm.onComplete = { res in
                        guard let uid = auth.userID else { return }
                        let record = QuizResultRecord(result: res, userID: uid)
                        modelContext.insert(record)
                        try? modelContext.save()
                    }
                }
            } else {
                LoginView()
                    .environment(auth)
            }
        }
    }
}

#Preview {
    ContentView()
}
