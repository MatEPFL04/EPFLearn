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

    private let frames: [Frame] = [
        Frame(line: -1, highlight: nil, calledMethod: nil, result: nil,
              note: "Shape only declares what every shape must offer, not how"),
        Frame(line: 1, highlight: nil, calledMethod: nil, result: nil,
              note: "abstract area() has no body, so Shape alone is incomplete: Java refuses 'new Shape()'"),
        Frame(line: 4, highlight: .circle, calledMethod: nil, result: nil,
              note: "Circle extends Shape and writes its own area(): π · r²"),
        Frame(line: 7, highlight: .square, calledMethod: nil, result: nil,
              note: "Square extends Shape and writes a different area(): s · s"),
        Frame(line: 10, highlight: .circle, calledMethod: "Circle.area()", result: "12.56",
              note: "watch: sh is declared as Shape, but Java checks the real object first. It's a Circle, so Circle's area() runs"),
        Frame(line: 10, highlight: .square, calledMethod: "Square.area()", result: "9.00",
              note: nil)
    ]

    private var total: Int { frames.count - 1 }
    private var fr: Frame { frames[min(step, total)] }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PBHeader("Abstraction")

            PBAdaptive {
                stage
            } code: {
                PBCodePane(lines: code.map { PBCodePane.Line(code: $0) },
                           current: fr.line, accent: PB.num, maxVisibleLines: 12)
                    .pbViewport()
            }

            PBStepper(step: $step, total: total, accent: PB.num)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(.systemGroupedBackground))
    }

    private var stage: some View {
        VStack(spacing: 10) {
            dispatchRow

            HStack(spacing: 10) {
                blueprint(.circle)
                blueprint(.square)
            }
        }
        .padding(14)
        .frame(minHeight: 190)
        .pbViewport()
        .overlay(alignment: .bottomLeading) {
            if let note = fr.note { PBNote(text: note).padding(9) }
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
            Text(card.name)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(active ? card.color : .primary.opacity(0.4))
            Text("extends Shape")
                .font(.system(size: 8, design: .monospaced))
                .foregroundColor(.primary.opacity(0.3))
            Text("area() = \(card.formula)")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundColor(active ? card.color : .primary.opacity(0.35))
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
