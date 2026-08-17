//
//  QuizViewModel.swift
//  EPFLearn
//
//  Created by Mat on 04.04.2026.
//

import Foundation
import SwiftUI

@Observable
class QuizViewModel {
    
    private var questions = Question.sampleQuestionsAnalysis()
    var currentIndex: Int = 0
    var selectedAnswer: Int? = nil
    
    var score: Int = 0
    var correctAnswers: [Int] = [Int]()
  
    var isFinished: Bool = false

    var onComplete: ((ResultQCM) -> Void)?

    /// The run that just ended, kept for the completion screen. `nextQuestion`
    /// zeroes the live score as soon as the quiz is over, so without this the
    /// results screen would have nothing left to show.
    var lastResult: ResultQCM? = nil

    var category: Subject?=nil
    
    var currentQuestion: Question {
        questions[currentIndex]
    }

    /// How many questions this run holds, for the progress bar in QuestionView.
    var totalQuestions: Int { questions.count }
    
    var hasAnswered: Bool {
        selectedAnswer != nil
    }
    
    func tapped(_ index: Int) {
        switch index {
        case 1:  start(.arrays)
        case 2:  start(.graphs)
        case 3:  start(.discreteMaths)
        case 4:  start(.linearAlgebra)
        case 5:  start(.programmingBasics)
        default: start(.analysis)
        }
    }

    /// Draws a fresh sample of questions for a subject and starts the run.
    func start(_ subject: Subject) {
        switch subject {
        case .analysis:          questions = Question.sampleQuestionsAnalysis()
        case .arrays:            questions = Question.sampleQuestionsArrays()
        case .graphs:            questions = Question.sampleQuestionsGraphs()
        case .discreteMaths:     questions = Question.sampleQuestionsDiscreteMaths()
        case .linearAlgebra:     questions = Question.sampleQuestionsLinearAlgebra()
        case .programmingBasics: questions = Question.sampleQuestionsProgrammingBasics()
        }
        category = subject
        restart()
    }

    /// Same subject, freshly drawn questions.
    func retry() {
        start(category ?? .analysis)
    }
    
    func selectAnswer(_ index: Int) {
        guard !hasAnswered else { return }
        selectedAnswer = index
        if index == currentQuestion.correctIndex {
            correctAnswers.append(currentIndex)
            score += 1
        }
    }
    
    func nextQuestion() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            selectedAnswer = nil
        } else {
            let res = ResultQCM(category: category ?? .analysis,
                                nbQuestions: currentIndex + 1,
                                correctAnswers: correctAnswers,
                                nbCorrectAnswers: score)
            lastResult = res
            onComplete?(res)
            isFinished = true
            correctAnswers = []
            score = 0
        }
    }
    
    func restart() {
        currentIndex = 0
        correctAnswers = []
        score = 0
        selectedAnswer = nil
        isFinished = false
        lastResult = nil
        
        
    }
}
