//
//  SwiftUIView.swift
//  EPFLearn
//
//  Created by Mat on 04.04.2026.
//

import SwiftUI

struct QuizView: View {
    @State private var vm = QuizViewModel()

    var body: some View {
        if vm.isFinished {
            Text("Terminé ! Score : \(vm.score)")
        } else {
            QuestionView(vm: vm)
        }
    }
}
#Preview {
    QuizView()
}
