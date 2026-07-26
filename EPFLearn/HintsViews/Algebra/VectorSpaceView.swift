//
//  VectorSpaceView.swift
//  EPFLearn
//
//  Linear independence in R² / R³.
//  Reuses V3 / M3 / Projector / ScrubCell / BracketShape from Matrix3DView.swift.
//

import SwiftUI

struct VectorPreset {
    let name: String
    let vectors: (V3, V3, V3)?     // nil = "Custom"
}

struct VectorSpaceView: View {

    @State private var v1 = V3(2, 1, 0)
    @State private var v2 = V3(1, 2, 0)
    @State private var v3 = V3(0.5, 0.5, 2)

    /// Coefficients of the dependency equation λ₁v₁ + λ₂v₂ + λ₃v₃ = 0
    @State private var lambda = V3(0, 0, 0)

    @State private var is3D = true
    @State private var presetIndex = 0

    // Camera (3D only)
    @State private var azimuth: Double = -0.9
    @State private var elevation: Double = 0.42
    @State private var distance: Double = 8.5
    @State private var orbitAnchor: (Double, Double)? = nil

    static let warm = Color(red: 1.00, green: 0.80, blue: 0.26)
    static let warmUI = Color(red: 0.72, green: 0.50, blue: 0.00)

    // MARK: Derived state

    /// Vectors as used everywhere: in 2D the third coordinate simply does not exist.
    private var w1: V3 { is3D ? v1 : V3(v1.x, v1.y, 0) }
    private var w2: V3 { is3D ? v2 : V3(v2.x, v2.y, 0) }
    private var w3: V3 { is3D ? v3 : .zero }

    private var det: Double {
        is3D ? M3(c1: w1, c2: w2, c3: w3).det : w1.x * w2.y - w1.y * w2.x
    }
    private var independent: Bool { abs(det) > 0.02 }

    /// Σ λᵢvᵢ — the left-hand side of the equation, zero exactly when the chain closes.
    private var residual: V3 { lambda.x * w1 + lambda.y * w2 + lambda.z * w3 }
    private var lambdaIsTrivial: Bool { lambda.norm < 0.01 }
    private var closed: Bool { residual.norm < 0.02 && !lambdaIsTrivial }

    private var camAzimuth: Double { is3D ? azimuth : -.pi / 2 }
    private var camElevation: Double { is3D ? elevation : .pi / 2 - 0.0006 }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                viewport
                controlDeck
                analysisCard
            }
            .padding(14)
        }
        .background(Color(.systemGroupedBackground))
        .onChange(of: det) { autoSolve() }
        .onChange(of: is3D) { if !is3D { lambda.z = 0 }; autoSolve() }
    }

    // MARK: - Viewport

    private var viewport: some View {
        ZStack(alignment: .topLeading) {
            Canvas { ctx, size in
                render(ctx, size: size)
            }
            .frame(height: 360)
            .background(
                LinearGradient(colors: [Color(red: 0.10, green: 0.11, blue: 0.16),
                                        Color(red: 0.04, green: 0.05, blue: 0.08)],
                               startPoint: .top, endPoint: .bottom)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .contentShape(RoundedRectangle(cornerRadius: 16))
            .highPriorityGesture(orbitGesture, isEnabled: is3D)
            .onTapGesture(count: 2) {
                azimuth = -0.9; elevation = 0.42; distance = 8.5
            }

            hud.padding(10)
        }
        .overlay(alignment: .bottomTrailing) { zoomSlider.padding(9) }
    }

    private var orbitGesture: some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { g in
                if orbitAnchor == nil { orbitAnchor = (azimuth, elevation) }
                guard let a = orbitAnchor else { return }
                azimuth = a.0 - Double(g.translation.width) * 0.008
                elevation = min(max(a.1 + Double(g.translation.height) * 0.006, -1.45), 1.45)
            }
            .onEnded { _ in orbitAnchor = nil }
    }

    private var hud: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("det = \(fmt(det, 3))")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundStyle(independent ? .cyan : VectorSpaceView.warm)
            Text(verdictShort)
                .font(.system(size: 9.5))
                .foregroundStyle(.white.opacity(0.55))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 8))
    }

    private var verdictShort: String {
        if independent {
            return is3D ? "Independent — volume \(fmt(abs(det), 2))"
                        : "Independent — area \(fmt(abs(det), 2))"
        }
        return is3D ? "Dependent — the trio is coplanar"
                    : "Dependent — the pair is collinear"
    }

    private var zoomSlider: some View {
        HStack(spacing: 5) {
            Image(systemName: "minus.magnifyingglass").font(.system(size: 9))
            Slider(value: $distance, in: 4.5...16).frame(width: 88)
            Image(systemName: "plus.magnifyingglass").font(.system(size: 9))
        }
        .foregroundStyle(.white.opacity(0.7))
        .tint(.cyan)
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(.black.opacity(0.3), in: Capsule())
    }

    // MARK: - Control deck

    private var controlDeck: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                sectionLabel("SPACE")
                Picker("", selection: $is3D) {
                    Text("ℝ²").tag(false)
                    Text("ℝ³").tag(true)
                }
                .pickerStyle(.segmented)
                Text(is3D ? "three vectors, three coordinates"
                          : "two vectors, two coordinates")
                    .font(.system(size: 9.5))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 0) {
                sectionLabel("EXAMPLES")
                Picker("", selection: $presetIndex) {
                    ForEach(VectorSpaceView.presets.indices, id: \.self) { i in
                        Text(VectorSpaceView.presets[i].name)
                            .font(.system(size: 13, weight: .medium))
                            .tag(i)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 76)
                .clipped()
                .onChange(of: presetIndex) { applyPreset() }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 13).fill(Color(.secondarySystemGroupedBackground)))
    }

    private func sectionLabel(_ s: String) -> some View {
        Text(s)
            .font(.system(size: 9, weight: .bold))
            .tracking(0.7)
            .foregroundStyle(.secondary)
    }

    private func applyPreset() {
        guard let vs = VectorSpaceView.presets[presetIndex].vectors else { return }
        v1 = vs.0; v2 = vs.1; v3 = vs.2
    }

    // MARK: - Analysis card

    private var analysisCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                vectorEditor
                verdictPanel
            }
            Divider()
            
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 13).fill(Color(.secondarySystemGroupedBackground)))
    }

    private var columnCount: Int { is3D ? 3 : 2 }
    private var rowCount: Int { is3D ? 3 : 2 }

    private var vectorEditor: some View {
        VStack(spacing: 2) {
            HStack(spacing: 3) {
                Color.clear.frame(width: 11, height: 1)
                ForEach(0..<columnCount, id: \.self) { c in
                    Text(["v₁", "v₂", "v₃"][c])
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(VectorSpaceView.tint(c))
                        .frame(width: Matrix3DView.cellW)
                }
            }
            HStack(spacing: 3) {
                VStack(spacing: 3) {
                    ForEach(0..<rowCount, id: \.self) { r in
                        Text(["x", "y", "z"][r])
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .frame(width: 11, height: Matrix3DView.cellH)
                    }
                }
                BracketShape(leading: true)
                    .stroke(Color.secondary.opacity(0.5), lineWidth: 1.2)
                    .frame(width: 5)
                VStack(spacing: 3) {
                    ForEach(0..<rowCount, id: \.self) { r in
                        HStack(spacing: 3) {
                            ForEach(0..<columnCount, id: \.self) { c in
                                ScrubCell(value: binding(r, c), tint: VectorSpaceView.tint(c))
                            }
                        }
                    }
                }
                BracketShape(leading: false)
                    .stroke(Color.secondary.opacity(0.5), lineWidth: 1.2)
                    .frame(width: 5)
            }
            Text("drag ↔ · double-tap to zero")
                .font(.system(size: 8.5))
                .foregroundStyle(.tertiary)
                .padding(.top, 2)
        }
    }

    private var verdictPanel: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 5) {
                Image(systemName: independent ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 12))
                Text(independent ? "Independent" : "Dependent")
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundStyle(independent ? Color.green : VectorSpaceView.warmUI)

            Text(spanText)
                .font(.system(size: 9.5))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var spanText: String {
        if independent {
            return is3D
                ? "The trio is a basis of ℝ³: the parallelepiped has non-zero volume."
                : "The pair is a basis of ℝ²: the parallelogram has non-zero area."
        }
        return is3D
            ? "The span is only the highlighted plane — one direction of ℝ³ is out of reach."
            : "The span is only the highlighted line — the rest of the plane is out of reach."
    }

    // MARK: The equation  λ₁v₁ + λ₂v₂ + λ₃v₃ = 0

    private var equationRow: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 0) {
                sectionLabel("DEPENDENCY EQUATION")
                Spacer()
            }
            HStack(spacing: 3) {
                ForEach(0..<columnCount, id: \.self) { c in
                    if c > 0 {
                        Text("+").font(.system(size: 13, weight: .light)).foregroundStyle(.secondary)
                    }
                    ScrubCell(value: lambdaBinding(c), tint: VectorSpaceView.tint(c))
                    Text("·\(["v₁", "v₂", "v₃"][c])")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(VectorSpaceView.tint(c))
                }
                Text("=").font(.system(size: 14, weight: .light)).foregroundStyle(.secondary)
                    .padding(.leading, 2)
                Text("0")
                    .font(.system(size: 15, weight: .heavy, design: .monospaced))
                    .foregroundStyle(closed ? Color.green : .secondary)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.65)
        }
    }

 
    // MARK: Bindings

    static func tint(_ c: Int) -> Color { [.red, .green, .blue][c] }

    private func binding(_ row: Int, _ col: Int) -> Binding<Double> {
        Binding(
            get: {
                let v = col == 0 ? v1 : (col == 1 ? v2 : v3)
                return row == 0 ? v.x : (row == 1 ? v.y : v.z)
            },
            set: { nv in
                var v = col == 0 ? v1 : (col == 1 ? v2 : v3)
                if row == 0 { v.x = nv } else if row == 1 { v.y = nv } else { v.z = nv }
                if col == 0 { v1 = v } else if col == 1 { v2 = v } else { v3 = v }
                presetIndex = 0
            }
        )
    }

    private func lambdaBinding(_ c: Int) -> Binding<Double> {
        Binding(
            get: { c == 0 ? lambda.x : (c == 1 ? lambda.y : lambda.z) },
            set: { nv in
                if c == 0 { lambda.x = nv } else if c == 1 { lambda.y = nv } else { lambda.z = nv }
            }
        )
    }

    /// Fills λ with an actual non-trivial solution whenever one exists.
    private func autoSolve() {
        guard !independent else { return }
        guard let l = nullVector() else { return }
        lambda = l
    }

    /// Null vector of the matrix whose columns are the vectors: the rows must all be orthogonal to λ.
    private func nullVector() -> V3? {
        let rows: [V3] = is3D
            ? [V3(w1.x, w2.x, w3.x), V3(w1.y, w2.y, w3.y), V3(w1.z, w2.z, w3.z)]
            : [V3(w1.x, w2.x, 0), V3(w1.y, w2.y, 0)]

        var best = V3.zero
        if is3D {
            for i in 0..<rows.count {
                for j in (i + 1)..<rows.count {
                    let c = rows[i].cross(rows[j])
                    if c.norm > best.norm { best = c }
                }
            }
        } else {
            // In R²: λ orthogonal to the dominant row (a, b) is (-b, a).
            let r = rows[0].norm >= rows[1].norm ? rows[0] : rows[1]
            best = V3(-r.y, r.x, 0)
        }
        guard best.norm > 1e-6 else { return nil }

        // Normalise so the largest coefficient is ±1, then snap to the 0.25 grid of the cells.
        let m = max(abs(best.x), max(abs(best.y), abs(best.z)))
        let s = 1.0 / m
        let snap: (Double) -> Double = { min(max(($0 * s * 4).rounded() / 4, -3), 3) }
        return V3(snap(best.x), snap(best.y), is3D ? snap(best.z) : 0)
    }

    // MARK: - Presets

    static let presets: [VectorPreset] = [
        VectorPreset(name: "Custom", vectors: nil),
        VectorPreset(name: "Canonical basis", vectors: (V3(1, 0, 0), V3(0, 1, 0), V3(0, 0, 1))),
        VectorPreset(name: "Independent", vectors: (V3(2, 1, 0), V3(1, 2, 0), V3(0.5, 0.5, 2))),
        VectorPreset(name: "Collinear pair", vectors: (V3(1.5, 1, 0), V3(-3, -2, 0), V3(0, 0, 2))),
        VectorPreset(name: "Coplanar trio", vectors: (V3(2, 0, 1), V3(0, 2, 1), V3(2, 2, 2))),
        VectorPreset(name: "Almost dependent", vectors: (V3(2, 1, 0), V3(2, 1.25, 0), V3(0, 0, 2))),
        VectorPreset(name: "Flat trio", vectors: (V3(2, 1, 0), V3(-1, 2, 0), V3(1, 3, 0))),
        VectorPreset(name: "Skewed frame", vectors: (V3(2, 0.5, 0.5), V3(0.5, 2, 0.5), V3(0.5, 0.5, 2)))
    ]

    // MARK: - Rendering

    private func render(_ ctx: GraphicsContext, size: CGSize) {
        let p = Projector(azimuth: camAzimuth, elevation: camElevation, distance: distance, size: size)

        drawFloor(ctx, p)
        drawAxes(ctx, p)
        if !independent { drawSpan(ctx, p) }
        if is3D { drawShadow(ctx, p) }
        drawSolid(ctx, p)
        drawVectors(ctx, p)
        drawChain(ctx, p)
    }

    private func drawFloor(_ ctx: GraphicsContext, _ p: Projector) {
        let r = 3.0
        var pts: [CGPoint] = []
        for c in [V3(-r, -r, 0), V3(r, -r, 0), V3(r, r, 0), V3(-r, r, 0)] {
            guard let s = p.project(c) else { pts = []; break }
            pts.append(s)
        }
        if pts.count == 4 {
            var path = Path()
            path.move(to: pts[0])
            for q in pts.dropFirst() { path.addLine(to: q) }
            path.closeSubpath()
            ctx.fill(path, with: .color(.white.opacity(0.035)))
        }

        var grid = Path()
        var i = -r
        while i <= r + 1e-6 {
            if let s = p.segment(V3(i, -r, 0), V3(i, r, 0)) { grid.move(to: s.0); grid.addLine(to: s.1) }
            if let s = p.segment(V3(-r, i, 0), V3(r, i, 0)) { grid.move(to: s.0); grid.addLine(to: s.1) }
            i += 0.5
        }
        ctx.stroke(grid, with: .color(.white.opacity(0.09)), lineWidth: 0.7)
    }

    private func drawAxes(_ ctx: GraphicsContext, _ p: Projector) {
        var axes: [(V3, Color, String)] = [
            (V3(3.2, 0, 0), .red, "x"),
            (V3(0, 3.2, 0), .green, "y")
        ]
        if is3D { axes.append((V3(0, 0, 3.0), .blue, "z")) }

        for (end, color, label) in axes {
            if let s = p.segment(V3.zero, end) {
                var path = Path()
                path.move(to: s.0); path.addLine(to: s.1)
                ctx.stroke(path, with: .color(color.opacity(0.35)), lineWidth: 1.2)
            }
            if let tip = p.project(end) {
                ctx.draw(Text(label).font(.system(size: 12, weight: .bold))
                            .foregroundStyle(color.opacity(0.8)),
                         at: CGPoint(x: tip.x + 10, y: tip.y - 8))
            }
        }
    }

    /// What the family actually reaches: a line, or a plane.
    private func drawSpan(_ ctx: GraphicsContext, _ p: Projector) {
        let planar = is3D && w1.cross(w2).norm > 1e-4
        if planar {
            let k = 1.8
            let corners = [(-k) * w1 + (-k) * w2, k * w1 + (-k) * w2, k * w1 + k * w2, (-k) * w1 + k * w2]
            var pts: [CGPoint] = []
            for c in corners {
                guard let s = p.project(c) else { return }
                pts.append(s)
            }
            var path = Path()
            path.move(to: pts[0])
            for q in pts.dropFirst() { path.addLine(to: q) }
            path.closeSubpath()
            ctx.fill(path, with: .color(VectorSpaceView.warm.opacity(0.13)))
            ctx.stroke(path, with: .color(VectorSpaceView.warm.opacity(0.4)), lineWidth: 1)
        } else {
            let a = w1.norm > 1e-6 ? w1 : w2
            guard a.norm > 1e-6 else { return }
            let k = 3.2 / a.norm
            if let s = p.segment((-k) * a, k * a) {
                var path = Path()
                path.move(to: s.0); path.addLine(to: s.1)
                ctx.stroke(path, with: .color(VectorSpaceView.warm.opacity(0.55)),
                           style: StrokeStyle(lineWidth: 2, dash: [7, 5]))
            }
        }
    }

    private func drawShadow(_ ctx: GraphicsContext, _ p: Projector) {
        let A = M3(c1: w1, c2: w2, c3: w3)
        var pts: [CGPoint] = []
        for c in Matrix3DView.cubeCorners {
            let w = A.apply(c)
            if let s = p.project(V3(w.x, w.y, 0)) { pts.append(s) }
        }
        guard pts.count >= 3 else { return }
        let hull = Matrix3DView.convexHull(pts)
        guard hull.count >= 3 else { return }
        var path = Path()
        path.move(to: hull[0])
        for q in hull.dropFirst() { path.addLine(to: q) }
        path.closeSubpath()
        ctx.fill(path, with: .color(.black.opacity(0.4)))
    }

    /// Parallelogram in ℝ², parallelepiped in ℝ³ — same code, w3 is simply zero in 2D.
    private func drawSolid(_ ctx: GraphicsContext, _ p: Projector) {
        let A = M3(c1: w1, c2: w2, c3: w3)
        let light = V3(0.45, -0.6, 0.85).unit
        var faces: [(depth: Double, path: Path, shade: Double)] = []

        for face in Matrix3DView.cubeFaces {
            let world = face.map { A.apply($0) }
            var screen: [CGPoint] = []
            var ok = true
            for w in world {
                guard let s = p.project(w) else { ok = false; break }
                screen.append(s)
            }
            guard ok, screen.count == 4 else { continue }

            let n = (world[1] - world[0]).cross(world[2] - world[0])
            let intensity = n.norm < 1e-7 ? 0.62 : 0.32 + 0.68 * abs(n.unit.dot(light))

            var path = Path()
            path.move(to: screen[0])
            for q in screen.dropFirst() { path.addLine(to: q) }
            path.closeSubpath()

            let centroid = 0.25 * (world[0] + world[1] + world[2] + world[3])
            faces.append((p.depth(centroid), path, intensity))
        }

        for f in faces.sorted(by: { $0.depth > $1.depth }) {
            let c = Color(red: 0.20 * f.shade, green: 0.78 * f.shade, blue: 0.92 * f.shade, opacity: 0.58)
            ctx.fill(f.path, with: .color(c))
            ctx.stroke(f.path, with: .color(.cyan.opacity(0.7)), lineWidth: 1.1)
        }
    }

    private func drawVectors(_ ctx: GraphicsContext, _ p: Projector) {
        var items: [(V3, Color, String)] = [(w1, .red, "v₁"), (w2, .green, "v₂")]
        if is3D { items.append((w3, .blue, "v₃")) }

        for (v, color, label) in items {
            arrow(ctx, p, from: .zero, to: v, color: color, width: 5)
            if is3D && abs(v.z) > 0.01 {
                let ground = V3(v.x, v.y, 0)
                if let s = p.segment(v, ground) {
                    var path = Path()
                    path.move(to: s.0); path.addLine(to: s.1)
                    ctx.stroke(path, with: .color(color.opacity(0.3)),
                               style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                }
                if let g = p.project(ground) {
                    ctx.fill(Path(ellipseIn: CGRect(x: g.x - 4, y: g.y - 2, width: 8, height: 4)),
                             with: .color(color.opacity(0.35)))
                }
            }
            if let tip = p.project(v) {
                ctx.draw(Text(label).font(.system(size: 14, weight: .heavy)).foregroundStyle(color),
                         at: CGPoint(x: tip.x + 16, y: tip.y - 12))
            }
        }
    }

    private func drawChain(_ ctx: GraphicsContext, _ p: Projector) {
            guard !lambdaIsTrivial else { return }

            let steps: [(V3, Color)] = is3D
                ? [(lambda.x * w1, .red), (lambda.y * w2, .green), (lambda.z * w3, .blue)]
                : [(lambda.x * w1, .red), (lambda.y * w2, .green)]

            var cursor = V3.zero
            for (step, color) in steps {
                let next = cursor + step
                if step.norm > 1e-6, let s = p.segment(cursor, next) {
                    var path = Path()
                    path.move(to: s.0); path.addLine(to: s.1)
                    ctx.stroke(path, with: .color(color.opacity(0.9)),
                               style: StrokeStyle(lineWidth: 2.5, lineCap: .round, dash: [6, 4]))
                }
                cursor = next
            }

            if closed {
                if let o = p.project(.zero) {
                    ctx.stroke(Path(ellipseIn: CGRect(x: o.x - 9, y: o.y - 9, width: 18, height: 18)),
                               with: .color(.green), lineWidth: 2.5)
                    ctx.draw(Text("= 0").font(.system(size: 12, weight: .heavy)).foregroundStyle(.green),
                             at: CGPoint(x: o.x + 26, y: o.y + 14))
                }
            } else {
                // Flèche jaune et texte supprimés pour épurer le dessin.
            }
        }

    private func arrow(_ ctx: GraphicsContext, _ p: Projector,
                       from a: V3, to b: V3, color: Color, width: CGFloat) {
        guard let s = p.segment(a, b) else { return }
        var line = Path()
        line.move(to: s.0); line.addLine(to: s.1)
        ctx.stroke(line, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round))

        let dx = s.1.x - s.0.x, dy = s.1.y - s.0.y
        guard (dx * dx + dy * dy).squareRoot() > 8 else { return }
        let ang = atan2(dy, dx)
        let L: CGFloat = width * 3.2
        let spread: CGFloat = .pi / 7
        var head = Path()
        head.move(to: s.1)
        head.addLine(to: CGPoint(x: s.1.x - L * cos(ang - spread), y: s.1.y - L * sin(ang - spread)))
        head.addLine(to: CGPoint(x: s.1.x - L * cos(ang + spread), y: s.1.y - L * sin(ang + spread)))
        head.closeSubpath()
        ctx.fill(head, with: .color(color))
    }
}

private func fmt(_ v: Double, _ digits: Int) -> String {
    String(format: "%.\(digits)f", v)
}

#Preview {
    VectorSpaceView()
}
