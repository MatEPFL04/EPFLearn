
import Foundation
import SwiftUI

struct QuestionView: View {

    var vm: QuizViewModel
    @State private var hintRevealed = false
    

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    Text(vm.currentQuestion.text)
                        .font(.title3)
                        .fontWeight(.medium)
                        .fixedSize(horizontal: false, vertical: true)

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
                            .fixedSize(horizontal: false, vertical: true)
                            .padding()
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    if vm.hasAnswered {
                        OptionButton(text: "Prochaine question", state: .idle, action: { vm.nextQuestion() })
                    }
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: VisualizationView(type: vm.currentQuestion.visualization,
                                                                  hint: vm.currentQuestion.hint,
                                                                  hintRevealed: true),
                                   label: { Text("Hint") })
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
