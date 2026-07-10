//
//  ContentView.swift
//  EPFLearn
//
//  Created by Mat on 08.04.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var vm = QuizViewModel()
    @State private var previousScores = [ResultQCM]()

    var body: some View {
        TabView {
            QuizView(vm: $vm)
                .tabItem { Label("Quiz", systemImage: "questionmark.circle") }
            StatisticsView(scores: $previousScores)
                .tabItem { Label("Home", systemImage: "house") }
        }
        .preferredColorScheme(.dark)    
        .onAppear {
            vm.onComplete = { res in previousScores.append(res) }
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
