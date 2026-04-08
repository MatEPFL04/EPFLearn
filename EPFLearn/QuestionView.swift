//
//  QuestionView.swift
//  EPFLearn
//
//  Created by Mat on 04.04.2026.
//

import Foundation
import SwiftUI

struct QuestionView: View {
    
    var vm: QuizViewModel

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                
                Text(vm.currentQuestion.text)
                    .font(.title3)
                    .fontWeight(.medium)
                
                ForEach(Array(vm.currentQuestion.options.enumerated()), id: \.offset) { index, option in
                    OptionButton(
                        text: option,
                        state: buttonState(for: index),
                        action: {
                            vm.selectAnswer(index)
                        }
                    )
                }
                if vm.hasAnswered {
                    Text(vm.currentQuestion.explanation)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                if vm.hasAnswered { OptionButton(text: "Prochaine question", state: .idle, action: { vm.nextQuestion() }) }
                            
                Spacer()
            }
            .toolbar {
                NavigationLink(destination: VisualizationView(type: vm.currentQuestion.visualization), label: { Text("Hint") })
                
            }
            .padding()
            
        }
    }

    func buttonState(for index: Int) -> OptionButton.AnswerState {
        guard let selected = vm.selectedAnswer else { return .idle }
        if index == vm.currentQuestion.correctIndex { return .correct }
        if index == selected { return .wrong }
        return .idle
    }
}
#Preview {
    QuestionView(vm: QuizViewModel())
        .preferredColorScheme(.dark)
}
