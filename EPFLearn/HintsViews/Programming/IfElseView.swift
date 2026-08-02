//
//  IfElseView.swift
//  EPFLearn
//
//  One idea: an if / else-if chain is evaluated top-down,
//  the first true condition wins, everything below is never touched.
//  The trace visits every executed line; dead branches dim at the end.
//

import SwiftUI

struct IfElseView: View {
    @State private var score = 72
    @State private var step = 0

    private var code: [String] {
        [
            "int score = \(score);",
            "String grade;",
            "if (score >= 90) {",
            "    grade = \"A\";",
            "} else if (score >= 75) {",
            "    grade = \"B\";",
            "} else if (score >= 60) {",
            "    grade = \"C\";",
            "} else {",
            "    grade = \"F\";",
            "}"
        ]
    }

    private var winner: Int {
        if score >= 90 { return 0 }
        if score >= 75 { return 1 }
        if score >= 60 { return 2 }
        return 3
    }

    private var seq: [Int] {
        var s = [0, 1]
        for i in 0..<min(winner + 1, 3) { s.append(2 + 2 * i) }
        if winner < 3 { s.append(3 + 2 * winner) }
        else { s.append(8); s.append(9) }
        return s
    }

    private var total: Int { seq.count + 1 }
    private var currentLine: Int {
        guard step >= 1, step <= seq.count else { return -1 }
        return seq[step - 1]
    }
    private var done: Bool { step == total }

    private var grade: String { ["A", "B", "C", "F"][winner] }
    private var gradeColor: Color { [Color.green, .cyan, PB.num, .pink][winner] }

    private var note: String {
        switch currentLine {
        case 0: return "score = \(score)"
        case 1: return "grade is declared, but not assigned yet"
        case 2: return "checking score >= 90 -> \(score >= 90)"
        case 3: return "true -> grade = \"A\". Java never even looks at the else-ifs below"
        case 4: return "score >= 90 was false, so check the next one: score >= 75 -> \(score >= 75)"
        case 5: return "true -> grade = \"B\". the remaining else-ifs are skipped"
        case 6: return "score >= 75 was false too, so check: score >= 60 -> \(score >= 60)"
        case 7: return "true -> grade = \"C\""
        case 8: return "every condition above was false, so this falls into the final else"
        case 9: return "grade = \"F\""
        default:
            if done { return "grade = \"\(grade)\": once a branch runs, the rest of the chain is skipped" }
            return "nothing has run yet, press ▸ to start"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PBHeader("If / Else")

            PBScrub(label: "score", value: $score, range: 0...100, accent: .cyan) {
                step = 0
            }

            PBAdaptive {
                gradePanel
            } code: {
                PBCodePane(lines: paneLines, current: currentLine, accent: .cyan)
                    .pbViewport()
            }

            PBStepper(step: $step, total: total, accent: .cyan)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(.systemGroupedBackground))
    }

    private var gradePanel: some View {
        VStack(spacing: 10) {
            HStack {
                PBChip(label: "score", value: "\(score)")
                Spacer()
                if done { PBChip(label: "grade", value: "\"\(grade)\"", color: gradeColor, hot: true) }
            }
            ZStack {
                Circle()
                    .fill(done ? gradeColor.opacity(0.15) : Color.primary.opacity(0.05))
                    .frame(width: 88, height: 88)
                Text(done ? grade : "?")
                    .font(.system(size: 42, weight: .black, design: .monospaced))
                    .foregroundColor(done ? gradeColor : .primary.opacity(0.25))
                    .shadow(color: done ? gradeColor.opacity(0.6) : .clear, radius: 12)
                    .contentTransition(.numericText())
            }
            // threshold ladder
            VStack(spacing: 4) {
                ladderRow("A", ">= 90", 0)
                ladderRow("B", ">= 75", 1)
                ladderRow("C", ">= 60", 2)
                ladderRow("F", "else", 3)
            }
        }
        .padding(.horizontal, 14).padding(.top, 14).padding(.bottom, 38)
        .frame(maxWidth: .infinity)
        .pbViewport()
        .overlay(alignment: .bottomLeading) {
            PBNote(text: note).padding(9)
        }
        .animation(.spring(duration: 0.3), value: step)
    }

    private func ladderRow(_ g: String, _ cond: String, _ idx: Int) -> some View {
        let isWinner = done && winner == idx
        let color: Color = [Color.green, .cyan, PB.num, .pink][idx]
        return HStack {
            Text(g).font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(isWinner ? color : .primary.opacity(0.5))
                .frame(width: 18)
            Text(cond).font(.system(size: 11, design: .monospaced))
                .foregroundColor(.primary.opacity(0.45))
            Spacer()
            if isWinner {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12)).foregroundColor(color)
            }
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(RoundedRectangle(cornerRadius: 8)
            .fill(isWinner ? color.opacity(0.14) : .clear))
    }

    private var paneLines: [PBCodePane.Line] {
        code.indices.map { i in
            var line = PBCodePane.Line(code: code[i])
            if let ci = conditionIndex(ofLine: i), ci < min(winner + 1, 3) {
                let frameOfCond = 2 + ci
                if step > frameOfCond {
                    let isTrue = ci == winner
                    line.badge = PBBadge(text: isTrue ? "true" : "false",
                                         color: isTrue ? .green : .pink)
                }
            }
            if done, (2...9).contains(i), !seq.contains(i) { line.dimmed = true }
            return line
        }
    }

    private func conditionIndex(ofLine i: Int) -> Int? {
        switch i { case 2: return 0; case 4: return 1; case 6: return 2; default: return nil }
    }
}

#Preview { IfElseView() }
