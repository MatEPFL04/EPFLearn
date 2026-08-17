//
//  FunctionView.swift
//  EPFLearn
//
//  One idea, two halves.
//  int parameter : Java passes by value. The parameter is its OWN box that
//    happens to share the caller's name - mutating it never touches the
//    caller's variable. Only `return` carries a value back.
//  array parameter : the parameter is still its own box, but what got copied
//    into it is the reference. Both names reach the same cells, so a write
//    inside the method IS visible to the caller.
//

import SwiftUI

struct FunctionView: View {

    enum Mode: String, CaseIterable {
        case value = "int"
        case array = "int[]"
    }

    @State private var mode: Mode = .value
    @State private var step = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                PBHeader("Functions")
                Picker("", selection: $mode) {
                    ForEach(Mode.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .onChange(of: mode) { _ in step = 0 }
            }

            PBAdaptive {
                mode == .value ? AnyView(valueStage) : AnyView(arrayStage)
            } code: {
                PBCodePane(lines: code.map { PBCodePane.Line(code: $0) },
                           current: currentLine, accent: PB.num)
                    .pbViewport()
            }

            PBStepper(step: $step, total: total, accent: PB.num)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Code

    private var code: [String] {
        switch mode {
        case .value:
            return [
                "static int boost(int v) {",
                "    v = v * 3;",
                "    v = v + 10;",
                "    return v;",
                "}",
                "",
                "int v = 4;",
                "int w = boost(v);"
            ]
        case .array:
            return [
                "static void reset(int[] d) {",
                "    d[2] = 0;",
                "}",
                "",
                "int[] xs = {4, 5, 6};",
                "reset(xs);"
            ]
        }
    }

    private struct Frame { let line: Int; let note: String? }

    private let valueFrames: [Frame] = [
        Frame(line: -1, note: nil),
        Frame(line: 6, note: nil),
        Frame(line: 7, note: "call boost(v)"),
        Frame(line: 0, note: "param v = copy of 4"),
        Frame(line: 1, note: "param v = 12"),
        Frame(line: 2, note: "param v = 22"),
        Frame(line: 3, note: "return 22"),
        Frame(line: 7, note: "w = 22, caller v still 4"),
        Frame(line: -1, note: "same name, different boxes")
    ]

    private let arrayFrames: [Frame] = [
        Frame(line: -1, note: nil),
        Frame(line: 4, note: "xs → {4, 5, 6}"),
        Frame(line: 5, note: "call reset(xs)"),
        Frame(line: 0, note: "d copies the reference"),
        Frame(line: 1, note: "d[2] = 0 hits the same array"),
        Frame(line: 5, note: "xs[2] is 0 too"),
        Frame(line: -1, note: "d = ... would not move xs")
    ]

    private var frames: [Frame] { mode == .value ? valueFrames : arrayFrames }
    private var total: Int { frames.count - 1 }
    private var fr: Frame { frames[min(step, total)] }
    private var currentLine: Int { fr.line }

    // MARK: - Stage 1: int parameter

    private var callerA: Int? { step >= 1 ? 4 : nil }
    private var bVal: Int? { step >= 7 ? 22 : nil }
    private var paramA: Int? {
        switch step {
        case 3: return 4
        case 4: return 12
        case 5, 6: return 22
        default: return nil
        }
    }
    private var paramAlive: Bool { (3...6).contains(step) }
    private var copyArrow: Bool { step == 3 }
    private var returnArrow: Bool { (6...7).contains(step) }
    private var callerSteady: Bool { (4...6).contains(step) }

    private var valueStage: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let aP = CGPoint(x: w * 0.28, y: 34)
            let bP = CGPoint(x: w * 0.66, y: 34)
            let xP = CGPoint(x: w * 0.47, y: 146)

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(PB.num.opacity(paramAlive ? 0.55 : 0.18),
                                  style: StrokeStyle(lineWidth: 1.2, dash: [5]))
                    .background(RoundedRectangle(cornerRadius: 12)
                        .fill(PB.num.opacity(paramAlive ? 0.05 : 0.015)))
                    .frame(width: w * 0.64, height: 90)
                    .position(x: w * 0.47, y: 144)

                // Pinned inside the frame's top-left corner: centred, it used to
                // land on the param box and on the arrow tips.
                Text("boost(int v)")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundColor(PB.num.opacity(paramAlive ? 0.9 : 0.35))
                    .position(x: w * 0.15 + 44, y: 108)

                Canvas { ctx, _ in
                    if copyArrow {
                        drawArrow(ctx, from: CGPoint(x: aP.x, y: aP.y + 32),
                                  to: CGPoint(x: xP.x - 20, y: xP.y - 34), color: .cyan)
                    }
                    if returnArrow {
                        drawArrow(ctx, from: CGPoint(x: xP.x + 20, y: xP.y - 34),
                                  to: CGPoint(x: bP.x, y: bP.y + 32), color: .green)
                    }
                }

                if copyArrow {
                    tag("copy 4", .cyan)
                        .position(x: (aP.x + xP.x) / 2 - 34, y: 76)
                        .transition(.opacity)
                }
                if returnArrow {
                    tag("return 22", .green)
                        .position(x: (bP.x + xP.x) / 2 + 34, y: 76)
                        .transition(.opacity)
                }

                box(name: "v", scope: "caller", value: callerA, color: .cyan,
                    hot: step == 1, steady: callerSteady).position(aP)
                box(name: "w", scope: "caller", value: bVal, color: .green,
                    hot: step == 7).position(bP)
                box(name: "v", scope: "param", value: paramA, color: PB.num,
                    hot: step == 3 || step == 4 || step == 5)
                    .position(xP).opacity(paramAlive ? 1 : 0)
            }
            .animation(.spring(duration: 0.3), value: step)
        }
        .frame(height: 196)
        .pbViewport()
        .overlay(alignment: .bottomLeading) {
            if let note = fr.note { PBNote(text: note).padding(7) }
        }
    }

    // MARK: - Stage 2: array parameter

    private var arrLive: Bool { step >= 1 }
    private var arrParamAlive: Bool { (3...4).contains(step) }
    private var cells: [Int] { step >= 4 ? [4, 5, 0] : [4, 5, 6] }

    private var arrayStage: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let aP = CGPoint(x: w * 0.18, y: 34)
            let heap = CGPoint(x: w * 0.64, y: 80)
            let paramP = CGPoint(x: w * 0.18, y: 150)

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(PB.num.opacity(arrParamAlive ? 0.55 : 0.18),
                                  style: StrokeStyle(lineWidth: 1.2, dash: [5]))
                    .background(RoundedRectangle(cornerRadius: 12)
                        .fill(PB.num.opacity(arrParamAlive ? 0.05 : 0.015)))
                    .frame(width: w * 0.9, height: 70)
                    .position(x: w * 0.5, y: 148)

                // Top-right of the frame: the param tag owns the left side.
                Text("reset(int[] d)")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundColor(PB.num.opacity(arrParamAlive ? 0.9 : 0.35))
                    .position(x: w * 0.95 - 52, y: 120)

                Canvas { ctx, _ in
                    if arrLive {
                        drawArrow(ctx, from: CGPoint(x: aP.x + 34, y: aP.y + 6),
                                  to: CGPoint(x: heap.x - 58, y: heap.y - 16),
                                  color: .cyan, dashed: false)
                    }
                    if arrParamAlive || step >= 5 {
                        drawArrow(ctx, from: CGPoint(x: paramP.x + 34, y: paramP.y - 6),
                                  to: CGPoint(x: heap.x - 58, y: heap.y + 16),
                                  color: PB.num, dashed: false)
                    }
                }

                refTag(name: "xs", scope: "caller", color: .cyan, live: arrLive, hot: step == 1)
                    .position(aP)
                refTag(name: "d", scope: "param", color: PB.num,
                       live: arrParamAlive || step >= 5, hot: step == 3)
                    .position(paramP)
                    .opacity(arrParamAlive || step >= 5 ? 1 : 0.25)

                if step == 3 {
                    // Below the d -> heap arrow and to the right of the param
                    // box, the only spot inside the frame nothing else claims.
                    tag("copy of the ref", PB.num)
                        .position(x: w * 0.58, y: 170)
                        .transition(.opacity)
                }

                if arrLive {
                    arrayBox(cells, hotCell: step >= 4 ? 2 : nil)
                        .position(heap)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.spring(duration: 0.3), value: step)
        }
        .frame(height: 210)
        .pbViewport()
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 5) {
                if step >= 4 {
                    PBChip(label: "d[2]", value: "0", color: PB.num, hot: true)
                    PBChip(label: "xs[2]", value: "0", color: .cyan, hot: true)
                }
            }
            .padding(9)
        }
        .overlay(alignment: .bottomLeading) {
            if let note = fr.note { PBNote(text: note).padding(7) }
        }
    }

    // MARK: - Pieces

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

    private func refTag(name: String, scope: String, color: Color, live: Bool, hot: Bool) -> some View {
        VStack(spacing: 3) {
            Text(scope).font(.system(size: 8, design: .monospaced))
                .foregroundColor(.primary.opacity(0.3))
            HStack(spacing: 4) {
                Text(name).font(.system(size: 12, weight: .bold, design: .monospaced))
                Image(systemName: "arrow.right").font(.system(size: 9, weight: .bold))
            }
            .foregroundColor(live ? color : .primary.opacity(0.2))
            .frame(width: 62, height: 32)
            .background(RoundedRectangle(cornerRadius: 9).fill(color.opacity(live ? 0.16 : 0.05)))
            .overlay(RoundedRectangle(cornerRadius: 9)
                .strokeBorder(color.opacity(hot ? 1 : (live ? 0.45 : 0.2)),
                              style: StrokeStyle(lineWidth: hot ? 2 : 1, dash: live ? [] : [4])))
            .shadow(color: hot ? color.opacity(0.7) : .clear, radius: 8)
        }
    }

    private func arrayBox(_ values: [Int], hotCell: Int?) -> some View {
        VStack(spacing: 4) {
            Text("int[3]").font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundColor(.primary.opacity(0.4))
            HStack(spacing: 3) {
                ForEach(values.indices, id: \.self) { i in
                    Text("\(values[i])")
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                        .contentTransition(.numericText())
                        .frame(width: 32, height: 34)
                        .background(RoundedRectangle(cornerRadius: 7)
                            .fill(Color.primary.opacity(hotCell == i ? 0.22 : 0.09)))
                        .overlay(RoundedRectangle(cornerRadius: 7)
                            .strokeBorder(hotCell == i ? PB.num : .primary.opacity(0.2),
                                          lineWidth: hotCell == i ? 2 : 1))
                        .shadow(color: hotCell == i ? PB.num.opacity(0.7) : .clear, radius: 8)
                }
            }
            HStack(spacing: 3) {
                ForEach(0..<3, id: \.self) { i in
                    Text("[\(i)]").font(.system(size: 8, design: .monospaced))
                        .foregroundColor(.primary.opacity(0.3)).frame(width: 32)
                }
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

    private func drawArrow(_ ctx: GraphicsContext, from: CGPoint, to: CGPoint,
                           color: Color, dashed: Bool = true) {
        let ctrl = CGPoint(x: (from.x + to.x) / 2 + (to.x > from.x ? -26 : 26), y: (from.y + to.y) / 2)
        var path = Path()
        path.move(to: from); path.addQuadCurve(to: to, control: ctrl)
        ctx.stroke(path, with: .color(color.opacity(0.9)),
                   style: StrokeStyle(lineWidth: 2, dash: dashed ? [6, 4] : []))
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
