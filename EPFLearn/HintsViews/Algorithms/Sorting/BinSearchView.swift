//
//  BinSearch.swift
//  EPFLearn
//
//  Created by Mat on 27.06.2026.
//
import SwiftUI

enum BinarySearch {
    static func run(_ input: [Int], target: Int) -> [QSFrame] {
        let a = input.sorted()
        var frames: [QSFrame] = []
        var comparisons = 0
        var lo = 0, hi = a.count - 1

        frames.append(QSFrame(array: a, lo: lo, hi: hi, pivot: -1, comparisons: 0))

        while lo <= hi {
            let mid = (lo + hi) / 2
            comparisons += 1
            frames.append(QSFrame(array: a, lo: lo, hi: hi, pivot: mid, comparisons: comparisons))

            if a[mid] == target {
                frames.append(QSFrame(array: a, lo: mid, hi: mid, pivot: mid, comparisons: comparisons))
                return frames
            } else if a[mid] < target {
                lo = mid + 1
            } else {
                hi = mid - 1
            }
        }
        frames.append(QSFrame(array: a, lo: 0, hi: -1, pivot: -1, comparisons: comparisons))
        return frames
    }

    static func linear(_ input: [Int], target: Int) -> [QSFrame] {
        let a = input.sorted()
        var frames: [QSFrame] = [QSFrame(array: a, lo: 0, hi: a.count - 1, pivot: -1, comparisons: 0)]
        var comparisons = 0
        for i in a.indices {
            comparisons += 1
            frames.append(QSFrame(array: a, lo: i, hi: a.count - 1, pivot: i, comparisons: comparisons))
            if a[i] == target { break }
        }
        return frames
    }
}

struct BinarySearchView: View {

    @State private var arrayBin: [Int] = []
    @State private var arrayLin: [Int] = []
    @State private var target = 0

    @State private var framesBin: [QSFrame] = []
    @State private var framesLin: [QSFrame] = []
    @State private var stepBin: Double = 0
    @State private var stepLin: Double = 0
    @State private var n: Double = 50

    private var targetIndex: Int? { arrayBin.firstIndex(of: target) }

    var body: some View {
        VStack(spacing: 16) {
            panel(title: "Binary search", frames: framesBin, step: stepBin)
            if framesBin.count > 1 {
                Slider(value: $stepBin, in: 0...Double(framesBin.count - 1), step: 1)
                Text("Binary: \(Int(stepBin)) / \(framesBin.count - 1)")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
            }

            panel(title: "Linear search", frames: framesLin, step: stepLin)
            if framesLin.count > 1 {
                Slider(value: $stepLin, in: 0...Double(framesLin.count - 1), step: 1)
                Text("Linear: \(Int(stepLin)) / \(framesLin.count - 1)")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
            }

            Text("Target: \(target)")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button("New") { reset() }.buttonStyle(.bordered)
                Button("Search") { run() }.buttonStyle(.borderedProminent)
            }

            Text("Number of elements in the array: \(Int(n))")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
            Slider(value: $n, in: 1...100, step: 1)
                .onChange(of: n) {
                    reset()
                }
        }
        .padding()
        .onAppear { if arrayBin.isEmpty { reset() } }
    }

    @ViewBuilder
    private func panel(title: String, frames: [QSFrame], step: Double) -> some View {
        let frame = frames.isEmpty
            ? QSFrame(array: arrayBin, lo: 0, hi: arrayBin.count - 1, pivot: -1, comparisons: 0)
            : frames[min(Int(step), frames.count - 1)]
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title).font(.caption).bold()
                Spacer()
                Text("\(frame.comparisons) comparisons")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
            }
            QSBars(frame: frame, targetIndex: targetIndex)
                .frame(height: 120)
                .padding(.vertical, 6)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(.gray.opacity(0.2)))
        }
    }

    private func run() {
        framesBin = BinarySearch.run(arrayBin, target: target)
        framesLin = BinarySearch.linear(arrayLin, target: target)
        stepBin = 0; stepLin = 0
    }

    private func reset() {
        let a = (0..<Int(n)).map { _ in Int.random(in: 0...99) }.sorted()
        arrayBin = a; arrayLin = a
        target = a.randomElement() ?? 0
        framesBin = []; framesLin = []
        stepBin = 0; stepLin = 0
    }
}

#Preview {
    BinarySearchView().preferredColorScheme(.dark)
}
