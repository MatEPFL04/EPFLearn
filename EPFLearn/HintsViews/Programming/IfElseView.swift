//
//  IfElseView.swift
//  EPFLearn
//
//  One idea: an if / else-if chain is evaluated top-down, the first true
//  condition wins, and everything below it is never even looked at.
//
//  The thresholds are deliberately not the ones used in the quiz: the rule is
//  what transfers, not the numbers.
//

import SwiftUI

struct IfElseView: View {

    @State private var score = 72
    @State private var step = 0

    private var code: [String] {
        ["int s = \(score);",
         "String g;",
         "if (s >= 85) {",
         "    g = \"A\";",
         "} else if (s >= 65) {",
         "    g = \"B\";",
         "} else if (s >= 40) {",
         "    g = \"C\";",
         "} else {",
         "    g = \"F\";",
         "}"]
    }

    private let cuts = [85, 65, 40]

    private var winner: Int {
        for (i, cut) in cuts.enumerated() where score >= cut { return i }
        return 3
    }

    /// Executed lines, in order: the declarations, every condition tested, and
    /// the single assignment that wins.
    private var seq: [Int] {
        var s = [0, 1]
        for i in 0..<min(winner + 1, 3) { s.append(2 + 2 * i) }
        if winner < 3 { s.append(3 + 2 * winner) } else { s.append(8); s.append(9) }
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
        case 0: return "s = \(score)"
        case 1: return "g declared, not assigned"
        case 2: return "s >= 85 → \(score >= 85)"
        case 3: return "true → g = \"A\"; the else-ifs below are never tested"
        case 4: return "s >= 65 → \(score >= 65)"
        case 5: return "true → g = \"B\"; the rest of the chain is skipped"
        case 6: return "s >= 40 → \(score >= 40)"
        case 7: return "true → g = \"C\""
        case 8: return "all conditions failed, so the final else runs"
        case 9: return "g = \"F\""
        default:
            return done ? "first match wins, the rest is skipped" : "drag the step slider to run"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            PBHeader("If / Else")

            PBScrub(label: "s", value: $score, range: 0...100, accent: .cyan) { step = 0 }

            PBAdaptive {
                panel
            } code: {
                PBCodePane(lines: paneLines, current: currentLine, accent: .cyan)
                    .pbViewport()
            }

            PBStepper(step: $step, total: total, accent: .cyan)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(.systemGroupedBackground))
    }

    private var panel: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(done ? gradeColor.opacity(0.15) : Color.primary.opacity(0.05))
                    .frame(width: 62, height: 62)
                Text(done ? grade : "?")
                    .font(.system(size: 30, weight: .black, design: .monospaced))
                    .foregroundColor(done ? gradeColor : .primary.opacity(0.25))
                    .contentTransition(.numericText())
            }

            VStack(spacing: 3) {
                ladderRow("A", ">= 85", 0)
                ladderRow("B", ">= 65", 1)
                ladderRow("C", ">= 40", 2)
                ladderRow("F", "else", 3)
            }
        }
        .padding(10)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity)
        .pbViewport()
        .overlay(alignment: .bottomLeading) { PBNote(text: note).padding(7) }
        .animation(.spring(duration: 0.28), value: step)
    }

    private func ladderRow(_ g: String, _ cond: String, _ idx: Int) -> some View {
        // Tested-and-failed conditions dim as the chain walks past them.
        let tested = step > 2 + idx && idx < min(winner + 1, 3)
        let isWinner = done && winner == idx
        let color: Color = [Color.green, .cyan, PB.num, .pink][idx]
        return HStack(spacing: 6) {
            Text(g).font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(isWinner ? color : .primary.opacity(0.5))
                .frame(width: 14)
            Text(cond).font(.system(size: 10, design: .monospaced))
                .foregroundColor(.primary.opacity(0.45))
            Spacer(minLength: 0)
            if isWinner {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 11)).foregroundColor(color)
            } else if tested {
                Text("false").font(.system(size: 9, design: .monospaced))
                    .foregroundColor(.pink.opacity(0.8))
            }
        }
        .padding(.horizontal, 8).padding(.vertical, 3)
        .background(RoundedRectangle(cornerRadius: 6)
            .fill(isWinner ? color.opacity(0.14) : .clear))
    }

    private var paneLines: [PBCodePane.Line] {
        code.indices.map { i in
            var line = PBCodePane.Line(code: code[i])
            if let ci = conditionIndex(ofLine: i), ci < min(winner + 1, 3), step > 2 + ci {
                let isTrue = ci == winner
                line.badge = PBBadge(text: isTrue ? "true" : "false", color: isTrue ? .green : .pink)
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
