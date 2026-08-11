//
//  QuestionBodyText.swift
//  EPFLearn
//
//  Created by Mat on 04.04.2026.
//

import SwiftUI

/// Renders a question's text, pulling embedded code lines (e.g. Java snippets in
/// Programming Basics questions) out into a monospaced code box so students can
/// visually separate "code to read" from "the actual question being asked".
struct QuestionBodyText: View {

    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Code always renders first, prose (the actual question) always last,
            // regardless of how the two were interleaved in the source text.
            if let codeText {
                Text(codeText)
                    .font(.system(.callout, design: .monospaced))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                    )
            }
            if let proseText {
                Text(proseText)
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var codeText: String? {
        let lines = text.components(separatedBy: "\n").filter { Self.looksLikeCode($0) }
        return lines.isEmpty ? nil : lines.joined(separator: "\n")
    }

    private var proseText: String? {
        let lines = text.components(separatedBy: "\n").filter { !Self.looksLikeCode($0) }
        return lines.isEmpty ? nil : lines.joined(separator: "\n")
    }

    private static let codePrefixes = [
        "int ", "int[", "long ", "double ", "boolean ", "char ", "String ",
        "static ", "public ", "private ", "void ", "class ",
        "for (", "for(", "while (", "while(", "if (", "if(", "else",
        "return", "System.out", "abstract ",
    ]

    private static func looksLikeCode(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }
        if trimmed.hasSuffix(";") || trimmed.hasSuffix("{") { return true }
        if trimmed == "}" || trimmed.hasPrefix("}") { return true }
        return codePrefixes.contains { trimmed.hasPrefix($0) }
    }
}

#Preview {
    QuestionBodyText(text: "What will be printed?\nint score = 75;\nif (score >= 90) {\n  System.out.println(\"A\");\n} else if (score >= 70) {\n  System.out.println(\"B\");\n} else {\n  System.out.println(\"C\");\n}")
        .padding()
}
