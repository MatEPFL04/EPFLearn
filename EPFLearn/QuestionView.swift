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

    private static let letters = ["A", "B", "C", "D", "E", "F"]

    private var isCorrect: Bool { vm.selectedAnswer == vm.currentQuestion.correctIndex }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        questionCard

                        ForEach(Array(vm.currentQuestion.options.enumerated()), id: \.offset) { index, option in
                            OptionButton(
                                text: option,
                                state: buttonState(for: index),
                                action: { vm.selectAnswer(index) },
                                letter: Self.letters[index % Self.letters.count]
                            )
                        }

                        if vm.hasAnswered {
                            explanationCard
                            nextButton
                        }
                    }
                    .frame(maxWidth: 700, alignment: .leading)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .animation(.spring(response: 0.32, dampingFraction: 0.85), value: vm.hasAnswered)
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
            .background(Color(.systemGroupedBackground))
            .toolbar {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { showVisualization.toggle() }
                } label: {
                    Label(showVisualization ? "Question" : "Hint",
                          systemImage: showVisualization ? "text.alignleft" : "lightbulb.fill")
                }
                .tint(showVisualization ? .blue : .orange)
            }
        }
    }

    /// The question used to be loose text at the top of the scroll view, which
    /// read as a caption next to the tinted hint and option cards. It now wears
    /// the same badge-and-card treatment, with the run's progress on it.
    private var questionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "questionmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 22, height: 22)
                    .background(Circle().fill(.blue))

                Text("QUESTION")
                    .font(.system(size: 11, weight: .heavy))
                    .kerning(1.2)
                    .foregroundStyle(.blue)

                Spacer(minLength: 0)

                Text("\(vm.currentIndex + 1) / \(vm.totalQuestions)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            progressBar

            QuestionBodyText(text: vm.currentQuestion.text)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue.opacity(0.10))
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16)
            .strokeBorder(.blue.opacity(0.30), lineWidth: 1))
    }

    private var progressBar: some View {
        GeometryReader { geo in
            let total = max(vm.totalQuestions, 1)
            let done = Double(vm.currentIndex) / Double(total)
            let current = Double(vm.currentIndex + 1) / Double(total)
            ZStack(alignment: .leading) {
                Capsule().fill(.blue.opacity(0.15))
                // The current question is drawn paler than the ones already
                // answered: progress you have earned versus progress you are on.
                Capsule().fill(.blue.opacity(0.35))
                    .frame(width: geo.size.width * current)
                Capsule().fill(.blue)
                    .frame(width: geo.size.width * done)
            }
        }
        .frame(height: 4)
        .animation(.spring(response: 0.4, dampingFraction: 0.9), value: vm.currentIndex)
    }

    private var explanationCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: isCorrect ? "checkmark" : "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 22, height: 22)
                    .background(Circle().fill(isCorrect ? Color.green : Color.red))

                Text(isCorrect ? "CORRECT" : "NOT QUITE")
                    .font(.system(size: 11, weight: .heavy))
                    .kerning(1.2)
                    .foregroundStyle(isCorrect ? .green : .red)

                Spacer(minLength: 0)
            }

            Text(vm.currentQuestion.explanation)
                .font(.callout)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background((isCorrect ? Color.green : Color.red).opacity(0.10))
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14)
            .strokeBorder((isCorrect ? Color.green : Color.red).opacity(0.30), lineWidth: 1))
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private var nextButton: some View {
        Button {
            vm.nextQuestion()
        } label: {
            HStack(spacing: 6) {
                Text(vm.currentIndex + 1 < vm.totalQuestions ? "Next question" : "See results")
                    .fontWeight(.semibold)
                Image(systemName: "arrow.right")
                    .font(.system(size: 13, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.blue)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
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
