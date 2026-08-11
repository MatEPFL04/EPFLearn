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
    
    var body: some View {
        Button(action: { if state == .idle { action() } }) {
            Text(text)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(borderColor, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .foregroundStyle(foregroundColor)
    }

    var backgroundColor: Color {
           switch state {
           case .idle: return Color(.secondarySystemBackground)
           case .correct: return .green.opacity(0.15)
           case .wrong: return .red.opacity(0.15)
           }
       }

       var borderColor: Color {
           switch state {
           case .idle: return Color.primary.opacity(0.15)
           case .correct: return .green.opacity(0.4)
           case .wrong: return .red.opacity(0.4)
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
    OptionButton(text: "test", state: .correct, action: {})
}

