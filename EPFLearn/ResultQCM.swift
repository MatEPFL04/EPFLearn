//
//  ResultQCM.swift
//  EPFLearn
//
//  Created by Mat on 09.04.2026.
//

import Foundation

struct ResultQCM: Hashable {
    let category: Subject
    var nbQuestions: Int
    var correctAnswers: [Int]
    var nbCorrectAnswers: Int
}
