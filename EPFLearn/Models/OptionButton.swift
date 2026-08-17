//
//  OptionButton.swift
//  EPFLearn
//
//  Created by Mat on 04.04.2026.
//

import SwiftUI

struct OptionButton: View {

    enum AnswerState { case idle, correct, wrong }

    let text: String
    let state: AnswerState
    let action: () -> Void
    /// A, B, C … so an option can be referred to and scanned at a glance.
    var letter: String? = nil

    var body: some View {
        Button(action: { if state == .idle { action() } }) {
            HStack(alignment: .top, spacing: 12) {
                if let letter {
                    Text(letter)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(state == .idle ? Color.secondary : foregroundColor)
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(badgeColor))
                }

                Text(text)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let icon = resultIcon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(foregroundColor)
                }
            }
            .padding(14)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(borderColor, lineWidth: state == .idle ? 1 : 1.5)
            )
        }
        .buttonStyle(.plain)
        .foregroundStyle(foregroundColor)
    }

    private var resultIcon: String? {
        switch state {
        case .idle: return nil
        case .correct: return "checkmark.circle.fill"
        case .wrong: return "xmark.circle.fill"
        }
    }

    var badgeColor: Color {
        switch state {
        case .idle: return Color.primary.opacity(0.08)
        case .correct: return .green.opacity(0.22)
        case .wrong: return .red.opacity(0.22)
        }
    }

    var backgroundColor: Color {
        switch state {
        case .idle: return Color(.secondarySystemGroupedBackground)
        case .correct: return .green.opacity(0.15)
        case .wrong: return .red.opacity(0.15)
        }
    }

    var borderColor: Color {
        switch state {
        case .idle: return Color.primary.opacity(0.12)
        case .correct: return .green.opacity(0.45)
        case .wrong: return .red.opacity(0.45)
        }
    }

    var foregroundColor: Color {
        switch state {
        case .idle: return .primary
        case .correct: return .green
        case .wrong: return .red
        }
    }
}

#Preview {
    VStack(spacing: 10) {
        OptionButton(text: "An idle option", state: .idle, action: {}, letter: "A")
        OptionButton(text: "The correct one", state: .correct, action: {}, letter: "B")
        OptionButton(text: "The one you picked", state: .wrong, action: {}, letter: "C")
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
