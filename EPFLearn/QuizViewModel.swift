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
    
    var category: Subject?=nil
    
    var currentQuestion: Question {
        questions[currentIndex]
    }
    
    var hasAnswered: Bool {
        selectedAnswer != nil
    }
    
    func tapped(_ index: Int) {
        switch index {
        case 0:
            questions = Question.sampleQuestionsAnalysis()
            category = .analysis
        case 1:
            questions = Question.sampleQuestionsArrays()
            category = .arrays
        case 2:
            questions = Question.sampleQuestionsGraphs()
            category = .graphs
        case 3:
            questions = Question.sampleQuestionsDiscreteMaths()
            category = .discreteMaths
        case 4:
            questions = Question.sampleQuestionsLinearAlgebra()
            category = .linearAlgebra
        case 5:
            questions = Question.sampleQuestionsProgrammingBasics()
            category = .programmingBasics
        default:
            questions = Question.sampleQuestionsAnalysis()
            category = .analysis
        }
        restart()
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
            let res = ResultQCM(category: category!,nbQuestions: currentIndex + 1, correctAnswers: correctAnswers, nbCorrectAnswers: score)
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
        
        
    }
}
