//
//  PBKit.swift
//  EPFLearn
//
//  Shared design kit for the Programming Basics visualizations.
//  Dark viewport + syntax-highlighted Java + debugger-style stepper,
//  matching the visual language of the 3D algebra views.
//

import SwiftUI

// MARK: - Palette

enum PB {
    static let panelTop = Color(.secondarySystemBackground)
    static let panelBottom = Color(.tertiarySystemBackground)

    static let kw = Color(red: 1.00, green: 0.44, blue: 0.62)      // keywords
    static let ty = Color(red: 0.40, green: 0.82, blue: 1.00)      // types
    static let num = Color(red: 1.00, green: 0.64, blue: 0.28)     // numbers
    static let str = Color(red: 0.48, green: 0.90, blue: 0.58)     // strings
    static let com = Color.secondary                               // comments
    static let plain = Color.primary.opacity(0.88)

    static let keywords: Set<String> = [
        "int", "static", "void", "return", "while", "for", "if", "else",
        "boolean", "double", "new", "true", "false", "null",
        "private", "public", "class", "interface", "abstract",
        "extends", "implements", "this"
    ]
    static let types: Set<String> = ["String", "System", "Scanner"]

    /// Minimal Java syntax highlighter → concatenated Text.
    static func java(_ line: String) -> Text {
        var out = Text(verbatim: "")
        var i = line.startIndex

        func emit(_ s: Substring, _ c: Color) {
            out = out + Text(verbatim: String(s)).foregroundColor(c)
        }

        while i < line.endIndex {
            let ch = line[i]
            if ch == "/" {
                let next = line.index(after: i)
                if next < line.endIndex, line[next] == "/" {
                    emit(line[i...], com)
                    break
                }
                emit(line[i...i], plain)
                i = next
            } else if ch == "\"" || ch == "'" {
                let quote = ch
                var j = line.index(after: i)
                while j < line.endIndex, line[j] != quote { j = line.index(after: j) }
                if j < line.endIndex { j = line.index(after: j) }
                emit(line[i..<j], str)
                i = j
            } else if ch.isLetter || ch == "_" {
                var j = i
                while j < line.endIndex, line[j].isLetter || line[j].isNumber || line[j] == "_" {
                    j = line.index(after: j)
                }
                let w = String(line[i..<j])
                emit(line[i..<j], keywords.contains(w) ? kw : (types.contains(w) ? ty : plain))
                i = j
            } else if ch.isNumber {
                var j = i
                while j < line.endIndex, line[j].isNumber { j = line.index(after: j) }
                emit(line[i..<j], num)
                i = j
            } else {
                emit(line[i...i], plain)
                i = line.index(after: i)
            }
        }
        return out
    }
}

// MARK: - Dark viewport container

extension View {
    func pbViewport() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(colors: [PB.panelTop, PB.panelBottom],
                               startPoint: .top, endPoint: .bottom)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Adaptive layout (iPhone stacked · iPad side-by-side)

/// Two panes that sit vertically on compact width (iPhone) and
/// horizontally on regular width (iPad / landscape). The stage is given
/// more room; the code column is capped so long lines stay readable.
struct PBAdaptive<Stage: View, Code: View>: View {
    @ViewBuilder var stage: Stage
    @ViewBuilder var code: Code

    @Environment(\.horizontalSizeClass) private var hClass

    var body: some View {
        if hClass == .regular {
            HStack(alignment: .top, spacing: 12) {
                stage.frame(maxWidth: .infinity)
                code.frame(width: 420)
            }
        } else {
            VStack(spacing: 10) { stage; code }
        }
    }
}

/// Title + optional trailing control on one row. A thin name for the app-wide
/// `VizHeader`, so the programming views open exactly like every other subject.
struct PBHeader<Trailing: View>: View {
    let title: String
    @ViewBuilder var trailing: Trailing

    var body: some View {
        VizHeader(title: title) { trailing }
    }
}

extension PBHeader where Trailing == EmptyView {
    init(_ title: String) { self.init(title: title) { EmptyView() } }
}

// MARK: - Code pane

struct PBBadge: Equatable {
    let text: String
    let color: Color
}

/// A fixed-height window onto the code, not the full snippet at full height.
/// Longer snippets (8-16 lines) used to push the stage + code + stepper
/// past one screen; now the pane caps at `maxVisibleLines` and auto-scrolls
/// to keep the current line centered as the step changes, so the canvas,
/// the code, and the stepper stay on screen together while scrubbing.
struct PBCodePane: View {
    struct Line {
        let code: String
        var dimmed: Bool = false
        var badge: PBBadge? = nil
    }

    let lines: [Line]
    let current: Int
    var accent: Color = .cyan
    var maxVisibleLines: Int = 9

    private let rowHeight: CGFloat = 21

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 1) {
                    ForEach(lines.indices, id: \.self) { i in
                        row(i).id(i)
                    }
                }
                .padding(7)
            }
            .frame(height: rowHeight * CGFloat(min(lines.count, maxVisibleLines)) + 14)
            .onAppear { scrollToCurrent(proxy, animated: false) }
            .onChange(of: current) { _ in scrollToCurrent(proxy, animated: true) }
        }
    }

    private func scrollToCurrent(_ proxy: ScrollViewProxy, animated: Bool) {
        guard !lines.isEmpty else { return }
        let target = (current >= 0 && current < lines.count) ? current : 0
        // Dispatched a tick late: calling scrollTo synchronously from
        // onChange/onAppear can fire before the ScrollView has finished
        // laying out its rows, so the very first scroll silently no-ops
        // and the highlighted line is left off-window.
        DispatchQueue.main.async {
            if animated {
                withAnimation(.easeInOut(duration: 0.25)) { proxy.scrollTo(target, anchor: .center) }
            } else {
                proxy.scrollTo(target, anchor: .center)
            }
        }
    }

    @ViewBuilder
    private func row(_ i: Int) -> some View {
        HStack(spacing: 10) {
            Text("\(i + 1)")
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(.primary.opacity(0.25))
                .frame(width: 13, alignment: .trailing)

            PB.java(lines[i].code)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer(minLength: 4)

            if let b = lines[i].badge {
                Text(b.text)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 7).padding(.vertical, 2)
                    .background(Capsule().fill(b.color.opacity(0.22)))
                    .foregroundColor(b.color)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 2)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(i == current ? accent.opacity(0.16) : .clear)
        )
        .overlay(alignment: .leading) {
            if i == current {
                Capsule().fill(accent).frame(width: 3)
            }
        }
        .opacity(lines[i].dimmed ? 0.28 : 1)
    }
}

// MARK: - Stepper
//
// A thin name for the app-wide StepSlider so the programming views keep
// reading in their own vocabulary. Dragging the slider is the only way to
// move: the play button that used to sit here advanced the code whether or
// not the student had finished reading the current line.

struct PBStepper: View {
    @Binding var step: Int
    let total: Int
    var accent: Color = .cyan
    /// One short line about the frame currently shown.
    var caption: String? = nil

    var body: some View {
        StepSlider(step: $step, total: total, accent: accent, caption: caption)
    }
}

// MARK: - HUD chip (dark)

struct PBChip: View {
    let label: String
    let value: String
    var color: Color = .cyan
    var hot: Bool = false

    var body: some View {
        HStack(spacing: 5) {
            Text(label)
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.thinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(color.opacity(hot ? 0.8 : 0), lineWidth: 1))
    }
}

// MARK: - HUD note (one terse line, Matrix3DView style)

struct PBNote: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 10, design: .monospaced))
            .foregroundColor(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 7))
    }
}

// MARK: - Parameter control
//
// Every number a student can change - the loop bound, the score, the bit
// offset - is edited with the same slider as the step, so there is exactly
// one gesture to learn in the whole app.

struct PBScrub: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    var accent: Color = .cyan
    var onEdit: () -> Void = {}

    var body: some View {
        StepSlider(label: label, value: $value, range: range,
                   accent: accent, onEdit: onEdit)
    }
}
