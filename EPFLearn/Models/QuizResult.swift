//
//  QuizResult.swift
//  EPFLearn
//
//  Created by Mat on 11.07.2026.
//
import SwiftData
import Foundation

import SwiftData

@Model
class QuizResult {
    var date: Date
    var score: Int
    var total: Int
    var userID: String  

    init(score: Int, total: Int, userID: String) {
        self.date = .now
        self.score = score
        self.total = total
        self.userID = userID
    }
}
