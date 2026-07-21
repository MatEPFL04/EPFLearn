//
//  TutorViewModel.swift
//  EPFLearn
//
//  Created by Mat on 19.07.2026.
//

import Foundation

@Observable
class TutorViewModel {
    struct Msg: Identifiable {
        let id = UUID()
        let role: String   // "user" | "assistant"
        var text: String
    }

    let question: Question
    let studentChoice: Int

    var messages: [Msg]
    var input = ""
    var isStreaming = false
    var errorText: String?

    private let service = ClaudeService()

    init(question: Question, studentChoice: Int) {
        self.question = question
        self.studentChoice = studentChoice
        messages = [Msg(
            role: "assistant",
            text: "You picked \"\(question.options[studentChoice])\". "
                + "Let's work through it together, what led you to that answer?"
        )]
    }

    private var systemPrompt: String {
        let optionsList = question.options.enumerated()
            .map { "\($0.offset). \($0.element)" }
            .joined(separator: "\n")

        return """
        You are a Socratic tutor for a first-year EPFL student (calculus / algorithms). \
        You help them understand THEIR OWN mistake on a multiple-choice question.

        Question: \(question.text)
        Options:
        \(optionsList)
        Correct answer (index): \(question.correctIndex)
        Student's chosen answer (index): \(studentChoice)
        Reference explanation: \(question.explanation)

        ABSOLUTE RULES:
        - NEVER reveal which option is correct — not its number, not its text. \
        The student must reach it themselves.
        - Guide with questions and progressive hints: gentle first, more specific only if \
        they're truly stuck.
        - Start from their specific error — why their reasoning led them to that option.
        - Keep replies short (2-4 sentences), friendly and encouraging.
        - If they ask for the answer directly, decline warmly and ask a question that steers them.
        """
    }

    @MainActor
    func send() async {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isStreaming else { return }

        messages.append(Msg(role: "user", text: trimmed))
        input = ""
        errorText = nil
        isStreaming = true

        // L'API exige que l'historique commence par "user" → on retire l'accueil.
        var history = messages.map { ClaudeMessage(role: $0.role, text: $0.text) }
        while history.first?.role == "assistant" { history.removeFirst() }

        // Bulle assistant vide qu'on remplit au fil des morceaux.
        messages.append(Msg(role: "assistant", text: ""))
        let replyIndex = messages.count - 1

        do {
            for try await chunk in service.streamMessage(system: systemPrompt, messages: history) {
                messages[replyIndex].text += chunk        // ← s'affiche mot par mot
            }
        } catch {
            if messages[replyIndex].text.isEmpty {
                messages.remove(at: replyIndex)
            }
            errorText = "Couldn't connect. Try again."
        }
        isStreaming = false
    }
}
