//
//  QuizViewModel.swift
//  EPFLearn
//
//  Created by Mat on 04.04.2026.
//

import Foundation

@Observable
class QuizViewModel {
    var questions: [Question] = Question.sampleQuestions
    var currentIndex: Int = 0
    var selectedAnswer: Int? = nil
    var score: Int = 0
    var isFinished: Bool = false
    
    var currentQuestion: Question {
        questions[currentIndex]
    }
    
    var hasAnswered: Bool {
        selectedAnswer != nil
    }
    
    func selectAnswer(_ index: Int) {
        guard !hasAnswered else { return }
        selectedAnswer = index
        if index == currentQuestion.correctIndex {
            score += 1
        }
    }
    
    func nextQuestion() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            selectedAnswer = nil
        } else {
            isFinished = true
        }
    }
    
    func restart() {
        currentIndex = 0
        score = 0
        selectedAnswer = nil
        isFinished = false
    }
}
