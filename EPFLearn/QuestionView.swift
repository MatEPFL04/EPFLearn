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
    @State private var showVisualization = false

    var body: some View {
        NavigationStack {
            ZStack {

                // Contenu de la question
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        QuestionBodyText(text: vm.currentQuestion.text)

                        ForEach(Array(vm.currentQuestion.options.enumerated()), id: \.offset) { index, option in
                            OptionButton(
                                text: option,
                                state: buttonState(for: index),
                                action: { vm.selectAnswer(index) }
                            )
                        }

                        if vm.hasAnswered {
                            Text(vm.currentQuestion.explanation)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .padding()
                                .background(.regularMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                            OptionButton(text: "Next question", state: .idle,
                                         action: { vm.nextQuestion() })
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)   // remplace le Spacer()
                    .padding()
                }
                .opacity(showVisualization ? 0 : 1)
                .allowsHitTesting(!showVisualization)

                VisualizationView(
                    type: vm.currentQuestion.visualization,
                    hint: vm.currentQuestion.hint)
                .id(vm.currentQuestion.id)
                .opacity(showVisualization ? 1 : 0)
                .allowsHitTesting(showVisualization)
            }
            .toolbar {
                Button(showVisualization ? "Question" : "Hint") {
                    showVisualization.toggle()
                }
            }
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
}
