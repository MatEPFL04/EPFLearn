//
//  Matrix3DView.swift
//  EPFLearn
//
//  3D visualizer for a linear map from R³ to R³.
//  Real perspective projection + orbit camera + cast shadow.
//

import SwiftUI

// MARK: - Small 3D algebra

struct V3 {
    var x: Double, y: Double, z: Double

    init(_ x: Double, _ y: Double, _ z: Double) { self.x = x; self.y = y; self.z = z }

    static let zero = V3(0, 0, 0)

    static func + (a: V3, b: V3) -> V3 { V3(a.x + b.x, a.y + b.y, a.z + b.z) }
    static func - (a: V3, b: V3) -> V3 { V3(a.x - b.x, a.y - b.y, a.z - b.z) }
    static func * (s: Double, v: V3) -> V3 { V3(s * v.x, s * v.y, s * v.z) }
    static func * (v: V3, s: Double) -> V3 { s * v }

    func dot(_ b: V3) -> Double { x * b.x + y * b.y + z * b.z }
    func cross(_ b: V3) -> V3 {
        V3(y * b.z - z * b.y, z * b.x - x * b.z, x * b.y - y * b.x)
    }

    var norm: Double { (dot(self)).squareRoot() }
    var unit: V3 { let n = norm; return n < 1e-9 ? .zero : V3(x / n, y / n, z / n) }

    static func lerp(_ a: V3, _ b: V3, _ t: Double) -> V3 { a + t * (b - a) }
}

/// 3×3 matrix stored by columns: each column is the image of a canonical basis vector.
struct M3 {
    var c1: V3   // image of i
    var c2: V3   // image of j
    var c3: V3   // image of k

    static let identity = M3(c1: V3(1, 0, 0), c2: V3(0, 1, 0), c3: V3(0, 0, 1))

    func apply(_ v: V3) -> V3 { v.x * c1 + v.y * c2 + v.z * c3 }

    /// Determinant = triple product of the columns = signed volume of the image of the unit cube.
    var det: Double { c1.dot(c2.cross(c3)) }

    static func lerp(_ a: M3, _ b: M3, _ t: Double) -> M3 {
        M3(c1: V3.lerp(a.c1, b.c1, t),
           c2: V3.lerp(a.c2, b.c2, t),
           c3: V3.lerp(a.c3, b.c3, t))
    }

    subscript(row: Int, col: Int) -> Double {
        get {
            let v = col == 0 ? c1 : (col == 1 ? c2 : c3)
            return row == 0 ? v.x : (row == 1 ? v.y : v.z)
        }
        set {
            var v = col == 0 ? c1 : (col == 1 ? c2 : c3)
            if row == 0 { v.x = newValue } else if row == 1 { v.y = newValue } else { v.z = newValue }
            if col == 0 { c1 = v } else if col == 1 { c2 = v } else { c3 = v }
        }
    }
}

// MARK: - Camera / perspective projection

struct Projector {
    let eye: V3
    let right: V3
    let up: V3
    let fwd: V3
    let focal: Double
    let center: CGPoint

    init(azimuth: Double, elevation: Double, distance: Double, size: CGSize) {
        eye = V3(distance * cos(elevation) * cos(azimuth),
                 distance * cos(elevation) * sin(azimuth),
                 distance * sin(elevation))
        fwd = (V3.zero - eye).unit
        right = fwd.cross(V3(0, 0, 1)).unit
        up = right.cross(fwd).unit
        focal = Double(min(size.width, size.height)) * 1.45
        center = CGPoint(x: size.width / 2, y: size.height / 2 + 18)
    }

    /// Camera coordinates: (right, up, depth)
    func view(_ p: V3) -> V3 {
        let r = p - eye
        return V3(r.dot(right), r.dot(up), r.dot(fwd))
    }

    private func toScreen(_ v: V3) -> CGPoint {
        let s = focal / v.z
        return CGPoint(x: center.x + v.x * s, y: center.y - v.y * s)
    }

    func project(_ p: V3) -> CGPoint? {
        let v = view(p)
        guard v.z > 0.1 else { return nil }
        return toScreen(v)
    }

    func depth(_ p: V3) -> Double { view(p).z }

    /// Casts a ray through a screen point and intersects it with the world
    /// z = 0 plane - lets a 2D (planar) view turn a drag location straight
    /// back into math coordinates.
    func unprojectToZPlane(_ screen: CGPoint) -> V3? {
        let u = Double(screen.x - center.x) / focal
        let v = -Double(screen.y - center.y) / focal
        let dir = u * right + v * up + fwd
        guard abs(dir.z) > 1e-9 else { return nil }
        let t = -eye.z / dir.z
        guard t > 0 else { return nil }
        let p = eye + t * dir
        return V3(p.x, p.y, 0)
    }

    /// Segment clipped against the near plane, so nothing behind the camera is ever drawn.
    func segment(_ a: V3, _ b: V3) -> (CGPoint, CGPoint)? {
        let near = 0.1
        var va = view(a), vb = view(b)
        if va.z <= near && vb.z <= near { return nil }
        if va.z <= near {
            let t = (near - va.z) / (vb.z - va.z)
            va = va + t * (vb - va)
        } else if vb.z <= near {
            let t = (near - vb.z) / (va.z - vb.z)
            vb = vb + t * (va - vb)
        }
        return (toScreen(va), toScreen(vb))
    }
}

// MARK: - Main view

struct Matrix3DView: View {

    /// Set in challenge mode so the run can grade the map the student builds.
    var onReading: ((ChallengeReading) -> Void)? = nil

    @State private var matrix = M3.identity
    @State private var vector = V3(1, 1, 1)
    @State private var presetIndex = 0
    @State private var morph: Double = 1

    // Camera
    @State private var azimuth: Double = -0.9
    @State private var elevation: Double = 0.42
    @State private var distance: Double = 8.5

    /// Matrix actually rendered (morph between I and the chosen matrix).
    private var live: M3 { M3.lerp(.identity, matrix, morph) }
    private var image: V3 { matrix.apply(vector) }

    private var reading: SpaceMapReading {
        SpaceMapReading(vx: vector.x, vy: vector.y, vz: vector.z,
                        avx: image.x, avy: image.y, avz: image.z,
                        det: matrix.det, morph: morph)
    }

    // Palette
    static let vSceneColor = Color.primary
    static let avSceneColor = Color(red: 1.00, green: 0.80, blue: 0.26)
    static let avUIColor = Color(red: 0.72, green: 0.50, blue: 0.00)

    /// Same order in every algebra view: header, viewport, transformation
    /// slider, matrix panel, then whatever is specific to the view.
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                AlgebraHeader(
                    title: "A Linear Map in Space",
                    subtitle: "Edit the matrix and watch the unit cube become its image."
                )

                AlgebraViewport(
                    azimuth: $azimuth,
                    elevation: $elevation,
                    distance: $distance,
                    distanceRange: 4.5...16,
                    home: (azimuth: -0.9, elevation: 0.42, distance: 8.5),
                    accent: .cyan,
                    render: { ctx, size in render(ctx, size: size) },
                    hud: { hud },
                    legend: { legend }
                )

                MorphCard(morph: $morph, accent: .cyan)

                // Presets only: the nine cells live in the equation card just
                // below, where they sit next to v⃗ and Av⃗ and actually mean
                // something. Two editors for one matrix was pure duplication.
                MatrixControlPanel(
                    matrix: $matrix,
                    presetIndex: $presetIndex,
                    onPresetChange: applyPreset,
                    pickerHeight: 88,
                    showEditor: false
                )

                equationCard
            }
            .padding(10)
        }
        .onChange(of: reading, initial: true) { _, new in
            onReading?(.spaceMap(new))
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Viewport overlays

    private var hud: some View {
        let d = live.det
        let color: Color = abs(d) < 0.02 ? .orange : (d < 0 ? .pink : .cyan)
        return AlgebraHUD(headline: "det A = \(fmt(d, 3))",
                          detail: detComment(d),
                          color: color)
    }

    private var legend: some View {
        HStack(spacing: 11) {
            HStack(spacing: 5) {
                Rectangle()
                    .fill(Matrix3DView.vSceneColor.opacity(0.7))
                    .frame(width: 12, height: 2)
                Text("v").font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(Matrix3DView.vSceneColor)
            }
            HStack(spacing: 5) {
                Rectangle()
                    .fill(Matrix3DView.avSceneColor)
                    .frame(width: 12, height: 3)
                Text("Av").font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(Matrix3DView.avSceneColor)
            }
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(.thinMaterial, in: Capsule())
    }

    private func detComment(_ d: Double) -> String {
        if abs(d) < 0.02 { return "Space collapses, A is not invertible." }
        if d < 0 { return "Volume ×\(fmt(abs(d), 2)), orientation flipped." }
        return "Volume ×\(fmt(abs(d), 2))."
    }

    private func sectionLabel(_ t: String) -> some View {
        Text(t)
            .font(.system(size: 9, weight: .bold))
            .tracking(0.7)
            .foregroundStyle(.secondary)
    }

    private func applyPreset() {
        guard let m = MatrixPreset.sharedPresets[presetIndex].matrix else { return }
        matrix = m
        morph = 1
    }

    // MARK: - Equation A · v = Av

    private var equationCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 0) {
                sectionLabel("EQUATION")
                Spacer()
                Text("drag ↔ to edit · double-tap to zero")
                    .font(.system(size: 9))
                    .foregroundStyle(.tertiary)
            }

            HStack(alignment: .center, spacing: 3) {
                labelledBlock(titles: ["e⃗₁", "e⃗₂", "e⃗₃"],
                              tints: [.red, .green, .blue]) {
                    VStack(spacing: 3) {
                        ForEach(0..<3, id: \.self) { r in
                            HStack(spacing: 3) {
                                ForEach(0..<3, id: \.self) { c in
                                    ScrubCell(value: cellBinding(r, c), tint: Matrix3DView.colTint(c))
                                }
                            }
                        }
                    }
                }

                labelledBlock(titles: ["v⃗"], tints: [.secondary]) {
                    VStack(spacing: 3) {
                        ScrubCell(value: comp(\.x), tint: .gray)
                        ScrubCell(value: comp(\.y), tint: .gray)
                        ScrubCell(value: comp(\.z), tint: .gray)
                    }
                }

                Text("=")
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(.secondary)

                labelledBlock(titles: ["Av⃗"], tints: [Matrix3DView.avUIColor]) {
                    VStack(spacing: 3) {
                        resultCell(image.x)
                        resultCell(image.y)
                        resultCell(image.z)
                    }
                }
            }
            .frame(maxWidth: .infinity)

            Divider()

            combinationLine
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
    }

    /// Av = x·Ae₁ + y·Ae₂ + z·Ae₃, the "by columns" reading of the product.
    private var combinationLine: some View {
        VStack(alignment: .leading, spacing: 3) {
            (Text("Av⃗ = ").foregroundStyle(Matrix3DView.avUIColor)
             + Text(fmt(vector.x, 2)).foregroundStyle(Color.primary)
             + Text("· e⃗₁").foregroundStyle(Color.red)
             + Text("  +  ").foregroundStyle(Color.secondary)
             + Text(fmt(vector.y, 2)).foregroundStyle(Color.primary)
             + Text("· e⃗₂").foregroundStyle(Color.green)
             + Text("  +  ").foregroundStyle(Color.secondary)
             + Text(fmt(vector.z, 2)).foregroundStyle(Color.primary)
             + Text("· e⃗₃").foregroundStyle(Color.blue))
                .font(.system(size: 12.5, weight: .semibold, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text("The image of v⃗ is a combination of the columns of A, weighted by the coordinates of v⃗.")
                .font(.system(size: 9.5))
                .foregroundStyle(.secondary)
        }
    }

    private func labelledBlock<Content: View>(titles: [String], tints: [Color],
                                              @ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 2) {
            HStack(spacing: 3) {
                ForEach(titles.indices, id: \.self) { i in
                    Text(titles[i])
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(tints[i])
                        .frame(width: Matrix3DView.cellW)
                }
            }
            HStack(spacing: 2) {
                BracketShape(leading: true)
                    .stroke(Color.secondary.opacity(0.5), lineWidth: 1.2)
                    .frame(width: 5)
                content()
                BracketShape(leading: false)
                    .stroke(Color.secondary.opacity(0.5), lineWidth: 1.2)
                    .frame(width: 5)
            }
        }
    }

    private func resultCell(_ value: Double) -> some View {
        Text(fmt(value, 2))
            .font(.system(size: 11.5, weight: .bold, design: .monospaced))
            .foregroundStyle(Matrix3DView.avUIColor)
            .frame(width: Matrix3DView.cellW, height: Matrix3DView.cellH)
            .background(RoundedRectangle(cornerRadius: 6).fill(Matrix3DView.avUIColor.opacity(0.15)))
            .contentTransition(.numericText())
            .animation(.easeOut(duration: 0.15), value: value)
    }

    static let cellW: CGFloat = 42
    static let cellH: CGFloat = 29

    static func colTint(_ c: Int) -> Color { [.red, .green, .blue][c] }

    private func cellBinding(_ r: Int, _ c: Int) -> Binding<Double> {
        Binding(get: { matrix[r, c] },
                set: { matrix[r, c] = $0; presetIndex = 0 })   // manual edit → "Custom"
    }

    private func comp(_ key: WritableKeyPath<V3, Double>) -> Binding<Double> {
        Binding(get: { vector[keyPath: key] }, set: { vector[keyPath: key] = $0 })
    }

    // MARK: - 3D rendering

    private func render(_ ctx: GraphicsContext, size: CGSize) {
        let p = Projector(azimuth: azimuth, elevation: elevation, distance: distance, size: size)
        let A = live

        drawFloor(ctx, p)
        drawWorldAxes(ctx, p)
        drawShadow(ctx, p, A)
        drawReferenceCube(ctx, p)
        drawSolid(ctx, p, A)
        drawColumns(ctx, p, A)
        drawVectors(ctx, p, A)
    }

    // Floor: dark quad + grid
    private func drawFloor(_ ctx: GraphicsContext, _ p: Projector) {
        let r = 3.0
        let corners = [V3(-r, -r, 0), V3(r, -r, 0), V3(r, r, 0), V3(-r, r, 0)]
        var pts: [CGPoint] = []
        for c in corners {
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
            if let s = p.segment(V3(i, -r, 0), V3(i, r, 0)) {
                grid.move(to: s.0); grid.addLine(to: s.1)
            }
            if let s = p.segment(V3(-r, i, 0), V3(r, i, 0)) {
                grid.move(to: s.0); grid.addLine(to: s.1)
            }
            i += 0.5
        }
        ctx.stroke(grid, with: .color(.primary.opacity(0.09)), lineWidth: 0.7)
    }

    // World axes + canonical basis (dashed)
    private func drawWorldAxes(_ ctx: GraphicsContext, _ p: Projector) {
        let axes: [(V3, Color, String)] = [
            (V3(3.2, 0, 0), .red, "x"),
            (V3(0, 3.2, 0), .green, "y"),
            (V3(0, 0, 3.0), .blue, "z")
        ]
        for (end, color, label) in axes {
            if let s = p.segment(V3.zero, end) {
                var path = Path()
                path.move(to: s.0); path.addLine(to: s.1)
                ctx.stroke(path, with: .color(color.opacity(0.35)), lineWidth: 1.2)
            }
            if let tip = p.project(end) {
                ctx.draw(Text(label).font(.system(size: 12, weight: .bold)).foregroundStyle(color.opacity(0.8)),
                         at: CGPoint(x: tip.x + 10, y: tip.y - 8))
            }
        }
        let base: [(V3, Color)] = [(V3(1, 0, 0), .red), (V3(0, 1, 0), .green), (V3(0, 0, 1), .blue)]
        for (v, c) in base {
            if let s = p.segment(V3.zero, v) {
                var path = Path()
                path.move(to: s.0); path.addLine(to: s.1)
                ctx.stroke(path, with: .color(c.opacity(0.5)),
                           style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [4, 4]))
            }
        }
    }

    // Cast shadow of the parallelepiped on the floor (convex hull)
    private func drawShadow(_ ctx: GraphicsContext, _ p: Projector, _ A: M3) {
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

    // Original unit cube, discreet wireframe
    private func drawReferenceCube(_ ctx: GraphicsContext, _ p: Projector) {
        var path = Path()
        for (a, b) in Matrix3DView.cubeEdges {
            if let s = p.segment(a, b) { path.move(to: s.0); path.addLine(to: s.1) }
        }
        ctx.stroke(path, with: .color(.primary.opacity(0.22)),
                   style: StrokeStyle(lineWidth: 1, dash: [3, 4]))
    }

    // The image parallelepiped: depth-sorted faces + lighting
    private func drawSolid(_ ctx: GraphicsContext, _ p: Projector, _ A: M3) {
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
            let intensity = n.norm < 1e-7 ? 0.5 : 0.32 + 0.68 * abs(n.unit.dot(light))

            var path = Path()
            path.move(to: screen[0])
            for q in screen.dropFirst() { path.addLine(to: q) }
            path.closeSubpath()

            let centroid = 0.25 * (world[0] + world[1] + world[2] + world[3])
            faces.append((p.depth(centroid), path, intensity))
        }

        // painter's algorithm: far to near
        for f in faces.sorted(by: { $0.depth > $1.depth }) {
            let c = Color(red: 0.20 * f.shade, green: 0.78 * f.shade, blue: 0.92 * f.shade, opacity: 0.60)
            ctx.fill(f.path, with: .color(c))
            ctx.stroke(f.path, with: .color(.cyan.opacity(0.75)), lineWidth: 1.1)
        }
    }

    // The three columns of A
    private func drawColumns(_ ctx: GraphicsContext, _ p: Projector, _ A: M3) {
        let cols: [(V3, Color, String)] = [
            (A.c1, .red, "e⃗₁"), (A.c2, .green, "e⃗₂"), (A.c3, .blue, "e⃗₃")
        ]
        for (v, color, label) in cols {
            arrow(ctx, p, from: .zero, to: v, color: color, width: 4.5)
            if let tip = p.project(v) {
                ctx.draw(Text(label).font(.system(size: 12, weight: .bold)).foregroundStyle(color),
                         at: CGPoint(x: tip.x + 15, y: tip.y - 10))
            }
        }
    }

    // Test vector v and its image Av, both labelled, with plumb lines to the floor
    private func drawVectors(_ ctx: GraphicsContext, _ p: Projector, _ A: M3) {
        let img = A.apply(vector)
        let vTip = p.project(vector)
        let avTip = p.project(img)

        // Whenever A fixes v the two tips land on the same pixel, and with the
        // identity that is the very first thing on screen. Both labels would
        // then print on top of each other, so they are split apart vertically
        // instead: v⃗ above the tip, Av⃗ below it.
        let crowded: Bool = {
            guard let a = vTip, let b = avTip else { return false }
            return hypot(a.x - b.x, a.y - b.y) < 30
        }()

        arrow(ctx, p, from: .zero, to: vector,
              color: Matrix3DView.vSceneColor.opacity(0.55), width: 2.5, dashed: true)
        plumb(ctx, p, vector, color: Matrix3DView.vSceneColor.opacity(0.25))
        if let tip = vTip {
            ctx.draw(Text("v⃗").font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(Matrix3DView.vSceneColor),
                     at: CGPoint(x: tip.x + 14, y: tip.y - (crowded ? 26 : 12)))
        }

        arrow(ctx, p, from: .zero, to: img, color: Matrix3DView.avSceneColor, width: 5)
        plumb(ctx, p, img, color: Matrix3DView.avSceneColor.opacity(0.35))
        if let tip = avTip {
            ctx.draw(Text("Av⃗").font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(Matrix3DView.avSceneColor),
                     at: CGPoint(x: tip.x + 20, y: tip.y + (crowded ? 16 : -12)))
        }
    }

    /// Dashed plumb line down to the floor + a small ground dot: sells the height of a point.
    private func plumb(_ ctx: GraphicsContext, _ p: Projector, _ point: V3, color: Color) {
        let ground = V3(point.x, point.y, 0)
        if let s = p.segment(point, ground) {
            var path = Path()
            path.move(to: s.0); path.addLine(to: s.1)
            ctx.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
        }
        if let g = p.project(ground) {
            ctx.fill(Path(ellipseIn: CGRect(x: g.x - 4, y: g.y - 2, width: 8, height: 4)),
                     with: .color(color))
        }
    }

    private func arrow(_ ctx: GraphicsContext, _ p: Projector,
                       from a: V3, to b: V3, color: Color, width: CGFloat, dashed: Bool = false) {
        guard let s = p.segment(a, b) else { return }
        var line = Path()
        line.move(to: s.0); line.addLine(to: s.1)
        let style = dashed
            ? StrokeStyle(lineWidth: width, lineCap: .round, dash: [5, 5])
            : StrokeStyle(lineWidth: width, lineCap: .round)
        ctx.stroke(line, with: .color(color), style: style)

        let dx = s.1.x - s.0.x, dy = s.1.y - s.0.y
        let len = (dx * dx + dy * dy).squareRoot()
        guard len > 8 else { return }
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

    // MARK: - Unit cube geometry

    static let cubeCorners: [V3] = [
        V3(0, 0, 0), V3(1, 0, 0), V3(1, 1, 0), V3(0, 1, 0),
        V3(0, 0, 1), V3(1, 0, 1), V3(1, 1, 1), V3(0, 1, 1)
    ]

    static let cubeFaces: [[V3]] = [
        [V3(0,0,0), V3(0,1,0), V3(1,1,0), V3(1,0,0)],   // z = 0
        [V3(0,0,1), V3(1,0,1), V3(1,1,1), V3(0,1,1)],   // z = 1
        [V3(0,0,0), V3(1,0,0), V3(1,0,1), V3(0,0,1)],   // y = 0
        [V3(0,1,0), V3(0,1,1), V3(1,1,1), V3(1,1,0)],   // y = 1
        [V3(0,0,0), V3(0,0,1), V3(0,1,1), V3(0,1,0)],   // x = 0
        [V3(1,0,0), V3(1,1,0), V3(1,1,1), V3(1,0,1)]    // x = 1
    ]

    static let cubeEdges: [(V3, V3)] = [
        (V3(0,0,0), V3(1,0,0)), (V3(1,0,0), V3(1,1,0)), (V3(1,1,0), V3(0,1,0)), (V3(0,1,0), V3(0,0,0)),
        (V3(0,0,1), V3(1,0,1)), (V3(1,0,1), V3(1,1,1)), (V3(1,1,1), V3(0,1,1)), (V3(0,1,1), V3(0,0,1)),
        (V3(0,0,0), V3(0,0,1)), (V3(1,0,0), V3(1,0,1)), (V3(1,1,0), V3(1,1,1)), (V3(0,1,0), V3(0,1,1))
    ]

    /// 2D convex hull (monotone chain) used for the cast shadow.
    static func convexHull(_ points: [CGPoint]) -> [CGPoint] {
        guard points.count > 2 else { return points }
        let pts = points.sorted { $0.x == $1.x ? $0.y < $1.y : $0.x < $1.x }
        func cross(_ o: CGPoint, _ a: CGPoint, _ b: CGPoint) -> CGFloat {
            (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x)
        }
        var lower: [CGPoint] = []
        for p in pts {
            while lower.count >= 2 && cross(lower[lower.count - 2], lower[lower.count - 1], p) <= 0 {
                lower.removeLast()
            }
            lower.append(p)
        }
        var upper: [CGPoint] = []
        for p in pts.reversed() {
            while upper.count >= 2 && cross(upper[upper.count - 2], upper[upper.count - 1], p) <= 0 {
                upper.removeLast()
            }
            upper.append(p)
        }
        guard lower.count > 1, upper.count > 1 else { return points }
        lower.removeLast()
        upper.removeLast()
        return lower + upper
    }
}

// MARK: - Matrix brackets

struct BracketShape: Shape {
    var leading: Bool
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let tip = rect.width * 0.7
        if leading {
            p.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX - tip, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX - tip, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        } else {
            p.move(to: CGPoint(x: rect.minX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.minX + tip, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.minX + tip, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        }
        return p
    }
}

// MARK: - Scrubbable numeric cell

struct ScrubCell: View {
    @Binding var value: Double
    var tint: Color
    @State private var anchor: Double? = nil

    var body: some View {
        // Rounding a small negative number toward zero (drag/computation)
        // can land on -0.0, which %.2f prints as "-0.00". -0.0 == 0.0 in
        // IEEE754, so this substitution is free and always safe.
        Text(String(format: "%.2f", value == 0 ? 0 : value))
            .font(.system(size: 11.5, weight: .semibold, design: .monospaced))
            .foregroundStyle(.primary)
            .frame(width: Matrix3DView.cellW, height: Matrix3DView.cellH)
            .background(RoundedRectangle(cornerRadius: 6).fill(tint.opacity(0.15)))
            .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(tint.opacity(0.5), lineWidth: 1))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 1)
                    .onChanged { g in
                        if anchor == nil { anchor = value }
                        let raw = (anchor ?? 0) + Double(g.translation.width) / 45.0
                        value = min(max((raw * 4).rounded() / 4, -3), 3)
                    }
                    .onEnded { _ in anchor = nil }
            )
            .onTapGesture(count: 2) { value = 0 }
    }
}

private func fmt(_ v: Double, _ digits: Int) -> String {
    String(format: "%.\(digits)f", v)
}

#Preview {
    Matrix3DView()
}
