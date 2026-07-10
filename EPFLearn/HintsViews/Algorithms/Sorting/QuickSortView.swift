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

// Une étape de quicksort : le tableau + le contexte récursif (fenêtre, pivot)
// + le compteur de comparaisons À CET instant → tout est animé en même temps.
struct QSFrame {
    var array: [Int]
    var lo: Int          // bornes de la partition en cours
    var hi: Int
    var pivot: Int       // index du pivot (-1 = aucun)
    var comparisons: Int // total cumulé jusqu'à cette étape
}

// Quicksort instrumenté — logique pure, même esprit que `enum Graph` / `enum Sorting`.
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
            a.swapAt(pIdx, hi)                 // pivot placé en fin
            let pivotVal = a[hi]
            snap(lo, hi, hi)                   // début de partition : fenêtre + pivot
            var i = lo - 1
            for j in lo..<hi {
                comparisons += 1              // ← incrément AVANT le snap
                if a[j] <= pivotVal {
                    i += 1
                    a.swapAt(i, j)
                    snap(lo, hi, hi)          // état après échange, compteur à jour
                } else {
                    snap(lo, hi, hi)          // snap aussi sur comparaison sans échange,
                                              // pour que le compteur monte à chaque comparaison
                }
            }
            a.swapAt(i + 1, hi)
            snap(lo, hi, i + 1)               // pivot posé à sa place définitive
            return i + 1
        }

        func sort(_ lo: Int, _ hi: Int) {
            guard lo < hi else { return }
            let p = partition(lo, hi)
            sort(lo, p - 1)                   // récursion gauche
            sort(p + 1, hi)                   // récursion droite
        }
        sort(0, a.count - 1)
        return frames
    }
}

// Rendu barre-par-barre via Canvas — une couleur par barre (impossible avec un Shape).
struct QSBars: View {
    let frame: QSFrame

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
                    i == frame.pivot ? .orange :                        // pivot
                    (i >= frame.lo && i <= frame.hi) ? .blue            // fenêtre récursive
                    : .gray.opacity(0.3)                                // hors récursion
                ctx.stroke(p, with: .color(color), lineWidth: max(1, delta - 1.5))
            }
        }
    }
}

struct QuickSortView: View {

    private static let n = 30
    static func shuffled() -> [Int] { Array(1...n).shuffled() }
    static func sorted()   -> [Int] { Array(1...n) }

    // Frame courante affichée
    @State private var frameShuf = QSFrame(array: shuffled(), lo: 0, hi: n - 1, pivot: -1, comparisons: 0)
    @State private var frameSort = QSFrame(array: sorted(),   lo: 0, hi: n - 1, pivot: -1, comparisons: 0)

    // Frames pré-calculées + curseur de lecture
    @State private var framesShuf: [QSFrame] = []
    @State private var framesSort: [QSFrame] = []
    @State private var stepShuf = 0
    @State private var stepSort = 0

    private let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()

    private var running: Bool { stepShuf < framesShuf.count || stepSort < framesSort.count }

    var body: some View {
        VStack(spacing: 16) {

            panel(title: "Random array", frame: frameShuf)
            panel(title: "Already sorted array", frame: frameSort)

            Text("QuickSort")
                .font(.caption).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
                Button("Mélanger") { reset() }
                    .buttonStyle(.bordered)
                Button("Comparer") { run() }
                    .buttonStyle(.borderedProminent)
                    .disabled(running)
            }
        }
        .padding()
        .onReceive(timer) { _ in
            if stepShuf < framesShuf.count { frameShuf = framesShuf[stepShuf]; stepShuf += 1 }
            if stepSort < framesSort.count { frameSort = framesSort[stepSort]; stepSort += 1 }
        }
    }

    @ViewBuilder
    private func panel(title: String, frame: QSFrame) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title).font(.caption).bold()
                Spacer()
                Text("\(frame.comparisons) comparaisons")    // ← lu depuis la frame → temps réel
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())       // petite anim du chiffre
            }
            QSBars(frame: frame)
                .frame(height: 150)
                .padding(.vertical, 6)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(.gray.opacity(0.2)))
        }
    }

    private func run() {
        framesShuf = QuickSort.run(frameShuf.array, pivot: .last); stepShuf = 0
        framesSort = QuickSort.run(frameSort.array, pivot: .last); stepSort = 0
    }

    private func reset() {
        let fresh = Self.shuffled()
        frameShuf = QSFrame(array: fresh,         lo: 0, hi: fresh.count - 1, pivot: -1, comparisons: 0)
        frameSort = QSFrame(array: Self.sorted(), lo: 0, hi: Self.n - 1,      pivot: -1, comparisons: 0)
        framesShuf = []; framesSort = []
        stepShuf = 0; stepSort = 0
    }
}

#Preview {
    QuickSortView()
}
