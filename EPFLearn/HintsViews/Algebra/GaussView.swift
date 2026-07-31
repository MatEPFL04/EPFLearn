//
//  GaussView.swift
//  LearnViz
//
//  Gaussian elimination shown three ways at once: as three planes in space,
//  as a system of equations, and as the augmented matrix.
//  Reuses V3 / Projector / BracketShape from Matrix3DView.swift and the shared
//  chrome from SharedMatrixComponents.swift.
//

import SwiftUI

// MARK: - Elementary row operations

enum RowOp {
    case scale(row: Int, factor: Double)
    case combine(target: Int, source: Int, factor: Double)
    case swap(Int, Int)

    /// Full notation, written next to the matrix.
    var matrixLabel: String {
        switch self {
        case .scale(let r, let f):
            return "L\(sub(r)) → \(coefficient(f))L\(sub(r))"
        case .combine(let t, let s, let f):
            return "L\(sub(t)) → L\(sub(t)) \(signedTerm(f, "L\(sub(s))"))"
        case .swap(let a, let b):
            return "L\(sub(a)) ↔ L\(sub(b))"
        }
    }

    /// Compact operator, hanging off the equation.
    var systemBadge: String {
        switch self {
        case .scale(_, let f):          return "× \(pretty(f))"
        case .combine(_, let s, let f): return signedTerm(f, "L\(sub(s))")
        case .swap(_, let b):           return "↔ L\(sub(b))"
        }
    }

    var target: Int {
        switch self {
        case .scale(let r, _):     return r
        case .combine(let t, _, _): return t
        case .swap(let a, _):      return a
        }
    }

    var source: Int? {
        switch self {
        case .scale:                return nil
        case .combine(_, let s, _): return s
        case .swap(_, let b):       return b
        }
    }

    func applied(to m: [[Double]]) -> [[Double]] {
        var out = m
        switch self {
        case .scale(let r, let f):
            for c in 0..<4 { out[r][c] = clean(out[r][c] * f) }
        case .combine(let t, let s, let f):
            for c in 0..<4 { out[t][c] = clean(out[t][c] + f * out[s][c]) }
        case .swap(let a, let b):
            out.swapAt(a, b)
        }
        return out
    }
}

struct GaussStep {
    let op: RowOp
    let caption: String
}

/// A worked example: a starting matrix, a script, and every intermediate state.
struct GaussExample {
    let name: String
    let start: [[Double]]
    let script: [GaussStep]
    let states: [[[Double]]]

    init(name: String, start: [[Double]], script: [GaussStep]) {
        self.name = name
        self.start = start
        self.script = script
        var all = [start]
        var cur = start
        for s in script { cur = s.op.applied(to: cur); all.append(cur) }
        self.states = all
    }
}

// MARK: - Solution set

/// What the three planes actually share. Row operations never change it, which
/// is exactly what the viewport is there to show: the planes swing around while
/// this stays nailed in place.
enum SolutionSet {
    case empty
    case point(V3)
    case line(through: V3, direction: V3)
    case plane(through: V3, u: V3, v: V3)
}

/// Reduced row echelon form, used once on the starting matrix to work out the
/// solution set. Deliberately separate from the scripted steps: the point of
/// the view is that the answer does not depend on the route taken.
private func solutionSet(of matrix: [[Double]]) -> SolutionSet {
    var m = matrix
    var pivotRow = 0
    var pivotCols: [Int] = []

    for col in 0..<3 {
        guard pivotRow < 3 else { break }
        var best = pivotRow
        for r in pivotRow..<3 where abs(m[r][col]) > abs(m[best][col]) { best = r }
        guard abs(m[best][col]) > 1e-9 else { continue }
        m.swapAt(pivotRow, best)

        let p = m[pivotRow][col]
        for c in 0..<4 { m[pivotRow][c] = clean(m[pivotRow][c] / p) }
        for r in 0..<3 where r != pivotRow {
            let f = m[r][col]
            guard abs(f) > 1e-12 else { continue }
            for c in 0..<4 { m[r][c] = clean(m[r][c] - f * m[pivotRow][c]) }
        }
        pivotCols.append(col)
        pivotRow += 1
    }

    // A row reading 0 = k with k nonzero kills the whole system.
    for r in 0..<3 {
        let leftEmpty = (0..<3).allSatisfy { abs(m[r][$0]) < 1e-9 }
        if leftEmpty && abs(m[r][3]) > 1e-9 { return .empty }
    }

    // Particular solution: free variables set to zero.
    var base = [0.0, 0.0, 0.0]
    for (i, col) in pivotCols.enumerated() { base[col] = m[i][3] }
    let point = V3(base[0], base[1], base[2])

    let free = (0..<3).filter { !pivotCols.contains($0) }
    if free.isEmpty { return .point(point) }

    /// Direction obtained by setting one free variable to 1.
    func direction(_ freeCol: Int) -> V3 {
        var d = [0.0, 0.0, 0.0]
        d[freeCol] = 1
        for (i, col) in pivotCols.enumerated() { d[col] = -m[i][freeCol] }
        return V3(d[0], d[1], d[2])
    }

    if free.count == 1 { return .line(through: point, direction: direction(free[0])) }
    return .plane(through: point, u: direction(free[0]), v: direction(free[1]))
}

// MARK: - Plane geometry

/// The polygon where a plane meets the viewing box, so a plane can be drawn as
/// a finite surface instead of an infinite one.
private func planePolygon(_ row: [Double], half: Double) -> [V3] {
    let n = V3(row[0], row[1], row[2])
    guard n.norm > 1e-9 else { return [] }
    let d = row[3]

    let corners: [V3] = [
        V3(-half, -half, -half), V3(half, -half, -half),
        V3(half, half, -half), V3(-half, half, -half),
        V3(-half, -half, half), V3(half, -half, half),
        V3(half, half, half), V3(-half, half, half)
    ]
    let edges: [(Int, Int)] = [
        (0, 1), (1, 2), (2, 3), (3, 0),
        (4, 5), (5, 6), (6, 7), (7, 4),
        (0, 4), (1, 5), (2, 6), (3, 7)
    ]

    var hits: [V3] = []
    for (i, j) in edges {
        let a = corners[i], b = corners[j]
        let fa = n.dot(a) - d
        let fb = n.dot(b) - d
        if abs(fa) < 1e-9 { hits.append(a); continue }
        if abs(fb) < 1e-9 { hits.append(b); continue }
        if fa * fb < 0 {
            let t = fa / (fa - fb)
            hits.append(a + t * (b - a))
        }
    }
    guard hits.count >= 3 else { return [] }

    // Drop duplicates picked up at shared corners.
    var unique: [V3] = []
    for h in hits where !unique.contains(where: { ($0 - h).norm < 1e-6 }) {
        unique.append(h)
    }
    guard unique.count >= 3 else { return [] }

    // Order them around the centroid, in the plane, or the polygon self-crosses.
    let centroid = unique.reduce(V3.zero, +) * (1.0 / Double(unique.count))
    let normal = n.unit
    var u = normal.cross(V3(0, 0, 1))
    if u.norm < 1e-6 { u = normal.cross(V3(0, 1, 0)) }
    u = u.unit
    let v = normal.cross(u).unit

    return unique.sorted { p, q in
        let dp = p - centroid, dq = q - centroid
        return atan2(dp.dot(v), dp.dot(u)) < atan2(dq.dot(v), dq.dot(u))
    }
}

// MARK: - Main view

struct GaussView: View {

    @State private var step: Int = 0
    @State private var exampleIndex: Int = 0

    @State private var azimuth: Double = -0.9
    @State private var elevation: Double = 0.42
    @State private var distance: Double = 9.5

    static let warm = Color(red: 1.00, green: 0.80, blue: 0.26)
    static let warmUI = Color(red: 0.72, green: 0.50, blue: 0.00)
    static let cellW: CGFloat = 40
    static let rowH: CGFloat = 30

    /// One colour per equation, kept away from the red/green/blue used for
    /// x, y and z inside the equations themselves.
    static let rowColors: [Color] = [
        Color(red: 0.35, green: 0.78, blue: 0.98),
        Color(red: 0.95, green: 0.42, blue: 0.62),
        Color(red: 0.62, green: 0.85, blue: 0.42)
    ]

    private let boxHalf: Double = 3.0

    // MARK: Examples

    /// x = 1, y = 2, z = 3.
    static let unique = GaussExample(
        name: "Unique solution",
        start: [[1, 2, 1, 8],
                [2, 1, -1, 1],
                [1, -1, 2, 5]],
        script: [
            GaussStep(op: .combine(target: 1, source: 0, factor: -2),
                      caption: "Clear x from L₂ using the pivot of L₁."),
            GaussStep(op: .combine(target: 2, source: 0, factor: -1),
                      caption: "Clear x from L₃ with the same pivot."),
            GaussStep(op: .scale(row: 1, factor: -1.0 / 3),
                      caption: "Normalise the second pivot to 1."),
            GaussStep(op: .combine(target: 0, source: 1, factor: -2),
                      caption: "Clear y from L₁. Jordan also cleans upwards."),
            GaussStep(op: .combine(target: 2, source: 1, factor: 3),
                      caption: "Clear y from L₃."),
            GaussStep(op: .scale(row: 2, factor: 1.0 / 4),
                      caption: "Normalise the third pivot to 1."),
            GaussStep(op: .combine(target: 0, source: 2, factor: 1),
                      caption: "Clear z from L₁."),
            GaussStep(op: .combine(target: 1, source: 2, factor: -1),
                      caption: "Clear z from L₂. The left block is now the identity, and the three planes have become the three coordinate planes through the solution.")
        ])

    /// L₂ = 2·L₁ on the left, but not on the right: elimination exposes 0 = 1.
    static let none = GaussExample(
        name: "No solution",
        start: [[1, 1, 1, 2],
                [2, 2, 2, 5],
                [1, -1, 0, 1]],
        script: [
            GaussStep(op: .combine(target: 1, source: 0, factor: -2),
                      caption: "Clear x from L₂. Its plane vanishes: L₁ and L₂ were parallel, so nothing is left to intersect."),
            GaussStep(op: .combine(target: 2, source: 0, factor: -1),
                      caption: "Clear x from L₃ as usual."),
            GaussStep(op: .scale(row: 2, factor: -1.0 / 2),
                      caption: "Normalise L₃ to expose the second pivot."),
            GaussStep(op: .swap(1, 2),
                      caption: "Move the impossible line to the bottom. Two planes remain and they meet along a line, but that line satisfies neither of the original parallel planes.")
        ])

    /// L₂ = 2·L₁ on both sides: one equation is pure redundancy.
    static let many = GaussExample(
        name: "Infinitely many",
        start: [[1, 1, 1, 3],
                [2, 2, 2, 6],
                [1, -1, 0, 0]],
        script: [
            GaussStep(op: .combine(target: 1, source: 0, factor: -2),
                      caption: "Clear x from L₂. The whole line vanishes: L₂ was the same plane as L₁, drawn twice."),
            GaussStep(op: .combine(target: 2, source: 0, factor: -1),
                      caption: "Clear x from L₃."),
            GaussStep(op: .scale(row: 2, factor: -1.0 / 2),
                      caption: "Normalise the second pivot to 1."),
            GaussStep(op: .swap(1, 2),
                      caption: "Move the empty line to the bottom."),
            GaussStep(op: .combine(target: 0, source: 1, factor: -1),
                      caption: "Clear y from L₁. Two planes for three unknowns, so the answer is the whole line where they cross.")
        ])

    static let examples: [GaussExample] = [unique, none, many]

    private var example: GaussExample { GaussView.examples[exampleIndex] }
    
    // SAFE BINDINGS: Garantit qu'un changement d'exemple réinitialise proprement l'index sans crash
    private var safeStep: Int {
        min(step, example.script.count)
    }

    private var safeMatrixStep: Int {
        min(step, example.states.count - 1)
    }

    private var m: [[Double]] { example.states[safeMatrixStep] }
    
    private var pending: RowOp? {
        safeStep < example.script.count ? example.script[safeStep].op : nil
    }
    
    private var done: Bool { safeStep == example.script.count }

    /// Computed from the starting matrix, never from the current one: this is
    /// the quantity the whole method is designed to preserve.
    private var solution: SolutionSet { solutionSet(of: example.start) }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                AlgebraHeader(
                    title: "Gaussian Elimination",
                    subtitle: "Each equation is a plane. Row operations move the planes, never their intersection."
                )

                AlgebraViewport(
                    azimuth: $azimuth,
                    elevation: $elevation,
                    distance: $distance,
                    distanceRange: 6...20,
                    home: (azimuth: -0.9, elevation: 0.42, distance: 9.5),
                    accent: GaussView.warm,
                    render: { ctx, size in render(ctx, size: size) },
                    hud: { hud },
                    legend: { legend }
                )

                stepControl
                stage
            }
            .padding(14)
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - 3D scene

    private func render(_ ctx: GraphicsContext, size: CGSize) {
        let p = Projector(azimuth: azimuth, elevation: elevation, distance: distance, size: size)
        drawAxes(ctx, p)
        drawPlanes(ctx, p)
        drawSolution(ctx, p)
    }

    private func drawAxes(_ ctx: GraphicsContext, _ p: Projector) {
        let axes: [(V3, Color, String)] = [
            (V3(boxHalf + 0.6, 0, 0), .red, "x"),
            (V3(0, boxHalf + 0.6, 0), .green, "y"),
            (V3(0, 0, boxHalf + 0.4), .blue, "z")
        ]
        for (end, color, label) in axes {
            if let s = p.segment((-1.0) * end, end) {
                var path = Path()
                path.move(to: s.0); path.addLine(to: s.1)
                ctx.stroke(path, with: .color(color.opacity(0.28)), lineWidth: 1)
            }
            if let tip = p.project(end) {
                ctx.draw(Text(label).font(.system(size: 11, weight: .bold))
                            .foregroundStyle(color.opacity(0.75)),
                        at: CGPoint(x: tip.x + 9, y: tip.y - 7))
            }
        }
    }

    /// Painter's algorithm on the plane centroids, so overlaps read correctly.
    private func drawPlanes(_ ctx: GraphicsContext, _ p: Projector) {
        var faces: [(depth: Double, path: Path, color: Color, emphasis: Double)] = []

        for r in 0..<3 {
            let poly = planePolygon(m[r], half: boxHalf)
            guard poly.count >= 3 else { continue }

            var screen: [CGPoint] = []
            var ok = true
            for w in poly {
                guard let s = p.project(w) else { ok = false; break }
                screen.append(s)
            }
            guard ok, screen.count >= 3 else { continue }

            var path = Path()
            path.move(to: screen[0])
            for q in screen.dropFirst() { path.addLine(to: q) }
            path.closeSubpath()

            let centroid = poly.reduce(V3.zero, +) * (1.0 / Double(poly.count))
            let emphasis: Double = (pending?.target == r) ? 1.0
                                : ((pending?.source == r) ? 0.75 : 0.45)
            faces.append((p.depth(centroid), path, GaussView.rowColors[r], emphasis))
        }

        for f in faces.sorted(by: { $0.depth > $1.depth }) {
            ctx.fill(f.path, with: .color(f.color.opacity(0.10 + 0.13 * f.emphasis)))
            ctx.stroke(f.path, with: .color(f.color.opacity(0.35 + 0.5 * f.emphasis)),
                       lineWidth: 1 + f.emphasis)
        }
    }

    /// The invariant: a point, a line, a plane, or nothing at all.
    private func drawSolution(_ ctx: GraphicsContext, _ p: Projector) {
        switch solution {
        case .empty:
            return

        case .point(let q):
            guard let s = p.project(q) else { return }
            var glow = ctx
            glow.blendMode = .plusLighter
            glow.fill(Path(ellipseIn: CGRect(x: s.x - 9, y: s.y - 9, width: 18, height: 18)),
                      with: .color(GaussView.warm.opacity(0.35)))
            glow.fill(Path(ellipseIn: CGRect(x: s.x - 4, y: s.y - 4, width: 8, height: 8)),
                      with: .color(.white))
            ctx.draw(Text("solution").font(.system(size: 10, weight: .bold))
                                .foregroundStyle(GaussView.warm),
                    at: CGPoint(x: s.x + 34, y: s.y - 12))

        case .line(let through, let direction):
            let d = direction.unit
            let k = boxHalf * 1.7
            guard let s = p.segment(through - k * d, through + k * d) else { return }
            var path = Path()
            path.move(to: s.0); path.addLine(to: s.1)
            ctx.stroke(path, with: .color(GaussView.warm),
                       style: StrokeStyle(lineWidth: 3, lineCap: .round))
            ctx.draw(Text("solutions").font(.system(size: 10, weight: .bold))
                                .foregroundStyle(GaussView.warm),
                    at: CGPoint(x: (s.0.x + s.1.x) / 2 + 38, y: (s.0.y + s.1.y) / 2 - 12))

        case .plane(let through, let u, let v):
            let k = boxHalf * 1.2
            let corners = [through - k * u - k * v, through + k * u - k * v,
                           through + k * u + k * v, through - k * u + k * v]
            var screen: [CGPoint] = []
            for c in corners {
                guard let s = p.project(c) else { return }
                screen.append(s)
            }
            var path = Path()
            path.move(to: screen[0])
            for q in screen.dropFirst() { path.addLine(to: q) }
            path.closeSubpath()
            ctx.fill(path, with: .color(GaussView.warm.opacity(0.2)))
        }
    }

    // MARK: - Viewport overlays

    private var hud: some View {
        AlgebraHUD(headline: verdict.title,
                   detail: solutionHeadline,
                   color: verdict.color)
    }

    private var solutionHeadline: String {
        switch solution {
        case .empty:      return "The three planes share no point."
        case .point:      return "The three planes meet at one point."
        case .line:       return "The planes meet along a line."
        case .plane:      return "The planes meet on a whole plane."
        }
    }

    private var legend: some View {
        HStack(spacing: 9) {
            ForEach(0..<3, id: \.self) { r in
                HStack(spacing: 4) {
                    Rectangle()
                        .fill(GaussView.rowColors[r])
                        .frame(width: 10, height: 3)
                    Text("L\(sub(r))")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(GaussView.rowColors[r])
                }
            }
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(.black.opacity(0.45), in: Capsule())
    }

    // MARK: - Verdict, read off the current matrix

    private struct Verdict {
        let title: String
        let detail: String
        let icon: String
        let color: Color
    }

    private var verdict: Verdict {
        for r in 0..<3 {
            let emptyLeft: Bool = (0..<3).allSatisfy { abs(m[r][$0]) < 1e-9 }
            if emptyLeft && abs(m[r][3]) > 1e-9 {
                return Verdict(title: "No solution",
                               detail: "L\(sub(r)) now reads 0 = \(pretty(m[r][3])). No triple (x, y, z) can satisfy that, so the three planes never meet.",
                               icon: "xmark.octagon.fill",
                               color: .red)
            }
        }
        let rank: Int = (0..<3).filter { r in
            !(0..<3).allSatisfy { abs(m[r][$0]) < 1e-9 }
        }.count
        if rank < 3 {
            return Verdict(title: "Infinitely many solutions",
                           detail: "Rank \(rank) < 3: one line dissolved entirely, so an unknown stays free and the solutions form a \(3 - rank == 1 ? "line" : "plane").",
                           icon: "infinity.circle.fill",
                           color: GaussView.warmUI)
        }
        if isIdentity {
            return Verdict(title: "Solved",
                           detail: solutionText,
                           icon: "checkmark.circle.fill",
                           color: .green)
        }
        return Verdict(title: "Unique solution ahead",
                       detail: "Three pivots, no contradiction: keep reducing until the left block is the identity.",
                       icon: "arrow.triangle.turn.up.right.circle.fill",
                       color: .cyan)
    }

    private var isIdentity: Bool {
        for r in 0..<3 {
            for c in 0..<3 {
                let expected: Double = (r == c) ? 1 : 0
                if abs(m[r][c] - expected) > 1e-9 { return false }
            }
        }
        return true
    }

    private var solutionText: String {
        "x = \(pretty(m[0][3]))   ·   y = \(pretty(m[1][3]))   ·   z = \(pretty(m[2][3]))"
    }

    private var captionText: String {
        done ? verdict.detail : example.script[safeStep].caption
    }

    // MARK: - Stage

    private var stage: some View {
        VStack(alignment: .leading, spacing: 9) {
            stageLabel("SYSTEM")

            VStack(spacing: 0) {
                ForEach(0..<3, id: \.self) { r in systemRow(r) }
            }

            Rectangle()
                .frame(height: 0.5)
                .foregroundStyle(.white.opacity(0.12))
                .padding(.vertical, 3)

            stageLabel("AUGMENTED MATRIX")

            VStack(spacing: 0) {
                ForEach(0..<3, id: \.self) { r in matrixRow(r) }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [Color(red: 0.10, green: 0.11, blue: 0.16),
                                    Color(red: 0.04, green: 0.05, blue: 0.08)],
                           startPoint: .top, endPoint: .bottom)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func stageLabel(_ s: String) -> some View {
        Text(s)
            .font(.system(size: 9, weight: .bold))
            .tracking(0.8)
            .foregroundStyle(.white.opacity(0.4))
    }

    // MARK: Equation row

    private func systemRow(_ r: Int) -> some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(GaussView.rowColors[r])
                .frame(width: 3, height: 16)
                .clipShape(Capsule())
            equationText(r)
                .font(.system(size: 15, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Spacer(minLength: 6)
            if let op = pending, r == op.target || (op.source == r && isSwap(op)) {
                HStack(spacing: 5) {
                    Rectangle()
                        .frame(width: 1.5, height: 15)
                        .foregroundStyle(GaussView.warm.opacity(0.8))
                    Text(badge(for: op, row: r))
                        .font(.system(size: 12, weight: .heavy, design: .monospaced))
                        .foregroundStyle(GaussView.warm)
                }
            }
        }
        .padding(.horizontal, 8)
        .frame(height: GaussView.rowH + 2)
        .background(rowTint(r))
    }

    private func isSwap(_ op: RowOp) -> Bool {
        if case .swap = op { return true }
        return false
    }

    private func badge(for op: RowOp, row r: Int) -> String {
        if isSwap(op) && r != op.target { return "↔ L\(sub(op.target))" }
        return op.systemBadge
    }

    private func equationText(_ r: Int) -> Text {
        let names: [String] = ["x", "y", "z"]
        let colors: [Color] = [.red, .green, .blue]
        let dim: Color = Color.white.opacity(0.45)
        var out: Text = Text("")
        var started: Bool = false

        for c in 0..<3 {
            let v: Double = m[r][c]
            if abs(v) < 1e-9 { continue }
            let lead: String = started ? (v < 0 ? "   −   " : "   +   ") : (v < 0 ? "−" : "")
            let a: Double = abs(v)
            let coef: String = abs(a - 1) < 1e-9 ? "" : pretty(a)

            out = out + Text(lead).foregroundStyle(dim)
            out = out + Text(coef).foregroundStyle(Color.white)
            out = out + Text(names[c]).foregroundStyle(colors[c])
            started = true
        }
        if !started {
            out = out + Text("0").foregroundStyle(Color.white.opacity(0.5))
        }

        out = out + Text("   =   ").foregroundStyle(dim)
        out = out + Text(pretty(m[r][3])).foregroundStyle(GaussView.warm)
        return out
    }

    // MARK: Matrix row

    private func matrixRow(_ r: Int) -> some View {
        HStack(spacing: 3) {
            Text("L\(sub(r))")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(GaussView.rowColors[r].opacity(0.9))
                .frame(width: 18)

            BracketShape(leading: true)
                .stroke(Color.white.opacity(0.45), lineWidth: 1.2)
                .frame(width: 5, height: GaussView.rowH)

            ForEach(0..<3, id: \.self) { c in
                Text(pretty(m[r][c]))
                    .font(.system(size: 12.5, weight: .semibold, design: .monospaced))
                    .foregroundStyle(abs(m[r][c]) < 1e-9 ? Color.white.opacity(0.25) : Color.white)
                    .frame(width: GaussView.cellW, height: GaussView.rowH)
                    .contentTransition(.numericText())
            }

            Rectangle()
                .frame(width: 1, height: GaussView.rowH)
                .foregroundStyle(.white.opacity(0.3))

            Text(pretty(m[r][3]))
                .font(.system(size: 12.5, weight: .heavy, design: .monospaced))
                .foregroundStyle(GaussView.warm)
                .frame(width: GaussView.cellW, height: GaussView.rowH)
                .contentTransition(.numericText())

            BracketShape(leading: false)
                .stroke(Color.white.opacity(0.45), lineWidth: 1.2)
                .frame(width: 5, height: GaussView.rowH)

            if let op = pending, r == op.target {
                Text(op.matrixLabel)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(GaussView.warm)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .padding(.leading, 5)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 4)
        .frame(height: GaussView.rowH)
        .background(rowTint(r))
    }

    private func rowTint(_ r: Int) -> some View {
        let isTarget: Bool = (pending?.target == r)
        let isSource: Bool = (pending?.source == r)
        let c: Color = isTarget ? GaussView.warm : (isSource ? Color.cyan : Color.clear)
        let o: Double = isTarget ? 0.13 : (isSource ? 0.10 : 0)
        return RoundedRectangle(cornerRadius: 6).fill(c.opacity(o))
    }

    // MARK: - Step control

    /// Buttons rather than a stepped slider: no haptic ticking, and the two
    /// directions are separate targets instead of one thumb to aim at.
    private var stepControl: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    stepButton("chevron.left", enabled: safeStep > 0) {
                        move(to: safeStep - 1)
                    }
                    stepButton("chevron.right", enabled: safeStep < example.script.count) {
                        move(to: safeStep + 1)
                    }
                    Text("STEP \(safeStep) / \(example.script.count)")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .tracking(0.7)
                        .foregroundStyle(.secondary)
                    Spacer(minLength: 0)
                }

                progressTrack

                Text(captionText)
                    .font(.system(size: 10.5))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 0) {
                Text("EXAMPLE")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.7)
                    .foregroundStyle(.secondary)
                Picker("", selection: $exampleIndex) {
                    ForEach(GaussView.examples.indices, id: \.self) { i in
                        Text(GaussView.examples[i].name)
                            .font(.system(size: 13, weight: .medium))
                            .tag(i)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 82)
                .clipped()
                .onChange(of: exampleIndex) { _ in
                    step = 0
                }
            }
            .frame(width: 140)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 13).fill(Color(.secondarySystemGroupedBackground)))
    }

    private func stepButton(_ icon: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .frame(width: 34, height: 26)
                .background(RoundedRectangle(cornerRadius: 7)
                    .fill(enabled ? GaussView.warmUI.opacity(0.22) : Color.secondary.opacity(0.10)))
                .foregroundStyle(enabled ? GaussView.warm : Color.secondary.opacity(0.5))
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }

    private var progressTrack: some View {
        HStack(spacing: 3) {
            ForEach(0...example.script.count, id: \.self) { i in
                Capsule()
                    .fill(i <= safeStep ? GaussView.warmUI : Color.secondary.opacity(0.2))
                    .frame(height: 4)
                    .onTapGesture { move(to: i) }
            }
        }
    }

    private func move(to target: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            step = min(max(target, 0), example.script.count)
        }
    }

    // MARK: - Verdict + script

    private var verdictCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: verdict.icon).font(.system(size: 13))
                Text(verdict.title).font(.system(size: 12.5, weight: .bold))
            }
            .foregroundStyle(verdict.color)

            Divider()

            VStack(alignment: .leading, spacing: 3) {
                ForEach(example.script.indices, id: \.self) { i in
                    stepRow(i)
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 13).fill(Color(.secondarySystemGroupedBackground)))
    }

    /// Kept in its own function with explicit types: nested ternaries inlined in
    /// a ForEach are what blows up the type-checker.
    private func stepRow(_ i: Int) -> some View {
        let isCurrent: Bool = (i == safeStep)
        let isPast: Bool = (i < safeStep)
        let color: Color = isCurrent ? GaussView.warmUI
                                     : (isPast ? Color.secondary : Color.gray.opacity(0.5))
        let weight: Font.Weight = isCurrent ? .heavy : .semibold
        let number: String = "\(i + 1)."
        let label: String = example.script[i].op.matrixLabel

        return HStack(spacing: 6) {
            Text(number)
                .font(.system(size: 9.5, design: .monospaced))
                .foregroundStyle(Color.gray.opacity(0.6))
                .frame(width: 14, alignment: .trailing)
            Text(label)
                .font(.system(size: 10.5, weight: weight, design: .monospaced))
                .foregroundStyle(color)
        }
        .contentShape(Rectangle())
        .onTapGesture { move(to: i) }
    }
}
// MARK: - Formatting helpers

/// Small rationals read far better than 0.3333 during an elimination.
private func pretty(_ x: Double) -> String {
    if abs(x) < 1e-9 { return "0" }
    if abs(x - x.rounded()) < 1e-9 { return String(Int(x.rounded())) }
    for d in 2...16 {
        let n = x * Double(d)
        if abs(n - n.rounded()) < 1e-9 { return "\(Int(n.rounded()))/\(d)" }
    }
    return String(format: "%.2f", x)
}

private func coefficient(_ f: Double) -> String {
    abs(f - 1) < 1e-9 ? "" : "\(pretty(f))·"
}

private func signedTerm(_ f: Double, _ label: String) -> String {
    let sign: String = f < 0 ? "−" : "+"
    let a: Double = abs(f)
    let coef: String = abs(a - 1) < 1e-9 ? "" : "\(pretty(a))·"
    return "\(sign) \(coef)\(label)"
}

private func sub(_ i: Int) -> String { ["₁", "₂", "₃"][i] }

/// Kills the −0 and the 1e-17 that elimination leaves behind.
private func clean(_ x: Double) -> Double {
    abs(x) < 1e-10 ? 0 : (x * 1e9).rounded() / 1e9
}

#Preview {
    GaussView()
        .preferredColorScheme(.dark)
}
