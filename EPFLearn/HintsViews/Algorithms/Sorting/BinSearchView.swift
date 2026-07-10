//
//  BinSearch.swift
//  EPFLearn
//
//  Created by Mat on 27.06.2026.
//
enum BinarySearch {
    static func run(_ input: [Int], target: Int) -> [QSFrame] {
        let a = input.sorted()                       // binary search exige un tableau trié
        var frames: [QSFrame] = []
        var comparisons = 0
        var lo = 0, hi = a.count - 1

        // état initial : fenêtre = tout le tableau, aucun mid encore testé
        frames.append(QSFrame(array: a, lo: lo, hi: hi, pivot: -1, comparisons: 0))

        while lo <= hi {
            let mid = (lo + hi) / 2
            comparisons += 1
            frames.append(QSFrame(array: a, lo: lo, hi: hi, pivot: mid, comparisons: comparisons))

            if a[mid] == target {                    // trouvé : on fige la fenêtre sur le seul mid
                frames.append(QSFrame(array: a, lo: mid, hi: mid, pivot: mid, comparisons: comparisons))
                return frames
            } else if a[mid] < target {
                lo = mid + 1                         // on jette la moitié gauche
            } else {
                hi = mid - 1                         // on jette la moitié droite
            }
        }
        // pas trouvé : fenêtre vide
        frames.append(QSFrame(array: a, lo: 0, hi: -1, pivot: -1, comparisons: comparisons))
        return frames
    }
}
struct BinarySearchView: View {

    @State private var arrayBin: [Int] = []
    @State private var arrayLin: [Int] = []
    @State private var target = 0

    @State private var framesBin: [QSFrame] = []
    @State private var framesLin: [QSFrame] = []
    @State private var step: Double = 0

    private var maxStep: Int { max(0, max(framesBin.count, framesLin.count) - 1) }

    var body: some View {
        VStack(spacing: 16) {
            panel(title: "Binary search", frames: framesBin)
            panel(title: "Linear search", frames: framesLin)

            Text("Cible : \(target)")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)

            if maxStep > 0 {
                VStack(spacing: 4) {
                    Slider(value: $step, in: 0...Double(maxStep), step: 1)
                    Text("Étape \(Int(step)) / \(maxStep)")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 12) {
                Button("Nouveau") { reset() }.buttonStyle(.bordered)
                Button("Chercher") { run() }.buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .onAppear { if arrayBin.isEmpty { reset() } }
    }

    @ViewBuilder
    private func panel(title: String, frames: [QSFrame]) -> some View {
        let frame = frames.isEmpty
            ? QSFrame(array: arrayBin, lo: 0, hi: arrayBin.count - 1, pivot: -1, comparisons: 0)
            : frames[min(Int(step), frames.count - 1)]
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
                .frame(height: 120)
                .padding(.vertical, 6)
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(.gray.opacity(0.2)))
        }
    }

    private func run() {
        framesBin = BinarySearch.run(arrayBin, target: target)
        framesLin = BinarySearch.linear(arrayLin, target: target)
        step = 0
    }

    private func reset() {
        let a = (0..<31).map { _ in Int.random(in: 0...99) }.sorted()
        arrayBin = a; arrayLin = a
        target = a.randomElement() ?? 0
        framesBin = []; framesLin = []; step = 0
    }
}

#Preview {
    BinarySearchView().preferredColorScheme(.dark)
}
