//
//  VectorSpaceView.swift
//  LearnViz
//
//  Linear independence in R² / R³.
//  Reuses V3 / M3 / Projector / ScrubCell / BracketShape from Matrix3DView.swift
//  and the shared preset catalogue from SharedMatrixComponents.swift.
//

import SwiftUI

struct VectorSpaceView: View {

    @State private var v1 = V3(2, 1, 0)
    @State private var v2 = V3(1, 2, 0)
    @State private var v3 = V3(0.5, 0.5, 2)

    @State private var is3D: Bool
    @State private var presetIndex = 0

    // Camera (3D only)
    @State private var azimuth: Double = -0.9
    @State private var elevation: Double = 0.42
    @State private var distance: Double = 8.5
    @State private var orbitAnchor: (Double, Double)? = nil

    // Direct-drag editing (2D only): which vector's tip is currently grabbed.
    @State private var draggingVector: Int? = nil
    @State private var canvasSize: CGSize = CGSize(width: 300, height: 360)

    init(is3D: Bool = true) {
        _is3D = State(initialValue: is3D)
        // The planar view is the determinant view: it opens on the identity,
        // the one pair whose det every other example is read against. v3 keeps
        // its default so switching to ℝ³ still lands on an independent trio.
        if !is3D {
            _v1 = State(initialValue: V3(1, 0, 0))
            _v2 = State(initialValue: V3(0, 1, 0))
            _presetIndex = State(initialValue: 1)   // "Identity" in planarPresets
        }
    }

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

    /// The planar views need their own catalogue: several 3D presets differ
    /// only in their third column, which does not exist in ℝ².
    private var presets: [MatrixPreset] {
        is3D ? MatrixPreset.sharedPresets : MatrixPreset.planarPresets
    }

    /// The length of v⃗₁, kept as a binding so a slider can scale that column
    /// without changing its direction. Dragging a tip can only ever set a
    /// length by eye, which left "what does tripling a column do to det?"
    /// impossible to check.
    private var v1Length: Binding<Double> {
        Binding(
            get: { (v1.x * v1.x + v1.y * v1.y).squareRoot() },
            set: { new in
                let current = (v1.x * v1.x + v1.y * v1.y).squareRoot()
                guard current > 0.0001 else { v1 = V3(new, 0, 0); return }
                let k = new / current
                v1 = V3(v1.x * k, v1.y * k, 0)
                presetIndex = 0
            }
        )
    }

    private var camAzimuth: Double { is3D ? azimuth : -.pi / 2 }
    private var camElevation: Double { is3D ? elevation : .pi / 2 - 0.0006 }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                viewport
                if !is3D {
                    VizSlider(label: "length of v₁", value: v1Length, range: 0.5...4,
                              accent: .cyan, format: "%.2f",
                              caption: "Drag either dot on the graph to turn a vector; use this to scale v⃗₁ exactly.")
                }
                controlDeck
                analysisCard
            }
            .padding(14)
        }
        .background(Color(.systemGroupedBackground))
        .onChange(of: is3D) {
            // The two catalogues are different lists, so an index carried over
            // would point at an unrelated example.
            presetIndex = 0
            if !is3D {
                v1.z = 0
                v2.z = 0
                v3.z = 0
            }
        }
    }

    // MARK: - Viewport

    private var viewport: some View {
        ZStack(alignment: .topLeading) {
            Canvas { ctx, size in
                render(ctx, size: size)
            }
            .frame(height: 300)   // matches the other algebra viewports, and keeps the readouts on screen
            .background(
                LinearGradient(colors: [Color(.secondarySystemBackground),
                                        Color(.tertiarySystemBackground)],
                               startPoint: .top, endPoint: .bottom)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .contentShape(RoundedRectangle(cornerRadius: 16))
            .onGeometryChange(for: CGSize.self) { $0.size } action: { canvasSize = $0 }
            .highPriorityGesture(orbitGesture, isEnabled: is3D)
            .highPriorityGesture(vectorDragGesture, isEnabled: !is3D)
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

    /// Lets you grab v1 or v2 by its tip and drag it straight on the graph,
    /// so rotating/rescaling a vector and watching the span react is a
    /// direct manipulation instead of a numeric edit.
    private var vectorDragGesture: some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { g in
                let p = Projector(azimuth: camAzimuth, elevation: camElevation,
                                   distance: distance, size: canvasSize)

                if draggingVector == nil {
                    let candidates = [(0, w1), (1, w2)]
                    let hit = candidates
                        .compactMap { idx, v -> (Int, CGFloat)? in
                            guard let tip = p.project(v) else { return nil }
                            let d = hypot(tip.x - g.startLocation.x, tip.y - g.startLocation.y)
                            return (idx, d)
                        }
                        .filter { $0.1 < 34 }
                        .min { $0.1 < $1.1 }
                    draggingVector = hit?.0
                }
                guard let idx = draggingVector,
                      let math = p.unprojectToZPlane(g.location) else { return }

                let snapped = snapDirection(math, against: idx == 0 ? w2 : w1)
                let clamped = V3(min(max(snapped.x, -4), 4), min(max(snapped.y, -4), 4), 0)
                if idx == 0 { v1 = clamped } else { v2 = clamped }
                presetIndex = 0
            }
            .onEnded { _ in draggingVector = nil }
    }

    /// Aimantation. det = 0 is the state this view exists to show, and it needs
    /// the two arrows to be exactly collinear - which no fingertip ever manages
    /// on its own. So while a tip is dragged, its direction snaps onto the other
    /// vector's line (pointing the same way or the opposite way) and onto the
    /// axes. Only the direction is snapped; the length stays wherever the finger
    /// put it, since none of the questions turn on it.
    private func snapDirection(_ p: V3, against other: V3) -> V3 {
        let r = (p.x * p.x + p.y * p.y).squareRoot()
        guard r > 0.15 else { return p }
        let angle = atan2(p.y, p.x)

        // The other vector's line first, so it wins whenever it nearly
        // coincides with an axis: collinearity is what we are aiming for.
        var targets: [Double] = []
        if (other.x * other.x + other.y * other.y).squareRoot() > 0.15 {
            let a = atan2(other.y, other.x)
            targets += [a, a + .pi]
        }
        targets += [0, .pi / 2, .pi, -.pi / 2]

        // ~7°, matching the tolerance the trig view uses for the same job.
        let tolerance = 0.12
        for t in targets {
            let d = atan2(sin(angle - t), cos(angle - t))
            if abs(d) < tolerance { return V3(r * cos(t), r * sin(t), 0) }
        }
        return p
    }

    private var hud: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("det = \(fmt(det, 3))")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundStyle(independent ? .cyan : VectorSpaceView.warm)
            Text(verdictShort)
                .font(.system(size: 9.5))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }

    private var verdictShort: String {
        if independent {
            return is3D ? "Independent: volume \(fmt(abs(det), 2))"
                        : "Independent: area \(fmt(abs(det), 2))"
        }
        return is3D ? "Dependent: the trio is coplanar"
                    : "Dependent: the pair is collinear"
    }

    private var zoomSlider: some View {
        HStack(spacing: 5) {
            Image(systemName: "minus.magnifyingglass").font(.system(size: 9))
            Slider(value: $distance, in: 4.5...16).frame(width: 88)
            Image(systemName: "plus.magnifyingglass").font(.system(size: 9))
        }
        .foregroundStyle(.secondary)
        .tint(.cyan)
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(.thinMaterial, in: Capsule())
    }

    // MARK: - Control deck

    private var controlDeck: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                sectionLabel("SPACE")
                Picker("Space", selection: $is3D) {
                    Text("ℝ²").tag(false)
                    Text("ℝ³").tag(true)
                }
                .pickerStyle(.menu)
                .labelsHidden()
                Text(is3D ? "three vectors, three coordinates"
                          : "two vectors, two coordinates")
                    .font(.system(size: 9.5))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 0) {
                // A matrix is stored by columns, so its columns are the
                // vectors: nothing to convert.
                MatrixPresetPicker(presetIndex: $presetIndex,
                                   presets: presets,
                                   height: 76)
                    .onChange(of: presetIndex) { applyPreset() }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
    }

    private func sectionLabel(_ s: String) -> some View {
        Text(s)
            .font(.system(size: 9, weight: .bold))
            .tracking(0.7)
            .foregroundStyle(.secondary)
    }

    private func applyPreset() {
        guard presets.indices.contains(presetIndex),
              let m = presets[presetIndex].matrix else { return }
        if is3D {
            v1 = m.c1
            v2 = m.c2
            v3 = m.c3
        } else {
            v1 = V3(m.c1.x, m.c1.y, 0)
            v2 = V3(m.c2.x, m.c2.y, 0)
            v3 = .zero
        }
    }

    // MARK: - Analysis card

    private var analysisCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                vectorEditor
                verdictPanel
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
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
            ? "The span is only the highlighted plane: one direction of ℝ³ is out of reach."
            : "The span is only the highlighted line: the rest of the plane is out of reach."
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

    // MARK: - Rendering

    private func render(_ ctx: GraphicsContext, size: CGSize) {
        let p = Projector(azimuth: camAzimuth, elevation: camElevation, distance: distance, size: size)

        drawFloor(ctx, p)
        drawAxes(ctx, p)
        if !independent { drawSpan(ctx, p) }
        if is3D { drawShadow(ctx, p) }
        drawSolid(ctx, p)
        drawVectors(ctx, p)
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
            ctx.fill(path, with: .color(.primary.opacity(0.035)))
        }

        var grid = Path()
        var i = -r
        while i <= r + 1e-6 {
            if let s = p.segment(V3(i, -r, 0), V3(i, r, 0)) { grid.move(to: s.0); grid.addLine(to: s.1) }
            if let s = p.segment(V3(-r, i, 0), V3(r, i, 0)) { grid.move(to: s.0); grid.addLine(to: s.1) }
            i += 0.5
        }
        ctx.stroke(grid, with: .color(.primary.opacity(0.09)), lineWidth: 0.7)
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

        ctx.drawLayer { layer in
            layer.addFilter(.blur(radius: 6))
            layer.fill(path, with: .color(.black.opacity(0.26)))
        }
    }

    /// Parallelogram in ℝ², parallelepiped in ℝ³ - same code, w3 is simply zero
    /// in 2D. Skipped when the family is dependent: the solid collapses and its
    /// faces produce nothing but slivers, while drawSpan already shows the truth.
    private func drawSolid(_ ctx: GraphicsContext, _ p: Projector) {
        guard independent else { return }

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

            // Plumb line only where it means something: a genuinely 3D setup,
            // with the vector clearly off the floor. In 2D the z components are
            // always zero, so this never fires.
            if is3D && independent && abs(v.z) > 0.1 && v.norm > 0.2 && abs(v.z) / v.norm > 0.15 {
                let ground = V3(v.x, v.y, 0)
                if let s = p.segment(v, ground) {
                    var path = Path()
                    path.move(to: s.0); path.addLine(to: s.1)
                    ctx.stroke(path, with: .color(color.opacity(0.3)),
                               style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                }
            }

            if let tip = p.project(v) {
                ctx.draw(Text(label).font(.system(size: 14, weight: .heavy)).foregroundStyle(color),
                         at: CGPoint(x: tip.x + 16, y: tip.y - 12))

                // A visible, grabbable handle - only in 2D, where the tip can
                // actually be dragged straight on the graph.
                if !is3D {
                    let r: CGFloat = 7
                    let dot = Path(ellipseIn: CGRect(x: tip.x - r, y: tip.y - r, width: r * 2, height: r * 2))
                    ctx.fill(dot, with: .color(color))
                    ctx.stroke(dot, with: .color(.white.opacity(0.85)), lineWidth: 1.5)
                }
            }
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
        .preferredColorScheme(.dark)
}
