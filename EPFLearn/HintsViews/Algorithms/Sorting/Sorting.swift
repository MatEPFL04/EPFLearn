//
//  Sorting.swift
//  EPFLearn
//
//  Created by Mat on 27.06.2026.
//

// Algos de tri — logique pure, renvoie les états successifs du tableau.
// Même principe que `enum Graph` : la vue ne fait que rejouer les frames.
enum Sorting {
    
    static func insertion(_ input: [Int]) -> [[Int]] {
        var a = input
        var frames = [a]
        for j in 1..<a.count {
            let key = a[j]
            var i = j - 1
            while i >= 0 && a[i] > key {
                a[i + 1] = a[i]; i -= 1
                frames.append(a)
            }
            a[i + 1] = key
            frames.append(a)
        }
        return frames
    }

    static func merge(_ input: [Int]) -> [[Int]] {
        var a = input
        var frames = [a]

        func mergeStep(_ p: Int, _ q: Int, _ r: Int) {
            let L = Array(a[p...q]), R = Array(a[(q + 1)...r])
            var i = 0, j = 0, k = p
            while i < L.count && j < R.count {
                if L[i] <= R[j] { a[k] = L[i]; i += 1 } else { a[k] = R[j]; j += 1 }
                k += 1; frames.append(a)
            }
            while i < L.count { a[k] = L[i]; i += 1; k += 1; frames.append(a) }
            while j < R.count { a[k] = R[j]; j += 1; k += 1; frames.append(a) }
        }
        func sort(_ p: Int, _ r: Int) {
            guard p < r else { return }
            let q = (p + r) / 2
            sort(p, q); sort(q + 1, r); mergeStep(p, q, r)
        }
        sort(0, a.count - 1)
        return frames
    }
    
    static func heap(_ input: [Int]) -> [[Int]] {
        var a = input
        var frames = [a]
        let n = a.count

        func siftDown(_ start: Int, _ end: Int) {
            var root = start
            while 2 * root + 1 <= end {                 // tant qu'il y a un fils gauche
                let child = 2 * root + 1
                var swap = root
                if a[swap] < a[child] { swap = child }
                if child + 1 <= end && a[swap] < a[child + 1] { swap = child + 1 }
                if swap == root { return }              // parent ≥ ses fils : fini
                a.swapAt(root, swap)
                frames.append(a)
                root = swap
            }
        }

        // Phase 1 : construction du tas max (bottom-up)
        for start in stride(from: n / 2 - 1, through: 0, by: -1) {
            siftDown(start, n - 1)
        }

        // Phase 2 : on extrait le max vers la fin, on rétrécit le tas
        for end in stride(from: n - 1, through: 1, by: -1) {
            a.swapAt(0, end)
            frames.append(a)
            siftDown(0, end - 1)
        }

        return frames
    }
}
