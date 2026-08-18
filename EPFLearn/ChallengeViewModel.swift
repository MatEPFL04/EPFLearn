//
//  ChallengeViewModel.swift
//  EPFLearn
//
//  Drives an inverted run. The figure reports its state continuously, but
//  nothing is graded until the student commits with `check()`: sweeping a
//  drag through the answer must not count as knowing it. Mirrors
//  QuizViewModel closely enough that a finished run stores the same way.
//

import Foundation
import SwiftUI

@Observable
class ChallengeViewModel {

    /// How many wrong commits before the run stops asking the student to
    /// keep guessing and offers the worked example instead.
    static let maxAttempts = 3

    private(set) var challenges: [Challenge] = []
    var currentIndex: Int = 0
    var isFinished: Bool = false

    /// The figure as it stands. Never auto-solves anything.
    var feedback: ChallengeFeedback = .waiting
    /// The last thing the figure actually said. `check()` re-evaluates from
    /// this rather than trusting `feedback`, which could have been computed
    /// against an earlier challenge or an earlier layout pass.
    private var lastReading: ChallengeReading = .idle

    var resolved: Bool = false
    var revealedCurrent: Bool = false
    var attempts: Int = 0
    /// Set by a failed commit, cleared as soon as the figure moves again, so
    /// the message belongs to the state it was actually about.
    var lastCommitFailed: Bool = false

    /// Indices solved without revealing, for the summary.
    var solvedIndices: [Int] = []

    var category: Subject? = nil
    var lastResult: ResultQCM? = nil
    var onComplete: ((ResultQCM) -> Void)?

    var currentChallenge: Challenge? {
        challenges.indices.contains(currentIndex) ? challenges[currentIndex] : nil
    }

    var totalChallenges: Int { challenges.count }
    var attemptsExhausted: Bool { attempts >= Self.maxAttempts }

    func start(_ subject: Subject) {
        challenges = Challenge.challenges(for: subject)
        category = subject
        restart()
    }

    func retry() {
        start(category ?? .analysis)
    }

    /// Called by the hosted figure every time the student moves it. Records
    /// what the figure now reads; deliberately does not decide anything.
    func report(_ reading: ChallengeReading) {
        guard let challenge = currentChallenge, !resolved else { return }
        lastReading = reading
        feedback = challenge.evaluate(reading)
        lastCommitFailed = false
    }

    /// The student claims the figure is right. This is the only place a
    /// challenge can be solved. Re-evaluates from the stored reading: an
    /// earlier version trusted the cached `feedback`, so a figure whose state
    /// had not changed since a failed attempt kept answering with the verdict
    /// from that attempt.
    func check() {
        guard !resolved, let challenge = currentChallenge else { return }
        let verdict = challenge.evaluate(lastReading)
        feedback = verdict
        if verdict.satisfied {
            resolved = true
            solvedIndices.append(currentIndex)
        } else {
            attempts += 1
            lastCommitFailed = true
        }
    }

    /// Gives up on the current figure. The worked example is still worth
    /// reading, but the challenge is not counted as solved.
    func reveal() {
        revealedCurrent = true
        resolved = true
    }

    func next() {
        if currentIndex + 1 < challenges.count {
            currentIndex += 1
            resolved = false
            revealedCurrent = false
            attempts = 0
            lastCommitFailed = false
            feedback = .waiting
            lastReading = .idle
        } else {
            let res = ResultQCM(category: category ?? .analysis,
                                nbQuestions: challenges.count,
                                correctAnswers: solvedIndices,
                                nbCorrectAnswers: solvedIndices.count)
            lastResult = res
            onComplete?(res)
            isFinished = true
        }
    }

    func restart() {
        currentIndex = 0
        resolved = false
        revealedCurrent = false
        attempts = 0
        lastCommitFailed = false
        solvedIndices = []
        feedback = .waiting
        lastReading = .idle
        isFinished = false
        lastResult = nil
    }
}
