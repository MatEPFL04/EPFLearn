//
//  MatrixOperationsView.swift
//  EPFLearn
//
//  Which shapes fit together, and what comes out. The shapes are set by
//  dragging a matrix by its corner handle.
//
//  Rewritten after several rounds of layout bugs that all came from one
//  mistake: earlier versions computed the cell size from the measured width,
//  so growing a matrix changed the cell size, which changed the drag pitch,
//  which changed how far the finger was deemed to have moved. The grid
//  juddered under a still finger, the row reflowed mid-gesture, and operators
//  were squeezed out of existence when the row overflowed.
//
//  The rule now is that **nothing about the layout depends on the shapes**.
//  Every matrix sits in a box sized for the largest shape allowed, its grid
//  pinned to that box's top-left corner, and the cell size is a constant.
//  Growing a matrix moves nothing but its own outline.
//
//  Shapes are capped at 3×3 rather than 4×4. That is what buys the whole
//  statement — operands, operator and result — a single row at a legible cell
//  size; at 4 it had to wrap onto a second line, which reads like two separate
//  things rather than one equation.
//

import SwiftUI

struct MatrixOperationsView: View {

    /// Set in challenge mode so the run can grade the shapes the student picks.
    var onReading: ((ChallengeReading) -> Void)? = nil

    struct Shape: Equatable {
        var rows: Int
        var cols: Int
    }

    enum Operation: String, CaseIterable, Identifiable {
        case multiply  = "Multiply (AB)"
        case add       = "Add (A+B)"
        case transpose = "Transpose (Aᵀ)"
        case scalar    = "Scalar Multiply (2A)"

        var id: Self { self }
        var usesB: Bool { self == .multiply || self == .add }
    }

    // MARK: Constant geometry

    /// Capped at 3. Four columns each forced the result onto a second line,
    /// which read badly: an operation is one statement and belongs on one row.
    static let maxSide = 3
    static let cell: CGFloat = 18
    static let gap: CGFloat = 2
    /// Pitch of the grid, and therefore of the drag. Constant by construction:
    /// this is the value that used to move while a finger was down.
    static let pitch: CGFloat = cell + gap
    /// Room for the largest shape, plus the outline's inset.
    static let slot: CGFloat = CGFloat(maxSide) * pitch + 8

    @State private var a = Shape(rows: 2, cols: 3)
    @State private var b = Shape(rows: 3, cols: 2)
    @State private var operation: Operation = .multiply

    // MARK: Derived

    private var productDefined: Bool { a.cols == b.rows }
    private var sumDefined: Bool { a == b }

    /// The shape that comes out, or nil when the operation is not defined.
    private var result: Shape? {
        switch operation {
        case .multiply:  return productDefined ? Shape(rows: a.rows, cols: b.cols) : nil
        case .add:       return sumDefined ? a : nil
        case .transpose: return Shape(rows: a.cols, cols: a.rows)
        case .scalar:    return a
        }
    }

    private var reading: MatrixShapeReading {
        MatrixShapeReading(aRows: a.rows, aCols: a.cols,
                           bRows: b.rows, bCols: b.cols,
                           operation: operation.rawValue)
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                VizHeader("Matrix Operations",
                          subtitle: "Drag a matrix by its corner to reshape it.")

                figure

                Picker("Operation", selection: $operation) {
                    ForEach(Operation.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(10)
        }
        .background(Color(.systemGroupedBackground))
        .onChange(of: reading, initial: true) { _, new in
            onReading?(.matrixShape(new))
        }
    }

    // MARK: Figure

    private var figure: some View {
        VStack(spacing: 14) {
            equationRow
            verdict
            Text(rule)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
    }

    /// The whole statement on one line: operands, operator, result.
    @ViewBuilder
    private var equationRow: some View {
        // Centred, not top-aligned: every box is the same height, so the
        // operators land level with the middle of the matrices they join
        // rather than floating up by their labels.
        HStack(alignment: .center, spacing: 12) {
            if operation == .scalar { symbol("2 ×") }

            MatrixBox(shape: $a, label: "A", color: .pink,
                      emphasis: operation == .multiply ? .firstRow : .none,
                      dimmed: operation == .multiply && !productDefined)

            if operation == .transpose { symbol("ᵀ") }

            if operation.usesB {
                symbol(operation == .multiply ? "×" : "+")
                MatrixBox(shape: $b, label: "B", color: .purple,
                          emphasis: operation == .multiply ? .firstColumn : .none,
                          dimmed: operation == .multiply && !productDefined)
            }

            symbol("=")

            if let r = result {
                MatrixBox(shape: .constant(r), label: resultLabel, color: .green,
                          draggable: false)
            } else {
                // The same footprint as a matrix, so switching between defined
                // and undefined never changes the size of anything.
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                    .frame(width: Self.slot, height: Self.slot)
            }
        }
    }

    /// Operators carry a fixed size and layout priority: when the row was
    /// overfull, these were the only flexible things in it and SwiftUI
    /// resolved the overflow by shrinking them to nothing.
    private func symbol(_ text: String) -> some View {
        Text(text)
            .font(.title3.bold())
            .foregroundStyle(.secondary)
            .fixedSize()
            .layoutPriority(1)
            .frame(minWidth: 18)
    }

    private var resultLabel: String {
        switch operation {
        case .multiply, .add: return "C"
        case .transpose:      return "Aᵀ"
        case .scalar:         return "2A"
        }
    }

    // MARK: Verdict

    @ViewBuilder
    private var verdict: some View {
        switch operation {
        case .multiply:
            badge(productDefined,
                  ok: "Compatible: the result is \(a.rows)×\(b.cols)",
                  no: "Not defined: A has \(a.cols) column\(a.cols == 1 ? "" : "s"), B has \(b.rows) row\(b.rows == 1 ? "" : "s")")
        case .add:
            badge(sumDefined,
                  ok: "Compatible: both are \(a.rows)×\(a.cols)",
                  no: "Not defined: \(a.rows)×\(a.cols) and \(b.rows)×\(b.cols) are different shapes")
        case .transpose:
            badge(true, ok: "\(a.rows)×\(a.cols) becomes \(a.cols)×\(a.rows)", no: "")
        case .scalar:
            badge(true, ok: "The shape never changes: still \(a.rows)×\(a.cols)", no: "")
        }
    }

    private func badge(_ good: Bool, ok: String, no: String) -> some View {
        let tint: Color = good ? .green : .red
        return Label(good ? ok : no,
                     systemImage: good ? "checkmark.circle.fill" : "xmark.circle.fill")
            .font(.caption)
            .foregroundStyle(tint)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 8).fill(tint.opacity(0.12)))
    }

    private var rule: String {
        switch operation {
        case .multiply:  return "(m×n) × (n×p) = (m×p)"
        case .add:       return "(m×n) + (m×n) = (m×n)"
        case .transpose: return "(m×n)ᵀ = (n×m)"
        case .scalar:    return "c · (m×n) = (m×n)"
        }
    }
}

// MARK: - One matrix

/// A matrix drawn inside a box of constant size, whatever its shape. Dragging
/// the corner handle reshapes it and moves nothing else on screen, which is
/// the entire point of the fixed box.
private struct MatrixBox: View {

    enum Emphasis { case none, firstRow, firstColumn }

    @Binding var shape: MatrixOperationsView.Shape
    let label: String
    let color: Color
    var emphasis: Emphasis = .none
    var dimmed: Bool = false
    var draggable: Bool = true

    /// The shape when the drag began. The pitch is a constant, so unlike the
    /// earlier versions there is nothing here the drag can feed back into.
    @State private var anchor: MatrixOperationsView.Shape? = nil

    private var pitch: CGFloat { MatrixOperationsView.pitch }
    private var gridWidth: CGFloat { CGFloat(shape.cols) * pitch + 6 }
    private var gridHeight: CGFloat { CGFloat(shape.rows) * pitch + 6 }

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)

            ZStack(alignment: .topLeading) {
                // The room the shape could grow into. Without it a 1×1 sat
                // alone in the corner of a box built for 3×3, which read as a
                // layout mistake and left the operators aligned with nothing.
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                    .foregroundStyle(color.opacity(draggable ? 0.28 : 0.12))
                    .frame(width: MatrixOperationsView.slot,
                           height: MatrixOperationsView.slot)

                RoundedRectangle(cornerRadius: 8)
                    .stroke(color, lineWidth: 2)
                    .frame(width: gridWidth, height: gridHeight)

                grid.padding(4)

                if draggable { handle }
            }
            .frame(width: MatrixOperationsView.slot,
                   height: MatrixOperationsView.slot,
                   alignment: .topLeading)

            Text("\(shape.rows)×\(shape.cols)")
                .font(.caption2.monospaced())
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
        }
    }

    private var grid: some View {
        VStack(spacing: MatrixOperationsView.gap) {
            ForEach(0..<shape.rows, id: \.self) { row in
                HStack(spacing: MatrixOperationsView.gap) {
                    ForEach(0..<shape.cols, id: \.self) { col in
                        let hot = (emphasis == .firstRow && row == 0)
                               || (emphasis == .firstColumn && col == 0)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(hot ? color.opacity(dimmed ? 0.45 : 1) : color.opacity(0.3))
                            .frame(width: MatrixOperationsView.cell,
                                   height: MatrixOperationsView.cell)
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .strokeBorder(hot && !dimmed ? Color.orange : .clear,
                                                  lineWidth: 2)
                            )
                    }
                }
            }
        }
    }

    /// 15pt of dot inside a 44pt touch target, riding the grid's corner.
    private var handle: some View {
        Circle()
            .fill(color)
            .overlay(Circle().strokeBorder(.white.opacity(0.9), lineWidth: 2))
            .frame(width: 15, height: 15)
            .frame(width: 44, height: 44)
            .contentShape(Circle())
            .offset(x: gridWidth - 22, y: gridHeight - 22)
            .gesture(
                DragGesture()
                    .onChanged { g in
                        let base = anchor ?? shape
                        if anchor == nil { anchor = base }
                        let cols = (Double(base.cols) + g.translation.width / pitch).rounded()
                        let rows = (Double(base.rows) + g.translation.height / pitch).rounded()
                        shape = .init(rows: clampSide(rows), cols: clampSide(cols))
                    }
                    .onEnded { _ in anchor = nil }
            )
    }

    private func clampSide(_ v: Double) -> Int {
        min(max(Int(v), 1), MatrixOperationsView.maxSide)
    }
}

#Preview {
    MatrixOperationsView()
        .preferredColorScheme(.dark)
}
