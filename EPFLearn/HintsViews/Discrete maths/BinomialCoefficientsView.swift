//
//  BinomialCoefficientsView.swift
//  EPFLearn
//
//  Rebuilt: a real, centred Pascal triangle with animated parent links
//  and four pattern overlays (Pascal, parity/Sierpiński, row sums, Fibonacci).
//

import SwiftUI

struct BinomialCoefficientsView: View {

    // MARK: Patterns

    enum Pattern: String, CaseIterable, Hashable {
        case pascal, parity, rowSums, fibonacci

        var title: String {
            switch self {
            case .pascal:    return "Pascal"
            case .parity:    return "Parity"
            case .rowSums:   return "Sums"
            case .fibonacci: return "Fibonacci"
            }
        }
        var tint: Color {
            switch self {
            case .pascal:    return DMTheme.violet
            case .parity:    return DMTheme.rose
            case .rowSums:   return DMTheme.cyan
            case .fibonacci: return DMTheme.amber
            }
        }
        var explanation: String {
            switch self {
            case .pascal:
                return "Tap any cell: it lights up its two parents. Every entry is the sum of the two directly above it."
            case .parity:
                return "Colour only the odd numbers and Pascal's triangle turns into the Sierpiński gasket — a fractal hiding inside a table of integers."
            case .rowSums:
                return "Row n always adds up to 2ⁿ. Reason: choosing any subset of n items means, for each item, keeping it or not — that's 2ⁿ subsets, sorted by size."
            case .fibonacci:
                return "Add along the shallow diagonals (row + column constant) and you get the Fibonacci numbers: 1, 1, 2, 3, 5, 8, 13…"
            }
        }
    }

    // MARK: State

    @State private var rows = 6
    @State private var pattern: Pattern = .pascal
    @State private var selected: (n: Int, k: Int)? = nil
    @State private var focusedDiagonal: Int = 4

    private let hSpacing: CGFloat = 6
    private let vSpacing: CGFloat = 6

    private var tint: Color { pattern.tint }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                DMHero(title: "Pascal's Triangle",
                       subtitle: "C(n,k) counts the ways to pick k items from n — and the whole triangle is built by simple addition.",
                       symbol: "triangle.fill",
                       tint: tint)

                DMSegmented(selection: $pattern,
                            options: Pattern.allCases,
                            label: { $0.title },
                            tint: tint)

                HStack(spacing: 14) {
                    DMStepper(title: "Rows", value: $rows, range: 3...9, tint: tint)
                        .onChange(of: rows) { _, newValue in
                            if let s = selected, s.n >= newValue { selected = nil }
                            focusedDiagonal = min(focusedDiagonal, max(0, newValue - 1))
                        }
                    if pattern == .fibonacci {
                        DMStepper(title: "Diagonal", value: $focusedDiagonal,
                                  range: 0...max(0, rows - 1), tint: tint)
                    }
                }

                if let s = selected { detailCard(n: s.n, k: s.k) }

                triangleCard
                patternCard
            }
            .padding(20)
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: pattern)
        }
        .background(DMAurora(tint: tint, accent: DMTheme.indigo))
    }

    // MARK: Triangle

    private var triangleCard: some View {
        DMCard(tint: tint, padding: 14) {
            GeometryReader { geo in
                let gutter: CGFloat = pattern == .rowSums ? 46 : 0
                let available = geo.size.width - gutter
                let cell = cellSize

                ZStack(alignment: .topLeading) {
                    // Parent links, drawn behind the cells.
                    Canvas { ctx, _ in
                        guard let s = selected, s.n > 0 else { return }
                        let child = centre(n: s.n, k: s.k, cell: cell, width: available)
                        for parentK in [s.k - 1, s.k] where parentK >= 0 && parentK <= s.n - 1 {
                            let parent = centre(n: s.n - 1, k: parentK, cell: cell, width: available)
                            var path = Path()
                            path.move(to: parent)
                            path.addLine(to: child)
                            ctx.stroke(path,
                                       with: .color(DMTheme.amber.opacity(0.85)),
                                       style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                        }
                    }
                    .frame(width: available, height: triangleHeight)

                    ForEach(0..<rows, id: \.self) { n in
                        ForEach(0...n, id: \.self) { k in
                            cellView(n: n, k: k, cell: cell)
                                .position(centre(n: n, k: k, cell: cell, width: available))
                        }
                    }

                    if pattern == .rowSums {
                        ForEach(0..<rows, id: \.self) { n in
                            Text("2\(superscript(n))")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(DMTheme.cyan)
                                .padding(.vertical, 3).padding(.horizontal, 6)
                                .background(Capsule().fill(DMTheme.cyan.opacity(0.16)))
                                .position(x: available + gutter / 2,
                                          y: CGFloat(n) * (cell + vSpacing) + cell / 2)
                        }
                    }
                }
                .frame(width: geo.size.width, height: triangleHeight, alignment: .topLeading)
            }
            .frame(height: triangleHeight)
        }
    }

    /// Deterministic so the enclosing card can reserve exactly the right height.
    private var cellSize: CGFloat {
        let base: CGFloat
        switch rows {
        case ..<5:  base = 46
        case 5:     base = 44
        case 6:     base = 40
        case 7:     base = 36
        case 8:     base = 32
        default:    base = 28
        }
        return pattern == .rowSums ? base - 4 : base
    }

    private var triangleHeight: CGFloat {
        CGFloat(rows) * (cellSize + vSpacing) - vSpacing
    }

    private func centre(n: Int, k: Int, cell: CGFloat, width: CGFloat) -> CGPoint {
        let step = cell + hSpacing
        let rowWidth = CGFloat(n + 1) * step - hSpacing
        let x = width / 2 - rowWidth / 2 + CGFloat(k) * step + cell / 2
        let y = CGFloat(n) * (cell + vSpacing) + cell / 2
        return CGPoint(x: x, y: y)
    }

    @ViewBuilder
    private func cellView(n: Int, k: Int, cell: CGFloat) -> some View {
        let value = DMMath.binomial(n, k)
        let isSelected = selected.map { $0.n == n && $0.k == k } ?? false
        let isParent = isParentOfSelection(n: n, k: k)
        let style = cellStyle(n: n, k: k, isSelected: isSelected, isParent: isParent)

        Text("\(value)")
            .font(.system(size: min(17, cell * 0.40),
                          weight: isSelected || isParent ? .heavy : .semibold,
                          design: .rounded))
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .foregroundStyle(style.text)
            .frame(width: cell, height: cell)
            .background(
                RoundedRectangle(cornerRadius: cell * 0.28, style: .continuous)
                    .fill(style.fill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cell * 0.28, style: .continuous)
                    .strokeBorder(style.border, lineWidth: style.borderWidth)
            )
            .scaleEffect(isSelected ? 1.16 : (isParent ? 1.06 : 1))
            .shadow(color: isSelected ? tint.opacity(0.5) : .clear, radius: 8, y: 3)
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    if isSelected { selected = nil } else { selected = (n, k) }
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isSelected)
            .animation(.easeInOut(duration: 0.25), value: pattern)
    }

    private struct CellStyle {
        var fill: Color
        var text: Color
        var border: Color
        var borderWidth: CGFloat
    }

    private func cellStyle(n: Int, k: Int, isSelected: Bool, isParent: Bool) -> CellStyle {
        if isSelected {
            return CellStyle(fill: tint, text: .white, border: .clear, borderWidth: 0)
        }
        if isParent {
            return CellStyle(fill: DMTheme.amber.opacity(0.28), text: DMTheme.amber,
                             border: DMTheme.amber, borderWidth: 2)
        }

        switch pattern {
        case .pascal, .rowSums:
            let depth = Double(n) / Double(max(rows - 1, 1))
            return CellStyle(fill: tint.opacity(0.08 + depth * 0.16),
                             text: tint, border: .clear, borderWidth: 0)

        case .parity:
            let odd = DMMath.binomial(n, k) % 2 == 1
            return CellStyle(fill: odd ? DMTheme.rose.opacity(0.85) : Color.primary.opacity(0.04),
                             text: odd ? .white : Color.secondary.opacity(0.5),
                             border: .clear, borderWidth: 0)

        case .fibonacci:
            let onDiagonal = (n + k == focusedDiagonal) && (k <= n - k)
            if onDiagonal {
                return CellStyle(fill: DMTheme.amber.opacity(0.85), text: .white,
                                 border: .clear, borderWidth: 0)
            }
            return CellStyle(fill: Color.primary.opacity(0.04),
                             text: Color.secondary.opacity(0.6),
                             border: .clear, borderWidth: 0)
        }
    }

    private func isParentOfSelection(n: Int, k: Int) -> Bool {
        guard let s = selected, s.n > 0, n == s.n - 1 else { return false }
        return k == s.k - 1 || k == s.k
    }

    // MARK: Detail of the tapped cell

    private func detailCard(n: Int, k: Int) -> some View {
        let value = DMMath.binomial(n, k)
        let isEdge = (k == 0 || k == n)

        return DMCard(tint: tint) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("C(\(n),\(k)) = \(value)")
                        .font(.system(.title3, design: .rounded).weight(.heavy))
                        .foregroundStyle(DMTheme.grad(tint))
                        .contentTransition(.numericText())
                    Spacer()
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { selected = nil }
                    } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                if isEdge {
                    DMBanner(text: "Edge of the triangle: there is exactly one way to pick none of the \(n) items, or all of them.",
                             symbol: "arrow.left.and.right",
                             tint: DMTheme.amber)
                } else {
                    DMFormula(text: "C(\(n),\(k)) = C(\(n-1),\(k-1)) + C(\(n-1),\(k)) = \(DMMath.binomial(n-1, k-1)) + \(DMMath.binomial(n-1, k))",
                              tint: DMTheme.amber, emphasised: true)
                }

                DMFormula(text: "= \(n)! / (\(k)!·\(n - k)!) = \(value)", tint: tint)

                if k != n - k {
                    Text("Symmetry: C(\(n),\(k)) = C(\(n),\(n - k)) — picking k to keep is the same as picking \(n - k) to leave behind.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .transition(.scale(scale: 0.94).combined(with: .opacity))
    }

    // MARK: Pattern explanation

    private var patternCard: some View {
        DMCard(tint: tint) {
            VStack(alignment: .leading, spacing: 10) {
                DMSectionTitle(text: pattern.title, symbol: "sparkles", tint: tint)

                Text(pattern.explanation)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                switch pattern {
                case .rowSums:
                    DMFormula(text: "Σₖ C(n,k) = 2ⁿ   →   row \(rows - 1) sums to \(1 << (rows - 1))",
                              tint: DMTheme.cyan, emphasised: true)
                case .fibonacci:
                    DMFormula(text: "diagonal \(focusedDiagonal): \(diagonalBreakdown) = F\(DMMath.subscriptDigits(focusedDiagonal + 1))",
                              tint: DMTheme.amber, emphasised: true)
                case .parity:
                    DMFormula(text: "odd entries only → Sierpiński gasket",
                              tint: DMTheme.rose, emphasised: true)
                case .pascal:
                    DMFormula(text: "C(n,k) = C(n−1,k−1) + C(n−1,k)",
                              tint: DMTheme.violet, emphasised: true)
                }
            }
        }
    }

    private var diagonalBreakdown: String {
        let d = focusedDiagonal
        var terms: [String] = []
        var sum = 0
        var k = 0
        while k <= d - k {
            let n = d - k
            guard n < rows else { break }
            terms.append("\(DMMath.binomial(n, k))")
            sum += DMMath.binomial(n, k)
            k += 1
        }
        guard !terms.isEmpty else { return "—" }
        return terms.joined(separator: " + ") + " = \(sum)"
    }

    private func superscript(_ n: Int) -> String {
        let table = ["⁰", "¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹"]
        return String(n).compactMap { Int(String($0)).map { table[$0] } }.joined()
    }
}

#Preview {
    BinomialCoefficientsView()
}
