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
        Button(action: action) {
            Text(text)
                .frame(maxWidth: .infinity)
                .padding()
                .background(backgroundColor)
                .foregroundStyle(foregroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .disabled(state != .idle)
    }
    
    var backgroundColor: Color {
           switch state {
           case .idle: return Color(.systemBackground)
           case .correct: return .green.opacity(0.15)
           case .wrong: return .red.opacity(0.15)
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

