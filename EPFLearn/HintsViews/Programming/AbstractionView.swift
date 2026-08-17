//
//  AbstractionView.swift
//  EPFLearn
//
//  One idea: Shape only promises that area() exists, not how it's computed.
//  Circle and Square each supply their own body. The call site - sh.area() -
//  never changes, yet it resolves to a different method every time, because
//  Java looks at sh's real, runtime class rather than its declared type.
//

import SwiftUI

struct AbstractionView: View {
    @State private var step = 0

    private let code = [
        "abstract class Shape {",
        "    abstract double area();",
        "}",
        "class Circle extends Shape {",
        "    double area() { return Math.PI*r*r; }",
        "}",
        "class Square extends Shape {",
        "    double area() { return s*s; }",
        "}",
        "for (Shape sh : shapes) {",
        "    sh.area();",
        "}"
    ]

    /// The loop header and the one call site inside it.
    private let loopLine = 9
    private let callLine = 10

    private enum Card: Equatable {
        case circle, square

        var name: String { self == .circle ? "Circle" : "Square" }
        var formula: String { self == .circle ? "π · r²" : "s · s" }
        var color: Color {
            self == .circle ? .cyan : Color(red: 0.72, green: 0.52, blue: 1.0)
        }
    }

    private struct Frame {
        let line: Int
        let highlight: Card?
        let calledMethod: String?
        let result: String?
        let note: String?
    }

    private var frames: [Frame] {
        [
            Frame(line: -1, highlight: nil, calledMethod: nil, result: nil,
                  note: "Shape says what, not how"),
            Frame(line: 1, highlight: nil, calledMethod: nil, result: nil,
                  note: "no body → new Shape() is refused"),
            Frame(line: 4, highlight: .circle, calledMethod: nil, result: nil,
                  note: "Circle writes its own area()"),
            Frame(line: 7, highlight: .square, calledMethod: nil, result: nil,
                  note: "Square writes a different area()"),
            // The loop header gets its own frame before each call: the point is
            // that one call site is reached twice, with sh bound differently.
            Frame(line: loopLine, highlight: .circle, calledMethod: nil, result: nil,
                  note: "pass 1: sh is the Circle"),
            Frame(line: callLine, highlight: .circle, calledMethod: "Circle.area()", result: "12.56",
                  note: "sh is a Circle → Circle.area() runs"),
            Frame(line: loopLine, highlight: .square, calledMethod: nil, result: nil,
                  note: "pass 2: sh is the Square"),
            Frame(line: callLine, highlight: .square, calledMethod: "Square.area()", result: "9.00",
                  note: "same line, the real object picks the body"),
        ]
    }

    private var total: Int { frames.count - 1 }
    private var fr: Frame { frames[min(step, total)] }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            PBHeader("Abstraction")

            PBAdaptive {
                stage
            } code: {
                PBCodePane(lines: paneLines, current: fr.line,
                           accent: PB.num, maxVisibleLines: 9)
                    .pbViewport()
            }

            PBStepper(step: $step, total: total, accent: PB.num)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(.systemGroupedBackground))
    }

    private var paneLines: [PBCodePane.Line] {
        code.map { PBCodePane.Line(code: $0) }
    }

    private var stage: some View {
        VStack(spacing: 10) {
            dispatchRow

            HStack(spacing: 10) {
                blueprint(.circle)
                blueprint(.square)
            }
        }
        .padding(10)
        .frame(minHeight: 150)
        .pbViewport()
        .overlay(alignment: .bottomLeading) {
            if let note = fr.note { PBNote(text: note).padding(7) }
        }
        .animation(.spring(duration: 0.3), value: step)
    }

    /// The heart of the view: the same call, sh.area(), resolving to a
    /// different concrete method every time.
    private var dispatchRow: some View {
        let color = fr.highlight?.color ?? .primary
        return HStack(spacing: 10) {
            Text("sh.area()")
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 9).fill(.primary.opacity(0.06)))

            Image(systemName: "arrow.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(fr.calledMethod == nil ? .primary.opacity(0.25) : color)

            HStack(spacing: 6) {
                Text(fr.calledMethod ?? "?")
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                if let result = fr.result {
                    Text("= \(result)")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .opacity(0.8)
                }
            }
            .foregroundColor(fr.calledMethod == nil ? .primary.opacity(0.3) : color)
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 9).fill(color.opacity(fr.calledMethod == nil ? 0.04 : 0.16)))
            .overlay(RoundedRectangle(cornerRadius: 9)
                .strokeBorder(color.opacity(fr.calledMethod == nil ? 0.15 : 0.9),
                              lineWidth: fr.calledMethod == nil ? 1 : 1.6))

            Spacer(minLength: 0)
        }
    }

    private func blueprint(_ card: Card) -> some View {
        let active = fr.highlight == card
        return VStack(spacing: 6) {
            // Tinted rather than grey when idle: three shades of grey on one
            // card read as disabled, not as "not the one running right now".
            Text(card.name)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(card.color.opacity(active ? 1 : 0.6))
            Text("extends Shape")
                .font(.system(size: 8, design: .monospaced))
                .foregroundColor(card.color.opacity(active ? 0.7 : 0.45))
            Text("area() = \(card.formula)")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundColor(card.color.opacity(active ? 1 : 0.55))
                .padding(.top, 2)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 10).padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 10).fill(card.color.opacity(active ? 0.16 : 0.04)))
        .overlay(RoundedRectangle(cornerRadius: 10)
            .strokeBorder(card.color.opacity(active ? 1 : 0.2),
                          style: StrokeStyle(lineWidth: active ? 2 : 1, dash: active ? [] : [4])))
        .shadow(color: active ? card.color.opacity(0.6) : .clear, radius: 8)
        .scaleEffect(active ? 1.03 : 1)
    }
}

#Preview { AbstractionView() }
