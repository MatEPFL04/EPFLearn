
//
//  BigOView.swift
//  EPFLearn
//
//  Big-O as its formal definition: f(n) = O(g(n)) iff there exist C > 0 and n₀
//  with f(n) ≤ C·g(n) for all n ≥ n₀. Pick f and g, drag n₀, tune C, and hunt
//  for a witness. The true Yes/No comes from the (known) growth ranking.
//

import SwiftUI

struct BigOView: View {

    struct GrowthFn: Identifiable {
        let id: Int
        let name: String
        let f: (Double) -> Double
    }

    // Listed in increasing order of growth → f = O(g) iff fIndex ≤ gIndex.
    private let fns: [GrowthFn] = [
        .init(id: 0, name: "1",       f: { _ in 1 }),
        .init(id: 1, name: "log n",   f: { max(0, log2($0)) }),
        .init(id: 2, name: "n",       f: { $0 }),
        .init(id: 3, name: "n log n", f: { $0 * max(0, log2($0)) }),
        .init(id: 4, name: "n²",      f: { $0 * $0 }),
        .init(id: 5, name: "n³",      f: { $0 * $0 * $0 }),
        .init(id: 6, name: "2ⁿ",      f: { pow(2, $0) })
    ]

    @State private var fIndex = 4   // n²
    @State private var gIndex = 5   // n³
    @State private var C: Double = 1
    @State private var n0: Double = 1
    @State private var n0Start: Double? = nil

    private let boardW: CGFloat = 340
    private let boardH: CGFloat = 280
    private let leftPad: CGFloat = 30
    private let rightPad: CGFloat = 14
    private let topPad: CGFloat = 18
    private let botPad: CGFloat = 26
    private let nMax: Double = 14

    private var plotW: CGFloat { boardW - leftPad - rightPad }
    private var plotH: CGFloat { boardH - topPad - botPad }
    private var bottomY: CGFloat { topPad + plotH }

    private var fName: String { fns[fIndex].name }
    private var gName: String { fns[gIndex].name }
    private var cLabel: String { String(format: "%.1f", C) }
    private var isBigO: Bool { fIndex <= gIndex }

    private var samples: [Double] { stride(from: 1.0, through: nMax, by: 0.25).map { $0 } }
    private func fVal(_ n: Double) -> Double { fns[fIndex].f(n) }
    private func gVal(_ n: Double) -> Double { C * fns[gIndex].f(n) }
    private func xS(_ n: Double) -> CGFloat { leftPad + CGFloat((n - 1) / (nMax - 1)) * plotW }

    private var yMax: Double {
        let m = samples.map { max(fVal($0), gVal($0)) }.max() ?? 1
        return m > 0 ? m * 1.08 : 1
    }
    // Smallest shown n ≥ n₀ where f exceeds C·g (if any).
    private var failN: Double? {
        for n in samples where n >= n0 {
            if fVal(n) > gVal(n) + 1e-9 { return n }
        }
        return nil
    }

    private var hintText: String {
        if !isBigO {
            return "\(gName) grows slower than \(fName), so f overtakes C·g for large n whatever C is — even if it looks fine on the range shown."
        }
        if failN == nil {
            return "C·g stays above f for every shown n ≥ n₀: a valid witness, so f = O(g)."
        }
        return "Not a witness yet — around n = \(Int((failN ?? 0).rounded())), f is above C·g. Raise C or move n₀ right."
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {

                Text("f(n) = O(g(n)) means: there exist C > 0 and n₀ with f(n) ≤ C·g(n) for all n ≥ n₀. Try to find a C and n₀ that work.")
                    .font(.footnote).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 18) {
                    fnPicker("f", $fIndex)
                    fnPicker("g", $gIndex)
                }

                ZStack {
                    Canvas { ctx, _ in draw(&ctx) }

                    // Draggable n₀ line
                    Rectangle()
                        .fill(Color.white.opacity(0.001))
                        .frame(width: 34, height: plotH)
                        .contentShape(Rectangle())
                        .position(x: xS(n0), y: topPad + plotH / 2)
                        .gesture(
                            DragGesture()
                                .onChanged { g in
                                    let base = n0Start ?? n0
                                    if n0Start == nil { n0Start = n0 }
                                    let dn = Double(g.translation.width / plotW) * (nMax - 1)
                                    n0 = min(max(base + dn, 1), nMax)
                                }
                                .onEnded { _ in n0Start = nil }
                        )
                }
                .frame(width: boardW, height: boardH)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.45), lineWidth: 1))

                VStack(alignment: .leading, spacing: 4) {
                    Text("C = \(cLabel)").font(.caption).foregroundStyle(.secondary)
                    Slider(value: $C, in: 0.25...10)
                }

                // Verdict
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: isBigO ? "checkmark.seal.fill" : "xmark.seal.fill")
                            .foregroundStyle(isBigO ? .green : .red)
                        Text("Is \(fName) = O(\(gName)) ?   →   \(isBigO ? "Yes" : "No")")
                            .font(.subheadline).bold()
                    }
                    Text(hintText)
                        .font(.caption).foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background((isBigO ? Color.green : Color.red).opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding()
        }
    }

    private func fnPicker(_ label: String, _ sel: Binding<Int>) -> some View {
        HStack(spacing: 6) {
            Text("\(label):").font(.subheadline).foregroundStyle(.secondary)
            Picker(label, selection: sel) {
                ForEach(fns) { Text($0.name).tag($0.id) }
            }
            .pickerStyle(.menu)
            .labelsHidden()
        }
    }

    private func draw(_ ctx: inout GraphicsContext) {
        let xn0 = xS(n0)
        let ymax = yMax
        func yS(_ v: Double) -> CGFloat { bottomY - CGFloat(min(v, ymax) / ymax) * plotH }

        // Region n ≥ n₀
        let shade = Path(CGRect(x: xn0, y: topPad, width: max(0, leftPad + plotW - xn0), height: plotH))
        ctx.fill(shade, with: .color(.green.opacity(0.07)))

        // Axes
        var axes = Path()
        axes.move(to: CGPoint(x: leftPad, y: topPad))
        axes.addLine(to: CGPoint(x: leftPad, y: bottomY))
        axes.addLine(to: CGPoint(x: leftPad + plotW, y: bottomY))
        ctx.stroke(axes, with: .color(.gray.opacity(0.7)), lineWidth: 1.5)

        // x labels
        for n in stride(from: 2.0, through: nMax, by: 3.0) {
            ctx.draw(Text("\(Int(n))").font(.system(size: 10)).foregroundColor(.gray),
                     at: CGPoint(x: xS(n), y: bottomY + 12))
        }
        ctx.draw(Text("n").font(.system(size: 11)).foregroundColor(.gray),
                 at: CGPoint(x: leftPad + plotW, y: bottomY + 13))

        // Curve builder
        func curve(_ fn: (Double) -> Double) -> Path {
            var p = Path()
            var started = false
            for n in samples {
                let pt = CGPoint(x: xS(n), y: yS(fn(n)))
                if started { p.addLine(to: pt) } else { p.move(to: pt); started = true }
            }
            return p
        }

        ctx.stroke(curve { gVal($0) }, with: .color(.orange),
                   style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
        ctx.stroke(curve { fVal($0) }, with: .color(.blue), lineWidth: 2)

        // n₀ line + knob
        var line = Path()
        line.move(to: CGPoint(x: xn0, y: topPad))
        line.addLine(to: CGPoint(x: xn0, y: bottomY))
        ctx.stroke(line, with: .color(.green), style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
        ctx.fill(Path(ellipseIn: CGRect(x: xn0 - 5, y: topPad - 5, width: 10, height: 10)),
                 with: .color(.green))
        ctx.draw(Text("n₀=\(Int(n0.rounded()))").font(.system(size: 10, weight: .semibold)).foregroundColor(.green),
                 at: CGPoint(x: xn0, y: topPad - 14))

        // Legend
        ctx.draw(Text("f = \(fName)").font(.system(size: 11, weight: .semibold)).foregroundColor(.blue),
                 at: CGPoint(x: leftPad + 42, y: topPad + 8))
        ctx.draw(Text("C·g = \(cLabel)·\(gName)").font(.system(size: 11, weight: .semibold)).foregroundColor(.orange),
                 at: CGPoint(x: leftPad + plotW - 58, y: topPad + 8))
    }
}

#Preview { BigOView() }
