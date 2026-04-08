//
//  ContentView.swift
//  EPFLearn
//
//  Created by Mat on 08.04.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var vm = QuizViewModel()
    var body: some View {
        QuizView()
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
