//
//  ImageSpaceView.swift
//  LearnViz
//
//  The image of a linear map: an integer lattice, and where it travels.
//  Reuses V3 / M3 / Projector / ScrubCell / BracketShape from Matrix3DView.swift
//  and the shared chrome from SharedMatrixComponents.swift.
//

import SwiftUI

struct ImageSpaceView: View {

    /// Set in challenge mode so the run can grade the map the student builds.
    var onReading: ((ChallengeReading) -> Void)? = nil

    @State private var matrix = M3(c1: V3(1, 0.3, 0), c2: V3(0.2, 1, 0.3), c3: V3(0, 0.2, 1))
    @State private var presetIndex = 2
    @State private var morph: Double = 1

    @State private var azimuth: Double = -0.9
    @State private var elevation: Double = 0.42
    @State private var distance: Double = 11

    /// Yellow glows nicely against the dark canvas, but reads poorly on a
    /// white light-mode background - swap to a vivid blue there instead.
    static let neonHalo = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 1.00, green: 0.84, blue: 0.02, alpha: 1)
            : UIColor(red: 0.05, green: 0.50, blue: 1.00, alpha: 1)
    })
    static let neonUI = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.62, green: 0.48, blue: 0.00, alpha: 1)
            : UIColor(red: 0.02, green: 0.32, blue: 0.68, alpha: 1)
    })
    static let sourceCol = Color(red: 0.55, green: 0.60, blue: 0.72)

    /// Thin rim around each core dot. Always a light tint, never `.primary` -
    /// where hundreds of points collapse onto one spot (rank < 3), this rim
    /// gets painted over itself many times; a light rim brightens into a
    /// glow there, while a dark one (as `.primary` would be in light mode)
    /// stacks into an ugly black smudge.
    static let coreRim = Color(UIColor { traits in
        UIColor.white.withAlphaComponent(traits.userInterfaceStyle == .dark ? 0.18 : 0.4)
    })

    /// Integer combinations of e₁, e₂, e₃.
    static let lattice: [V3] = {
        var pts: [V3] = []
        let r: Int = 3
        for i in -r...r {
            for j in -r...r {
                for k in -r...r {
                    pts.append(V3(Double(i), Double(j), Double(k)))
                }
            }
        }
        return pts
    }()

    /// A shell near the origin, threaded to its image.
    static let traced: [V3] = lattice.filter { p in
        let s: Double = abs(p.x) + abs(p.y) + abs(p.z)
        return s > 0.5 && s < 2.5
    }

    /// The matrix actually applied right now.
    private var live: M3 { M3.lerp(.identity, matrix, morph) }

    // MARK: Rank of the target map

    private var imageBasis: [V3] {
        var basis: [V3] = []
        for c in [matrix.c1, matrix.c2, matrix.c3] {
            var v: V3 = c
            for b in basis {
                let proj: V3 = b.dot(v) * b
                v = v - proj
            }
            if v.norm > 1e-4 { basis.append(v.unit) }
        }
        return basis
    }

    private var rank: Int { imageBasis.count }

    private var imageName: String {
        switch rank {
        case 3:  return "im A = ℝ³"
        case 2:  return "im A is a plane through 0"
        case 1:  return "im A is a line through 0"
        default: return "im A = {0}"
        }
    }

    /// Same order as Matrix3DView: header, viewport, transformation slider,
    /// matrix panel.
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 7) {
                AlgebraHeader(
                    title: "The Image of a Map",
                    subtitle: "Drag the transformation slider and watch the grid leave its origin."
                )

                AlgebraViewport(
                    azimuth: $azimuth,
                    elevation: $elevation,
                    distance: $distance,
                    distanceRange: 6...24,
                    home: (azimuth: -0.9, elevation: 0.42, distance: 11),
                    accent: ImageSpaceView.neonHalo,
                    render: { ctx, size in render(ctx, size: size) },
                    hud: { hud },
                    legend: { legend }
                )

                MorphCard(morph: $morph, accent: ImageSpaceView.neonUI)

                MatrixControlPanel(
                    matrix: $matrix,
                    presetIndex: $presetIndex,
                    onPresetChange: applyPreset,
                    pickerHeight: 88
                )
            }
            .padding(10)
        }
        .background(Color(.systemGroupedBackground))
        .onChange(of: reading, initial: true) { _, new in
            onReading?(.linearMap(new))
        }
    }

    private var reading: LinearMapReading {
        LinearMapReading(
            rank: rank,
            entries: [matrix.c1.x, matrix.c1.y, matrix.c1.z,
                      matrix.c2.x, matrix.c2.y, matrix.c2.z,
                      matrix.c3.x, matrix.c3.y, matrix.c3.z],
            morph: morph)
    }

    // MARK: - Viewport overlays

    private var hud: some View {
        AlgebraHUD(headline: "dim im A = \(rank)",
                   detail: imageName,
                   color: ImageSpaceView.neonHalo)
    }

    private var legend: some View {
        HStack(spacing: 11) {
            HStack(spacing: 5) {
                Circle()
                    .stroke(ImageSpaceView.sourceCol.opacity(0.9), lineWidth: 1.2)
                    .frame(width: 7, height: 7)
                Text("x").font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(ImageSpaceView.sourceCol)
            }
            HStack(spacing: 5) {
                Circle().fill(ImageSpaceView.neonHalo)
                    .frame(width: 6, height: 6)
                Text("Ax").font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(ImageSpaceView.neonHalo)
            }
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(.thinMaterial, in: Capsule())
    }

    private func applyPreset() {
        guard let m = MatrixPreset.sharedPresets[presetIndex].matrix else { return }
        matrix = m
        morph = 1
    }

    // MARK: - Rendering

    private func render(_ ctx: GraphicsContext, size: CGSize) {
        let p = Projector(azimuth: azimuth, elevation: elevation, distance: distance, size: size)
        let A: M3 = live

        drawGrid(ctx, p)
        drawAxes(ctx, p)
        drawSpanRegion(ctx, p)
        drawSourceLattice(ctx, p)
        drawSourceBox(ctx, p)
        drawImageBox(ctx, p, A)
        drawImageLattice(ctx, p, A)
        drawColumns(ctx, p, A)
    }

    private func drawGrid(_ ctx: GraphicsContext, _ p: Projector) {
        var grid = Path()
        var i: Double = -4
        while i <= 4 + 1e-6 {
            if let s = p.segment(V3(i, -4, 0), V3(i, 4, 0)) { grid.move(to: s.0); grid.addLine(to: s.1) }
            if let s = p.segment(V3(-4, i, 0), V3(4, i, 0)) { grid.move(to: s.0); grid.addLine(to: s.1) }
            i += 1
        }
        ctx.stroke(grid, with: .color(.primary.opacity(0.05)), lineWidth: 0.6)
    }

    private func drawAxes(_ ctx: GraphicsContext, _ p: Projector) {
        let axes: [(V3, Color)] = [(V3(4, 0, 0), .red), (V3(0, 4, 0), .green), (V3(0, 0, 4), .blue)]
        for (end, color) in axes {
            let start: V3 = (-1.0) * end
            if let s = p.segment(start, end) {
                var path = Path()
                path.move(to: s.0); path.addLine(to: s.1)
                ctx.stroke(path, with: .color(color.opacity(0.20)), lineWidth: 1)
            }
        }
    }

    /// Source points: hollow rings, no glow. They never move.
    private func drawSourceLattice(_ ctx: GraphicsContext, _ p: Projector) {
        var rings = Path()
        for q in ImageSpaceView.lattice {
            guard let s = p.project(q) else { continue }
            let d: Double = p.depth(q)
            let r: CGFloat = d < distance ? 2.6 : 1.9
            rings.addEllipse(in: CGRect(x: s.x - r, y: s.y - r, width: r * 2, height: r * 2))
        }
        ctx.stroke(rings, with: .color(ImageSpaceView.sourceCol.opacity(0.55)), lineWidth: 0.9)
    }

    /// The canonical box, fixed.
    private func drawSourceBox(_ ctx: GraphicsContext, _ p: Projector) {
        var path = Path()
        for (a, b) in Matrix3DView.cubeEdges {
            if let s = p.segment(a, b) { path.move(to: s.0); path.addLine(to: s.1) }
        }
        ctx.stroke(path, with: .color(ImageSpaceView.sourceCol.opacity(0.5)),
                   style: StrokeStyle(lineWidth: 1.1, dash: [4, 4]))
    }

    /// Threads from x to its current position.
    private func drawTraces(_ ctx: GraphicsContext, _ p: Projector, _ A: M3) {
        guard morph > 0.01 else { return }
        var path = Path()
        for q in ImageSpaceView.traced {
            let img: V3 = A.apply(q)
            guard let s = p.segment(q, img) else { continue }
            path.move(to: s.0)
            path.addLine(to: s.1)
        }
        let alpha: Double = 0.05 + 0.10 * morph
        ctx.stroke(path, with: .color(ImageSpaceView.neonHalo.opacity(alpha)), lineWidth: 0.7)
    }

    /// The moving parallelepiped.
    private func drawImageBox(_ ctx: GraphicsContext, _ p: Projector, _ A: M3) {
        let light: V3 = V3(0.45, -0.6, 0.85).unit
        var faces: [(Double, Path, Double)] = []

        for face in Matrix3DView.cubeFaces {
            let world: [V3] = face.map { A.apply($0) }
            var screen: [CGPoint] = []
            var ok = true
            for w in world {
                guard let s = p.project(w) else { ok = false; break }
                screen.append(s)
            }
            guard ok, screen.count == 4 else { continue }

            let e1: V3 = world[1] - world[0]
            let e2: V3 = world[2] - world[0]
            let n: V3 = e1.cross(e2)
            let shade: Double = n.norm < 1e-7 ? 0.6 : 0.35 + 0.65 * abs(n.unit.dot(light))

            var path = Path()
            path.move(to: screen[0])
            for q in screen.dropFirst() { path.addLine(to: q) }
            path.closeSubpath()

            let sum: V3 = world[0] + world[1] + world[2] + world[3]
            let centroid: V3 = 0.25 * sum
            faces.append((p.depth(centroid), path, shade))
        }

        for f in faces.sorted(by: { $0.0 > $1.0 }) {
            ctx.fill(f.1, with: .color(ImageSpaceView.neonHalo.opacity(0.11 * f.2)))
            ctx.stroke(f.1, with: .color(ImageSpaceView.neonHalo.opacity(0.6)), lineWidth: 1.2)
        }
    }

    /// Image points: a soft halo plus a solid core, denser clusters reading darker/richer.
    private func drawImageLattice(_ ctx: GraphicsContext, _ p: Projector, _ A: M3) {
        var pts: [(CGPoint, Double)] = []
        pts.reserveCapacity(ImageSpaceView.lattice.count)
        for q in ImageSpaceView.lattice {
            let img: V3 = A.apply(q)
            guard let s = p.project(img) else { continue }
            pts.append((s, p.depth(img)))
        }
        guard !pts.isEmpty else { return }

        pts.sort { $0.1 > $1.1 }

        let bands: Int = 5
        let per: Int = max(1, pts.count / bands)
        for band in 0..<bands {
            let lo: Int = band * per
            let hi: Int = (band == bands - 1) ? pts.count : min((band + 1) * per, pts.count)
            guard lo < hi else { continue }
            let t: Double = Double(band) / Double(max(bands - 1, 1))

            let rHalo: CGFloat = 2.8 + 2.4 * t
            let rCore: CGFloat = 1.1 + 1.0 * t
            var halo = Path()
            var core = Path()
            for idx in lo..<hi {
                let q: CGPoint = pts[idx].0
                halo.addEllipse(in: CGRect(x: q.x - rHalo, y: q.y - rHalo,
                                           width: rHalo * 2, height: rHalo * 2))
                core.addEllipse(in: CGRect(x: q.x - rCore, y: q.y - rCore,
                                           width: rCore * 2, height: rCore * 2))
            }
            ctx.fill(halo, with: .color(ImageSpaceView.neonHalo.opacity(0.14 + 0.16 * t)))
            ctx.fill(core, with: .color(ImageSpaceView.neonHalo.opacity(0.75 + 0.25 * t)))
            ctx.stroke(core, with: .color(ImageSpaceView.coreRim), lineWidth: 0.4)
        }
    }

    /// The target subspace, fading in with the morph.
    private func drawSpanRegion(_ ctx: GraphicsContext, _ p: Projector) {
        guard morph > 0.05, rank < 3 else { return }
        let b: [V3] = imageBasis
        let fade: Double = morph * morph

        if b.count == 2 {
            let k: Double = 5.0
            let u: V3 = k * b[0]
            let w: V3 = k * b[1]
            let mu: V3 = (-k) * b[0]
            let mw: V3 = (-k) * b[1]

            var corners: [V3] = []
            corners.append(mu + mw)
            corners.append(u + mw)
            corners.append(u + w)
            corners.append(mu + w)

            var pts: [CGPoint] = []
            for c in corners {
                guard let s = p.project(c) else { return }
                pts.append(s)
            }
            var path = Path()
            path.move(to: pts[0])
            for q in pts.dropFirst() { path.addLine(to: q) }
            path.closeSubpath()
            ctx.fill(path, with: .color(ImageSpaceView.neonHalo.opacity(0.06 * fade)))
            ctx.stroke(path, with: .color(ImageSpaceView.neonHalo.opacity(0.28 * fade)), lineWidth: 1)

        } else if b.count == 1 {
            let e: V3 = 5.4 * b[0]
            let s0: V3 = (-1.0) * e
            guard let s = p.segment(s0, e) else { return }
            var path = Path()
            path.move(to: s.0)
            path.addLine(to: s.1)
            ctx.stroke(path, with: .color(ImageSpaceView.neonHalo.opacity(0.32 * fade)),
                       style: StrokeStyle(lineWidth: 2, lineCap: .round))
        }
    }

    private func drawColumns(_ ctx: GraphicsContext, _ p: Projector, _ A: M3) {
        let cols: [(V3, Color, String)] = [
            (A.c1, .red, "e⃗₁"), (A.c2, .green, "e⃗₂"), (A.c3, .blue, "e⃗₃")
        ]
        for (v, color, label) in cols {
            guard v.norm > 0.02 else { continue }
            arrow(ctx, p, to: v, color: color, width: 3)
            if let tip = p.project(v) {
                ctx.draw(Text(label).font(.system(size: 12, weight: .bold)).foregroundStyle(color),
                         at: CGPoint(x: tip.x + 18, y: tip.y - 10))
            }
        }
    }

    private func arrow(_ ctx: GraphicsContext, _ p: Projector, to b: V3, color: Color, width: CGFloat) {
        guard let s = p.segment(.zero, b) else { return }
        var line = Path()
        line.move(to: s.0); line.addLine(to: s.1)
        ctx.stroke(line, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round))

        let dx: CGFloat = s.1.x - s.0.x
        let dy: CGFloat = s.1.y - s.0.y
        guard (dx * dx + dy * dy).squareRoot() > 8 else { return }
        let ang: CGFloat = atan2(dy, dx)
        let L: CGFloat = width * 3.0
        let spread: CGFloat = .pi / 7
        var head = Path()
        head.move(to: s.1)
        head.addLine(to: CGPoint(x: s.1.x - L * cos(ang - spread), y: s.1.y - L * sin(ang - spread)))
        head.addLine(to: CGPoint(x: s.1.x - L * cos(ang + spread), y: s.1.y - L * sin(ang + spread)))
        head.closeSubpath()
        ctx.fill(head, with: .color(color))
    }
}

#Preview {
    ImageSpaceView()
        .preferredColorScheme(.dark)
}
