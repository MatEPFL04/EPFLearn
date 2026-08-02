//
//  FunctionView.swift
//  EPFLearn
//
//  One idea: Java passes by value. The parameter `a` is its OWN box that
//  happens to share the caller's name - mutating it (x2, then +100) never
//  touches the caller's a. Only `return` carries a value back.
//

import SwiftUI

struct FunctionView: View {
    @State private var step = 0

    private let code = [
        "static int twice(int a) {",
        "    a = a * 2;",
        "    a = a + 100;",
        "    return a;",
        "}",
        "",
        "int a = 7;",
        "int b = twice(a);"
    ]

    private struct Frame { let line: Int; let note: String? }

    private let frames: [Frame] = [
        Frame(line: -1, note: nil),
        Frame(line: 6, note: nil),
        Frame(line: 7, note: "twice(a) is called, about to enter the function"),
        Frame(line: 0, note: "enter: parameter a is created and gets a copy of 7"),
        Frame(line: 1, note: "a = a * 2 -> 14  (the parameter, not caller's a)"),
        Frame(line: 2, note: "a = a + 100 -> 114"),
        Frame(line: 3, note: "return sends 114 back"),
        Frame(line: 7, note: "now b receives it: b = 114 ; caller's a is still 7"),
        Frame(line: -1, note: "same name, different boxes: caller untouched")
    ]

    private var total: Int { frames.count - 1 }
    private var fr: Frame { frames[min(step, total)] }

    private var callerA: Int? { step >= 1 ? 7 : nil }
    private var bVal: Int? { step >= 7 ? 114 : nil }
    private var paramA: Int? {
        switch step {
        case 3: return 7
        case 4: return 14
        case 5, 6: return 114
        default: return nil
        }
    }
    // The function zone is only "live" once we have stepped into it (step 3+).
    private var paramAlive: Bool { (3...6).contains(step) }
    private var copyArrow: Bool { step == 3 }
    private var returnArrow: Bool { (6...7).contains(step) }
    private var callerSteady: Bool { (4...6).contains(step) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PBHeader("Functions")

            PBAdaptive {
                stage
            } code: {
                PBCodePane(lines: code.map { PBCodePane.Line(code: $0) },
                           current: fr.line, accent: PB.num)
                    .pbViewport()
            }

            PBStepper(step: $step, total: total, accent: PB.num)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(.systemGroupedBackground))
    }

    private var stage: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let aP = CGPoint(x: w * 0.28, y: 38)
            let bP = CGPoint(x: w * 0.66, y: 38)
            let xP = CGPoint(x: w * 0.47, y: 166)

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(PB.num.opacity(paramAlive ? 0.55 : 0.18),
                                  style: StrokeStyle(lineWidth: 1.2, dash: [5]))
                    .background(RoundedRectangle(cornerRadius: 12)
                        .fill(PB.num.opacity(paramAlive ? 0.05 : 0.015)))
                    .frame(width: w * 0.64, height: 100)
                    .position(x: w * 0.47, y: 166)

                Text("int twice(int a)")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundColor(PB.num.opacity(paramAlive ? 0.9 : 0.35))
                    .position(x: w * 0.47, y: 130)

                Canvas { ctx, _ in
                    if copyArrow {
                        drawArrow(ctx, from: CGPoint(x: aP.x, y: aP.y + 30),
                                  to: CGPoint(x: xP.x - 16, y: xP.y - 30), color: .cyan)
                    }
                    if returnArrow {
                        drawArrow(ctx, from: CGPoint(x: xP.x + 16, y: xP.y - 30),
                                  to: CGPoint(x: bP.x, y: bP.y + 30), color: .green)
                    }
                }

                if copyArrow {
                    tag("copy 7", .cyan)
                        .position(x: (aP.x + xP.x) / 2 - 30, y: (aP.y + xP.y) / 2)
                        .transition(.opacity)
                }
                if returnArrow {
                    tag("return 114", .green)
                        .position(x: (bP.x + xP.x) / 2 + 34, y: (bP.y + xP.y) / 2)
                        .transition(.opacity)
                }

                box(name: "a", scope: "caller", value: callerA, color: .cyan,
                    hot: step == 1, steady: callerSteady).position(aP)
                box(name: "b", scope: "caller", value: bVal, color: .green,
                    hot: step == 7).position(bP)
                box(name: "a", scope: "param", value: paramA, color: PB.num,
                    hot: step == 3 || step == 4 || step == 5)
                    .position(xP).opacity(paramAlive ? 1 : 0)
            }
            .animation(.spring(duration: 0.3), value: step)
        }
        .frame(height: 232)
        .pbViewport()
        .overlay(alignment: .bottomLeading) {
            if let note = fr.note { PBNote(text: note).padding(9) }
        }
    }

    private func box(name: String, scope: String, value: Int?, color: Color,
                     hot: Bool, steady: Bool = false) -> some View {
        VStack(spacing: 3) {
            HStack(spacing: 4) {
                Text(name).font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
                Text(scope).font(.system(size: 8, design: .monospaced))
                    .foregroundColor(.primary.opacity(0.3))
            }
            Text(value.map(String.init) ?? "·")
                .font(.system(size: 19, weight: .bold, design: .monospaced))
                .foregroundColor(value == nil ? .primary.opacity(0.2) : .primary)
                .contentTransition(.numericText())
                .frame(width: 62, height: 40)
                .background(RoundedRectangle(cornerRadius: 9).fill(color.opacity(value == nil ? 0.05 : 0.16)))
                .overlay(RoundedRectangle(cornerRadius: 9)
                    .strokeBorder(steady ? Color.green : color.opacity(hot ? 1 : (value == nil ? 0.2 : 0.45)),
                                  style: StrokeStyle(lineWidth: hot || steady ? 2 : 1,
                                                     dash: value == nil ? [4] : [])))
                .shadow(color: hot ? color.opacity(0.7) : .clear, radius: 8)
            if steady {
                Text("unchanged")
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundColor(.green)
                    .transition(.opacity)
            }
        }
    }

    private func tag(_ text: String, _ color: Color) -> some View {
        Text(text).font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundColor(color)
            .padding(.horizontal, 7).padding(.vertical, 3)
            .background(.thinMaterial, in: Capsule())
            .overlay(Capsule().strokeBorder(color.opacity(0.6), lineWidth: 1))
    }

    private func drawArrow(_ ctx: GraphicsContext, from: CGPoint, to: CGPoint, color: Color) {
        let ctrl = CGPoint(x: (from.x + to.x) / 2 + (to.x > from.x ? -26 : 26), y: (from.y + to.y) / 2)
        var path = Path()
        path.move(to: from); path.addQuadCurve(to: to, control: ctrl)
        ctx.stroke(path, with: .color(color.opacity(0.9)), style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
        let ang = atan2(to.y - ctrl.y, to.x - ctrl.x)
        var head = Path()
        head.move(to: to)
        head.addLine(to: CGPoint(x: to.x - 9 * cos(ang - 0.45), y: to.y - 9 * sin(ang - 0.45)))
        head.move(to: to)
        head.addLine(to: CGPoint(x: to.x - 9 * cos(ang + 0.45), y: to.y - 9 * sin(ang + 0.45)))
        ctx.stroke(head, with: .color(color.opacity(0.9)), style: StrokeStyle(lineWidth: 2, lineCap: .round))
    }
}

#Preview { FunctionView() }
