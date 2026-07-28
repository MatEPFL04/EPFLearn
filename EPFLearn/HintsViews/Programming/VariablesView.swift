//
//  VariablesView.swift
//  EPFLearn
//
//  One idea: copy semantics vs reference semantics.
//  Primitives copy their value. Arrays copy the reference — two names,
//  one object. The trace visits every executed line.
//

import SwiftUI

struct VariablesView: View {
    @State private var step = 0
    private let total = 6

    private let code = [
        "int a = 5;",
        "int b = a;",
        "b = b + 1;",
        "int[] u = {1, 2, 3};",
        "int[] v = u;",
        "v[0] = 9;"
    ]

    private var aVal: Int? { step >= 1 ? 5 : nil }
    private var bVal: Int? { step >= 3 ? 6 : (step >= 2 ? 5 : nil) }
    private var heap: [Int]? { step >= 4 ? (step >= 6 ? [9, 2, 3] : [1, 2, 3]) : nil }
    private var uLive: Bool { step >= 4 }
    private var vLive: Bool { step >= 5 }

    private var writeTarget: String {
        switch step {
        case 1: return "a"
        case 2, 3: return "b"
        case 4: return "u"
        case 5: return "v"
        case 6: return "cell"
        default: return ""
        }
    }

    private var note: String? {
        switch step {
        case 2: return "b gets a copy of the value"
        case 3: return "b changed - a did not"
        case 4: return "u holds a reference to the array"
        case 5: return "no new array - v points to the same one"
        case 6: return "one write, visible through u and v"
        default: return nil
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                PBHeader("Variables")

                PBAdaptive {
                    stage
                } code: {
                    PBCodePane(lines: code.map { PBCodePane.Line(code: $0) },
                               current: step - 1, accent: .cyan)
                        .pbViewport()
                }

                PBStepper(step: $step, total: total, accent: .cyan)
            }
            .padding(14)
        }
        .background(Color(.systemGroupedBackground))
    }

    private var stage: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let ax: CGFloat = 74
            let ay: CGFloat = 52, by: CGFloat = 52
            let bx: CGFloat = 178
            let uy: CGFloat = 148, vy: CGFloat = 208
            let box = CGPoint(x: w - 108, y: (uy + vy) / 2)

            ZStack {
                Canvas { ctx, _ in
                    if uLive {
                        drawArrow(ctx, from: CGPoint(x: ax + 44, y: uy),
                                  to: CGPoint(x: box.x - 66, y: box.y - 14),
                                  color: .green, hot: step == 4 || step == 6)
                    }
                    if vLive {
                        drawArrow(ctx, from: CGPoint(x: ax + 44, y: vy),
                                  to: CGPoint(x: box.x - 66, y: box.y + 14),
                                  color: .pink, hot: step == 5 || step == 6)
                    }
                }

                valueBox(name: "a", value: aVal, color: .cyan, hot: writeTarget == "a")
                    .position(x: ax, y: ay)
                valueBox(name: "b", value: bVal, color: .orange, hot: writeTarget == "b")
                    .position(x: bx, y: by)

                refTag(name: "u", color: .green, live: uLive, hot: writeTarget == "u")
                    .position(x: ax, y: uy)
                refTag(name: "v", color: .pink, live: vLive, hot: writeTarget == "v")
                    .position(x: ax, y: vy)

                if let heap {
                    arrayBox(heap, hotCell: step == 6 ? 0 : nil)
                        .position(box)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.spring(duration: 0.3), value: step)
        }
        .frame(height: 258)
        .pbViewport()
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 5) {
                if step >= 6 {
                    PBChip(label: "u[0]", value: "9", color: .green, hot: true)
                    PBChip(label: "v[0]", value: "9", color: .pink, hot: true)
                }
            }
            .padding(9)
        }
        .overlay(alignment: .bottomLeading) {
            if let note { PBNote(text: note).padding(9) }
        }
    }

    private func valueBox(name: String, value: Int?, color: Color, hot: Bool) -> some View {
        VStack(spacing: 4) {
            Text(name).font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            Text(value.map(String.init) ?? "·")
                .font(.system(size: 19, weight: .bold, design: .monospaced))
                .foregroundColor(value == nil ? .white.opacity(0.2) : .white)
                .contentTransition(.numericText())
                .frame(width: 58, height: 38)
                .background(RoundedRectangle(cornerRadius: 9)
                    .fill(color.opacity(value == nil ? 0.05 : 0.16)))
                .overlay(RoundedRectangle(cornerRadius: 9)
                    .strokeBorder(color.opacity(hot ? 1 : (value == nil ? 0.2 : 0.45)),
                                  style: StrokeStyle(lineWidth: hot ? 2 : 1,
                                                     dash: value == nil ? [4] : [])))
                .shadow(color: hot ? color.opacity(0.7) : .clear, radius: 8)
        }
    }

    private func refTag(name: String, color: Color, live: Bool, hot: Bool) -> some View {
        HStack(spacing: 4) {
            Text(name).font(.system(size: 12, weight: .bold, design: .monospaced))
            Image(systemName: "arrow.right").font(.system(size: 9, weight: .bold))
        }
        .foregroundColor(live ? color : .white.opacity(0.2))
        .frame(width: 58, height: 30)
        .background(RoundedRectangle(cornerRadius: 9).fill(color.opacity(live ? 0.16 : 0.05)))
        .overlay(RoundedRectangle(cornerRadius: 9)
            .strokeBorder(color.opacity(hot ? 1 : (live ? 0.45 : 0.2)),
                          style: StrokeStyle(lineWidth: hot ? 2 : 1, dash: live ? [] : [4])))
        .shadow(color: hot ? color.opacity(0.7) : .clear, radius: 8)
    }

    private func arrayBox(_ values: [Int], hotCell: Int?) -> some View {
        VStack(spacing: 4) {
            Text("int[3]").font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundColor(.white.opacity(0.4))
            HStack(spacing: 3) {
                ForEach(values.indices, id: \.self) { i in
                    Text("\(values[i])")
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .contentTransition(.numericText())
                        .frame(width: 34, height: 34)
                        .background(RoundedRectangle(cornerRadius: 7)
                            .fill(Color.white.opacity(hotCell == i ? 0.22 : 0.09)))
                        .overlay(RoundedRectangle(cornerRadius: 7)
                            .strokeBorder(hotCell == i ? PB.num : .white.opacity(0.2),
                                          lineWidth: hotCell == i ? 2 : 1))
                        .shadow(color: hotCell == i ? PB.num.opacity(0.7) : .clear, radius: 8)
                }
            }
            HStack(spacing: 3) {
                ForEach(0..<3, id: \.self) { i in
                    Text("[\(i)]").font(.system(size: 8, design: .monospaced))
                        .foregroundColor(.white.opacity(0.3)).frame(width: 34)
                }
            }
        }
    }

    private func drawArrow(_ ctx: GraphicsContext, from: CGPoint, to: CGPoint,
                           color: Color, hot: Bool) {
        let ctrl = CGPoint(x: (from.x + to.x) / 2, y: (from.y + to.y) / 2 - 22)
        var path = Path()
        path.move(to: from); path.addQuadCurve(to: to, control: ctrl)
        let c = color.opacity(hot ? 0.95 : 0.5)
        ctx.stroke(path, with: .color(c), style: StrokeStyle(lineWidth: hot ? 2 : 1.4))
        let ang = atan2(to.y - ctrl.y, to.x - ctrl.x)
        var head = Path()
        head.move(to: to)
        head.addLine(to: CGPoint(x: to.x - 8 * cos(ang - 0.45), y: to.y - 8 * sin(ang - 0.45)))
        head.move(to: to)
        head.addLine(to: CGPoint(x: to.x - 8 * cos(ang + 0.45), y: to.y - 8 * sin(ang + 0.45)))
        ctx.stroke(head, with: .color(c), style: StrokeStyle(lineWidth: hot ? 2 : 1.4, lineCap: .round))
    }
}

#Preview { VariablesView() }
