//
//  SortingView.swift
//  EPFLearn
//
//  Created by Mat on 26.06.2026.
//
import SwiftUI
import Combine

// MARK: - Vue

struct SortingView: View {

    enum Algo: String, CaseIterable {
        case insertion = "Insertion"
        case merge     = "Merge"
        case bubble    = "Bubble"
        case selection = "Selection"
    }

    enum Shape: String, CaseIterable {
        case random       = "Random"
        case reversed     = "Reversed"
        case almostSorted = "Almost sorted"
        case ksorted      = "k-sorted"
        case zigzag       = "Zigzag"
        case rotated      = "Rotated"
        case organ        = "Organ pipe"
    }

    @State private var algo: Algo
    @State private var shape: Shape
    @State private var array: [Int]
    @State private var n: Int
    @State private var frames: [QSFrame] = []
    @State private var step: Double = 0
    @State private var disorder: Double = 0

    init(algo: Algo = .insertion, shape: Shape = .random, disorder: Int = 0, n: Int = 30) {
        _algo = State(initialValue: algo)
        _shape = State(initialValue: shape)
        _disorder = State(initialValue: Double(disorder))
        _n = State(initialValue: n)
        _array = State(initialValue: SortingView.makeArray(n: n, shape: shape, amount: disorder))
    }

    // Toutes les formes produisent des valeurs >= 0 (QSBars dessine des barres
    // vers le haut, comme pour la recherche sur 0...99).
    static func makeArray(n: Int, shape: Shape, amount m: Int) -> [Int] {
        switch shape {
        case .random:
            return (0..<n).map { _ in Int.random(in: 0...99) }
        case .reversed:
            var a = Array(0..<n)
            for i in 0..<min(m, n) { a[i] = m - 1 - i }
            return a
        case .zigzag:
            var a = Array(0..<n).map { $0 + 1 }
            var i = 0
            while i + 1 < n { a.swapAt(i, i + 1); i += 2 }
            return a
        case .rotated:
            let k = min(m, n)
            return Array(k..<n) + Array(0..<k)
        case .organ:
            return (0..<n).map { $0 < n/2 ? 2*$0 : 2*(n - 1 - $0) }
        case .almostSorted:
            var a = Array(0..<n)
            let swaps = max(1, n / 10)
            for _ in 0..<swaps {
                let i = Int.random(in: 0..<(n - 1))
                a.swapAt(i, i + 1)
            }
            return a
        case .ksorted:
            var a = Array(0..<n)
            let k = max(1, min(m, n - 1))
            var i = 0
            while i + k < n { a.swapAt(i, i + k); i += k + 1 }
            return a.map { $0 + 10 }
        }
    }

    private var maxStep: Int { max(0, frames.count - 1) }

    private var current: QSFrame {
        if frames.isEmpty {
            return QSFrame(array: array, lo: 0, hi: array.count - 1, pivot: -1, comparisons: 0)
        }
        return frames[min(Int(step), frames.count - 1)]
    }

    var body: some View {
        VStack(spacing: 16) {
            panel

            if maxStep > 0 {
                Slider(value: $step, in: 0...Double(maxStep), step: 1)
                Text("Step \(Int(step)) / \(maxStep)")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
            } else {
                Text("Choose an algorithm and run it!")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Picker("Algorithme", selection: $algo) {
                ForEach(Algo.allCases, id: \.self) { algorithm in
                    Text(algorithm.rawValue).tag(algorithm)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .onChange(of: algo) { frames = []; step = 0 }   // même tableau → on peut comparer

            HStack(spacing: 12) {
                Button("Sort") { run() }.buttonStyle(.borderedProminent)
                if shape == .almostSorted || shape == .random {
                    
                    Button("New instance") { rebuild() }.buttonStyle(.bordered)
                }
            }

            Picker("Forme", selection: $shape) {
                ForEach(Shape.allCases, id: \.self) { shapeOption in
                    Text(shapeOption.rawValue).tag(shapeOption)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .onChange(of: shape) { rebuild() }

            if shape == .reversed || shape == .rotated || shape == .ksorted {
                Text(shape == .ksorted ? "k (max displacement) : \(Int(disorder))"
                                       : "Disorder : \(Int(disorder))")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
                Slider(value: $disorder, in: 0...Double(n), step: 1)
                    .onChange(of: disorder) { rebuild() }
            }

            Text("Number of elements : \(n)")
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.secondary)
            Slider(value: Binding(get: { Double(n) }, set: { n = Int($0) }), in: 5...100, step: 1)
                .onChange(of: n) { rebuild() }
        }
        .padding()
    }

    private var panel: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(algo.rawValue).font(.caption).bold()
                Spacer()
                Text("\(current.comparisons) comparisons")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
            }
            QSBars(frame: current, targetIndex: nil)
                .frame(height: 180)
                .padding(.vertical, 6)
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(.gray.opacity(0.2)))
        }
    }

    private func run() {
        switch algo {
        case .insertion: frames = Sorting.insertion(array)
        case .merge:     frames = Sorting.merge(array)
        case .bubble:    frames = Sorting.bubble(array)
        case .selection: frames = Sorting.selection(array)
        }
        step = 0
    }

    private func rebuild() {
        array = Self.makeArray(n: n, shape: shape, amount: Int(disorder))
        frames = []; step = 0
    }
}

#Preview {
    SortingView(algo: .bubble, shape: .random)
        .preferredColorScheme(.dark)
}
