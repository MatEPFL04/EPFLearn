//
//  QuickSortView.swift
//  EPFLearn
//
//  Created by Mat on 27.06.2026.
//
//
//  QuickSortView.swift
//  EPFLearn
//
//
//  QuickSortView.swift
//  EPFLearn
//

import Combine

import SwiftUI


struct QSFrame {
    var array: [Int]
    var lo: Int
    var hi: Int
    var pivot: Int
    var comparisons: Int
    var bestLo: Int = -1     // meilleur sous-tableau trouvé jusqu'ici
    var bestHi: Int = -1
}

enum QuickSort {

    enum Pivot { case last, medianOfThree }

    static func run(_ input: [Int], pivot: Pivot) -> [QSFrame] {
        var a = input
        var comparisons = 0
        var frames: [QSFrame] = [QSFrame(array: a, lo: 0, hi: a.count - 1, pivot: -1, comparisons: 0)]

        func snap(_ lo: Int, _ hi: Int, _ piv: Int) {
            frames.append(QSFrame(array: a, lo: lo, hi: hi, pivot: piv, comparisons: comparisons))
        }

        func choosePivot(_ lo: Int, _ hi: Int) -> Int {
            switch pivot {
            case .last:
                return hi
            case .medianOfThree:
                let mid = (lo + hi) / 2
                let trio = [(a[lo], lo), (a[mid], mid), (a[hi], hi)].sorted { $0.0 < $1.0 }
                return trio[1].1
            }
        }

        func partition(_ lo: Int, _ hi: Int) -> Int {
            let pIdx = choosePivot(lo, hi)
            a.swapAt(pIdx, hi)
            let pivotVal = a[hi]
            snap(lo, hi, hi)
            var i = lo - 1
            for j in lo..<hi {
                comparisons += 1
                if a[j] <= pivotVal {
                    i += 1
                    a.swapAt(i, j)
                    snap(lo, hi, hi)
                } else {
                    snap(lo, hi, hi)
                }
            }
            a.swapAt(i + 1, hi)
            snap(lo, hi, i + 1)
            return i + 1
        }

        func sort(_ lo: Int, _ hi: Int) {
            guard lo < hi else { return }
            let p = partition(lo, hi)
            sort(lo, p - 1)
            sort(p + 1, hi)
        }
        sort(0, a.count - 1)
        return frames
    }
}

struct QSBars: View {
    let frame: QSFrame
    var targetIndex: Int? = nil

    var body: some View {
        Canvas { ctx, size in
            let a = frame.array
            guard !a.isEmpty else { return }
            let maxAbs = CGFloat(a.map { abs($0) }.max() ?? 1)
            let scale = maxAbs == 0 ? 1 : (size.height - 12) / maxAbs
            let delta = size.width / CGFloat(a.count)
            let baseline = size.height

            for (i, elm) in a.enumerated() {
                let x = delta * (CGFloat(i) + 0.5)
                let top = baseline - CGFloat(elm) * scale
                var p = Path()
                p.move(to: CGPoint(x: x, y: baseline))
                p.addLine(to: CGPoint(x: x, y: top))

                let color: Color =
                    i == frame.pivot      ? .orange :
                    i == targetIndex      ? .green  :
                    (i >= frame.lo && i <= frame.hi) ? .blue :
                    .gray.opacity(0.3)

                ctx.stroke(p, with: .color(color.opacity(0.5)), lineWidth: max(3, delta + 2))
                ctx.stroke(p, with: .color(color), lineWidth: max(1, delta - 1.5))
            }
        }
    }
}

struct QuickSortView: View {

    enum Input: String, CaseIterable {
        case sorted   = "Sorted"
        case reversed = "Reversed"
        case constant = "Constant"
        case minLast  = "Min at end"
        case nearly   = "Almost sorted"
    }

    @State private var n: Int
    @State private var input: Input
    @State private var baseShuf: QSFrame
    @State private var baseStruct: QSFrame
    @State private var framesShuf: [QSFrame] = []
    @State private var framesStruct: [QSFrame] = []
    @State private var step: Double = 0

    init(n: Int = 30, input: Input = .sorted) {
        _n = State(initialValue: n)
        _input = State(initialValue: input)
        _baseShuf = State(initialValue: QSFrame(array: Self.shuffled(n), lo: 0, hi: n - 1, pivot: -1, comparisons: 0))
        _baseStruct = State(initialValue: QSFrame(array: Self.makeInput(input, n), lo: 0, hi: n - 1, pivot: -1, comparisons: 0))
    }

    static func shuffled(_ n: Int) -> [Int] { Array(1...n).shuffled() }

    static func makeInput(_ input: Input, _ n: Int) -> [Int] {
        switch input {
        case .sorted:
            return Array(1...n)
        case .reversed:
            return Array((1...n).reversed())
        case .constant:
            return Array(repeating: 1, count: n)
        case .minLast:
            // trié sauf le minimum déplacé en dernière position
            return Array(2...n) + [1]
        case .nearly:
            // trié avec quelques éléments du milieu permutés
            var a = Array(1...n)
            if n >= 6 {
                a.swapAt(n/2 - 1, n/2 + 1)
                a.swapAt(n/3, n/3 + 1)
            }
            return a
        }
    }

    private var maxStep: Int { max(0, max(framesShuf.count, framesStruct.count) - 1) }

    var body: some View {
        VStack(spacing: 16) {

            panel(title: "Random array", frame: displayed(framesShuf, baseShuf))
            panel(title: input.rawValue,  frame: displayed(framesStruct, baseStruct))

            if maxStep > 0 {
                VStack(spacing: 4) {
                    Slider(value: $step, in: 0...Double(maxStep), step: 1)
                    Text("Step \(Int(step)) / \(maxStep)")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 12) {
                Button("Shuffle") { reset() }.buttonStyle(.bordered)
                Button("Run") { run() }.buttonStyle(.borderedProminent)
            }

            Picker("Input", selection: $input) {
                ForEach(Input.allCases, id: \.self) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.menu)
            .onChange(of: input) { reset() }

            Text("Number of elements in the array : \(n)")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
            Slider(
                value: Binding(get: { Double(n) }, set: { n = Int($0) }),
                in: 1...100, step: 1
            )
            .onChange(of: n) { reset() }
        }
        .padding()
    }

    @ViewBuilder
    private func panel(title: String, frame: QSFrame) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title).font(.caption).bold()
                Spacer()
                Text("\(frame.comparisons) comparaisons")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
            }
            QSBars(frame: frame)
                .frame(height: 150)
                .padding(.vertical, 6)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(.gray.opacity(0.2)))
        }
    }

    private func displayed(_ frames: [QSFrame], _ base: QSFrame) -> QSFrame {
        guard !frames.isEmpty else { return base }
        return frames[min(Int(step), frames.count - 1)]
    }

    private func run() {
        framesShuf = QuickSort.run(baseShuf.array, pivot: .last)
        framesStruct = QuickSort.run(baseStruct.array, pivot: .last)
        step = 0
    }

    private func reset() {
        baseShuf = QSFrame(array: Self.shuffled(n), lo: 0, hi: n - 1, pivot: -1, comparisons: 0)
        baseStruct = QSFrame(array: Self.makeInput(input, n), lo: 0, hi: n - 1, pivot: -1, comparisons: 0)
        framesShuf = []; framesStruct = []
        step = 0
    }
}

#Preview {
    QuickSortView().preferredColorScheme(.dark)
}
