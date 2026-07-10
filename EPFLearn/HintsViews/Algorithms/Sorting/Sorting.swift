//
//  Sorting.swift
//  EPFLearn
//
//  Created by Mat on 27.06.2026.
//


enum Sorting {

    static func bubble(_ input: [Int]) -> [QSFrame] {
        var a = input
        var frames: [QSFrame] = []
        var comparisons = 0
        let n = a.count
        func snap(_ lo: Int, _ hi: Int, _ pivot: Int) {
            frames.append(QSFrame(array: a, lo: lo, hi: hi, pivot: pivot, comparisons: comparisons))
        }
        snap(0, n - 1, -1)
        guard n > 1 else { return frames }

        for end in stride(from: n - 1, through: 1, by: -1) {
            for j in 0..<end {
                comparisons += 1
                snap(0, end, j)                 // compare a[j] et a[j+1]
                if a[j] > a[j + 1] {
                    a.swapAt(j, j + 1)
                    snap(0, end, j + 1)         // après l'échange
                }
            }
        }
        snap(0, -1, -1)
        return frames
    }

    static func selection(_ input: [Int]) -> [QSFrame] {
        var a = input
        var frames: [QSFrame] = []
        var comparisons = 0
        let n = a.count
        func snap(_ lo: Int, _ hi: Int, _ pivot: Int) {
            frames.append(QSFrame(array: a, lo: lo, hi: hi, pivot: pivot, comparisons: comparisons))
        }
        snap(0, n - 1, -1)
        guard n > 1 else { return frames }

        for i in 0..<n {
            var minIdx = i
            snap(i, n - 1, i)
            for j in (i + 1)..<n {
                comparisons += 1
                snap(i, n - 1, j)               // on scrute a[j]
                if a[j] < a[minIdx] { minIdx = j }
            }
            if minIdx != i {
                a.swapAt(i, minIdx)
                snap(i, n - 1, i)               // on pose le minimum en i
            }
        }
        snap(0, -1, -1)
        return frames
    }

    static func insertion(_ input: [Int]) -> [QSFrame] {
        var a = input
        var frames: [QSFrame] = []
        var comparisons = 0
        let n = a.count
        func snap(_ lo: Int, _ hi: Int, _ pivot: Int) {
            frames.append(QSFrame(array: a, lo: lo, hi: hi, pivot: pivot, comparisons: comparisons))
        }
        snap(0, n - 1, -1)
        guard n > 1 else { return frames }

        for i in 1..<n {
            let key = a[i]
            var j = i
            snap(0, i, i)                       // on prend la clé a[i]
            while j > 0 {
                comparisons += 1
                snap(0, i, j)                   // compare a[j-1] et la clé
                if a[j - 1] > key {
                    a[j] = a[j - 1]
                    j -= 1
                    snap(0, i, j)               // on décale vers la droite
                } else {
                    break
                }
            }
            a[j] = key
            snap(0, i, j)                       // on insère la clé
        }
        snap(0, -1, -1)
        return frames
    }

    static func merge(_ input: [Int]) -> [QSFrame] {
        var a = input
        var frames: [QSFrame] = []
        var comparisons = 0
        let n = a.count
        func snap(_ lo: Int, _ hi: Int, _ pivot: Int) {
            frames.append(QSFrame(array: a, lo: lo, hi: hi, pivot: pivot, comparisons: comparisons))
        }
        snap(0, n - 1, -1)
        guard n > 1 else { return frames }

        func mergeRange(_ l: Int, _ m: Int, _ r: Int) {
            let left = Array(a[l...m])
            let right = Array(a[(m + 1)...r])
            var i = 0, j = 0, k = l
            while i < left.count && j < right.count {
                comparisons += 1
                snap(l, r, k)                   // compare les têtes des deux moitiés
                if left[i] <= right[j] { a[k] = left[i]; i += 1 }
                else { a[k] = right[j]; j += 1 }
                snap(l, r, k)                   // on écrit en k
                k += 1
            }
            while i < left.count  { a[k] = left[i];  i += 1; snap(l, r, k); k += 1 }
            while j < right.count { a[k] = right[j]; j += 1; snap(l, r, k); k += 1 }
        }
        func sort(_ l: Int, _ r: Int) {
            if l >= r { return }
            let m = (l + r) / 2
            sort(l, m)
            sort(m + 1, r)
            mergeRange(l, m, r)
        }
        sort(0, n - 1)
        snap(0, -1, -1)
        return frames
    }
}

