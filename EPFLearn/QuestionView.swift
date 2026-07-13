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
                VStack(alignment: .leading, spacing: 20) {
                    Text(vm.currentQuestion.text)
                        .font(.title3)
                        .fontWeight(.medium)

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
                    }

                    if vm.hasAnswered {
                        OptionButton(text: "Prochaine question", state: .idle, action: { vm.nextQuestion() })
                    }

                    Spacer()
                }
                .padding()
                .opacity(showVisualization ? 0 : 1)
                .allowsHitTesting(!showVisualization)

                // Visualisation associée à la question. Elle reste instanciée
                // en permanence — seule son opacité change — donc ses réglages
                // (slider, fonction sélectionnée, etc.) ne sont pas perdus quand
                // on va relire la question puis qu'on y revient.
                //
                // .id(vm.currentQuestion.id) force en revanche une réinitialisation
                // propre dès qu'on passe à une VRAIE nouvelle question (et donc,
                // potentiellement, une nouvelle visualisation).
                VisualizationView(
                    type: vm.currentQuestion.visualization,
                    hint: vm.currentQuestion.hint,
                    hintRevealed: vm.hasAnswered
                )
                    .id(vm.currentQuestion.id)
                    .padding()
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
