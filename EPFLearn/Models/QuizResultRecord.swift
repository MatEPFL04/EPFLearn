import SwiftData
import Foundation

@Model
class QuizResultRecord {
    var date: Date = Date.now
    var categoryRaw: String = ""
    var nbQuestions: Int = 0
    var correctAnswers: [Int] = []
    var nbCorrectAnswers: Int = 0
    var userID: String = ""

    init(result: ResultQCM, userID: String) {
        self.date = .now
        self.categoryRaw = result.category.rawValue
        self.nbQuestions = result.nbQuestions
        self.correctAnswers = result.correctAnswers
        self.nbCorrectAnswers = result.nbCorrectAnswers
        self.userID = userID
    }

    var asResultQCM: ResultQCM? {
        guard let category = Subject(rawValue: categoryRaw) else { return nil }
        return ResultQCM(category: category, nbQuestions: nbQuestions, correctAnswers: correctAnswers, nbCorrectAnswers: nbCorrectAnswers)
    }
}
