//
//  VariablesView.swift
//  EPFLearn
//
//  One idea: copy semantics vs reference semantics.
//  Primitives copy their value. `int[] q = p` copies only the reference, so
//  two names end up on one array; a fresh literal gives two separate arrays.
//
//  The names and numbers deliberately differ from the quiz code: the point is
//  to transfer the rule, not to look the answer up.
//

import SwiftUI

struct VariablesView: View {

    enum Variant: String, CaseIterable {
        case share, copy

        var label: String { self == .share ? "shared" : "independent" }
        var declLine: String { self == .share ? "int[] q = p;" : "int[] q = {4, 5, 6};" }
    }

    @State private var step = 0
    @State private var variant: Variant = .share
    private let total = 6

    private var code: [String] {
        ["int m = 3;",
         "int t = m;",
         "t = t + 4;",
         "int[] p = {4, 5, 6};",
         variant.declLine,
         "q[1] = 8;"]
    }

    // MARK: - Model

    private var mVal: Int? { step >= 1 ? 3 : nil }   // m and t exist only to contrast with p and q below
    private var tVal: Int? { step >= 3 ? 7 : (step >= 2 ? 3 : nil) }
    private var pLive: Bool { step >= 4 }
    private var qLive: Bool { step >= 5 }
    private var shares: Bool { variant == .share }

    private var pArray: [Int]? {
        guard step >= 4 else { return nil }
        return (shares && step >= 6) ? [4, 8, 6] : [4, 5, 6]
    }
    private var qArray: [Int]? {
        guard !shares, step >= 5 else { return nil }
        return step >= 6 ? [4, 8, 6] : [4, 5, 6]
    }

    private var hotCell: (onP: Bool, index: Int)? {
        guard step == 6 else { return nil }
        return (shares, 1)
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            PBHeader(title: "Variables") {
                Picker("", selection: $variant) {
                    ForEach(Variant.allCases, id: \.self) { Text($0.label).tag($0) }
                }
                .pickerStyle(.menu)
                .labelsHidden()
            }

            PBAdaptive {
                stage
            } code: {
                PBCodePane(lines: code.map { PBCodePane.Line(code: $0) },
                           current: step - 1, accent: .cyan)
                    .pbViewport()
            }

            PBStepper(step: $step, total: total, accent: .cyan)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(.systemGroupedBackground))
    }

    private var stage: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let ax: CGFloat = 62
            let py: CGFloat = 104, qy: CGFloat = 158
            let boxX = w - 92
            let pBox = CGPoint(x: boxX, y: shares ? (py + qy) / 2 : py)
            let qBox = CGPoint(x: boxX, y: qy)

            ZStack {
                // The boxes, the arrows and the highlighted code line carry the
                // lesson on their own; the captions that used to float here just
                // repeated them in grey.
                Canvas { ctx, _ in
                    if pLive {
                        arrow(ctx, from: CGPoint(x: ax + 28, y: py),
                              to: CGPoint(x: pBox.x - 54, y: pBox.y - (shares ? 10 : 0)),
                              color: .green, hot: step >= 6 && shares)
                    }
                    if qLive {
                        arrow(ctx, from: CGPoint(x: ax + 28, y: qy),
                              to: shares ? CGPoint(x: pBox.x - 54, y: pBox.y + 10)
                                         : CGPoint(x: qBox.x - 54, y: qBox.y),
                              color: .pink, hot: step >= 5)
                    }
                }

                valueBox("m", mVal, .cyan, hot: step == 1).position(x: ax, y: 26)
                valueBox("t", tVal, .orange, hot: step == 2 || step == 3).position(x: ax + 92, y: 26)

                refTag("p", .green, live: pLive, hot: step == 4).position(x: ax, y: py)
                refTag("q", .pink, live: qLive, hot: step == 5).position(x: ax, y: qy)

                if let pArray {
                    arrayBox(pArray, tint: .green, hot: hotCell?.onP == true ? 1 : nil)
                        .position(pBox)
                }
                if let qArray {
                    arrayBox(qArray, tint: .pink, hot: hotCell?.onP == false ? 1 : nil)
                        .position(qBox)
                }
            }
            .animation(.spring(duration: 0.28), value: step)
            .animation(.spring(duration: 0.28), value: variant)
        }
        .frame(height: 198)
        .pbViewport()
    }

    private func valueBox(_ name: String, _ value: Int?, _ color: Color, hot: Bool) -> some View {
        VStack(spacing: 2) {
            Text(name).font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            Text(value.map(String.init) ?? "·")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(value == nil ? .primary.opacity(0.2) : .primary)
                .contentTransition(.numericText())
                .frame(width: 48, height: 30)
                .background(RoundedRectangle(cornerRadius: 7).fill(color.opacity(value == nil ? 0.05 : 0.16)))
                .overlay(RoundedRectangle(cornerRadius: 7)
                    .strokeBorder(color.opacity(hot ? 1 : (value == nil ? 0.2 : 0.45)),
                                  style: StrokeStyle(lineWidth: hot ? 2 : 1, dash: value == nil ? [4] : [])))
        }
    }

    private func refTag(_ name: String, _ color: Color, live: Bool, hot: Bool) -> some View {
        HStack(spacing: 3) {
            Text(name).font(.system(size: 11, weight: .bold, design: .monospaced))
            Image(systemName: "arrow.right").font(.system(size: 8, weight: .bold))
        }
        .foregroundColor(live ? color : .primary.opacity(0.2))
        .frame(width: 48, height: 26)
        .background(RoundedRectangle(cornerRadius: 7).fill(color.opacity(live ? 0.16 : 0.05)))
        .overlay(RoundedRectangle(cornerRadius: 7)
            .strokeBorder(color.opacity(hot ? 1 : (live ? 0.45 : 0.2)),
                          style: StrokeStyle(lineWidth: hot ? 2 : 1, dash: live ? [] : [4])))
    }

    private func arrayBox(_ values: [Int], tint: Color, hot: Int?) -> some View {
        VStack(spacing: 2) {
            HStack(spacing: 2) {
                ForEach(values.indices, id: \.self) { i in
                    Text("\(values[i])")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .contentTransition(.numericText())
                        .frame(width: 26, height: 28)
                        .background(RoundedRectangle(cornerRadius: 6)
                            .fill(Color.primary.opacity(hot == i ? 0.22 : 0.09)))
                        .overlay(RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(hot == i ? PB.num : .primary.opacity(0.2), lineWidth: hot == i ? 2 : 1))
                }
            }
            HStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { i in
                    Text("[\(i)]").font(.system(size: 7, design: .monospaced))
                        .foregroundColor(.primary.opacity(0.3)).frame(width: 26)
                }
            }
        }
    }

    private func arrow(_ ctx: GraphicsContext, from: CGPoint, to: CGPoint, color: Color, hot: Bool) {
        let ctrl = CGPoint(x: (from.x + to.x) / 2, y: (from.y + to.y) / 2 - 18)
        var path = Path()
        path.move(to: from); path.addQuadCurve(to: to, control: ctrl)
        let c = color.opacity(hot ? 0.95 : 0.5)
        ctx.stroke(path, with: .color(c), style: StrokeStyle(lineWidth: hot ? 2 : 1.4))
        let ang = atan2(to.y - ctrl.y, to.x - ctrl.x)
        var head = Path()
        head.move(to: to)
        head.addLine(to: CGPoint(x: to.x - 7 * cos(ang - 0.45), y: to.y - 7 * sin(ang - 0.45)))
        head.move(to: to)
        head.addLine(to: CGPoint(x: to.x - 7 * cos(ang + 0.45), y: to.y - 7 * sin(ang + 0.45)))
        ctx.stroke(head, with: .color(c), style: StrokeStyle(lineWidth: hot ? 2 : 1.4, lineCap: .round))
    }
}

#Preview { VariablesView() }
