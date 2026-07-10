//
//  ArrayView.swift
//  EPFLearn
//
//  Created by Mat on 27.06.2026.
//
import SwiftUI

struct ArrayView: Shape {
    var array: [Int]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard !array.isEmpty else { return path }

        let maxAbs = CGFloat(array.map { abs($0) }.max() ?? 1)
        let scale = maxAbs == 0 ? 1 : (rect.height / 2 - 10) / maxAbs
        let delta = rect.width / CGFloat(array.count)
        let baseline = rect.midY

        for (i, elm) in array.enumerated() {
            let x = rect.minX + delta * (CGFloat(i) + 0.5)
            let top = baseline - CGFloat(elm) * scale
            path.move(to: CGPoint(x: x, y: baseline))
            path.addLine(to: CGPoint(x: x, y: top))
        }
        return path
    }
}


#Preview {
    SortingView()
}
