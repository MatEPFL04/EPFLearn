//
//  TrigPlotKit.swift
//  EPFLearn
//
//  Socle commun à TrigoView et ComplexPlaneView : palette, repère, conteneur
//  Canvas et primitives de dessin. Aucune vue métier ici.
//

import SwiftUI

// MARK: - Palette

enum TrigPalette {
    static let cosColor = Color(red: 0.98, green: 0.55, blue: 0.12)   // x / partie réelle
    static let sinColor = Color(red: 0.15, green: 0.62, blue: 0.86)   // y / partie imaginaire
    static let tanColor = Color(red: 0.16, green: 0.72, blue: 0.46)
    static let radius   = Color(red: 0.48, green: 0.38, blue: 0.78)   // rayon / z₁
    static let z2       = Color(red: 0.87, green: 0.32, blue: 0.55)   // z₂
    static let result   = Color(red: 0.85, green: 0.62, blue: 0.08)   // z₁ ∘ z₂
    static let ghost    = Color(.secondaryLabel)
    static let ink      = Color(.label)
}

// MARK: - Angles remarquables

enum TrigAngles {

    static let all: [(angle: Double, label: String)] = [
        (0, "0"), (.pi / 6, "π/6"), (.pi / 4, "π/4"), (.pi / 3, "π/3"),
        (.pi / 2, "π/2"), (2 * .pi / 3, "2π/3"), (3 * .pi / 4, "3π/4"), (5 * .pi / 6, "5π/6"),
        (.pi, "π"), (7 * .pi / 6, "7π/6"), (5 * .pi / 4, "5π/4"), (4 * .pi / 3, "4π/3"),
        (3 * .pi / 2, "3π/2"), (5 * .pi / 3, "5π/3"), (7 * .pi / 4, "7π/4"), (11 * .pi / 6, "11π/6")
    ]

    /// Écart signé le plus court entre deux angles (gère le passage par 0/2π).
    static func distance(_ a: Double, _ b: Double) -> Double {
        var d = a.truncatingRemainder(dividingBy: 2 * .pi) - b
        if d >  .pi { d -= 2 * .pi }
        if d < -.pi { d += 2 * .pi }
        return d
    }

    static func normalize(_ a: Double) -> Double {
        var v = a.truncatingRemainder(dividingBy: 2 * .pi)
        if v < 0 { v += 2 * .pi }
        return v
    }

    /// Aimantation. Tolérance large à dessein : 0.035 rad était invisable au doigt.
    static func snap(_ angle: Double, tolerance: Double = 0.06) -> Double {
        let a = normalize(angle)
        return all.first { abs(distance(a, $0.angle)) < tolerance }?.angle ?? a
    }
}

// MARK: - Repère math ↔ pixels

struct TrigSpace {
    let side: CGFloat
    let unit: CGFloat            // pixels par unité mathématique

    init(side: CGFloat, fitRadius: Double) {
        self.side = side
        self.unit = side / 2 / CGFloat(max(fitRadius, 0.001))
    }

    var center: CGPoint { CGPoint(x: side / 2, y: side / 2) }
    /// Demi-étendue visible, en unités mathématiques.
    var halfExtent: Double { Double(side / 2 / unit) }

    func point(_ x: Double, _ y: Double) -> CGPoint {
        CGPoint(x: center.x + CGFloat(x) * unit, y: center.y - CGFloat(y) * unit)
    }

    func math(_ p: CGPoint) -> (x: Double, y: Double) {
        (Double(p.x - center.x) / Double(unit), Double(center.y - p.y) / Double(unit))
    }
}

// MARK: - Conteneur

/// Carré auto-dimensionné. Le Canvas reçoit sa taille dans sa closure : aucune
/// constante de layout, aucun GeometryReader racine - donc sûr à l'intérieur du
/// ScrollView de VisualizationView, où un GeometryReader reçoit une hauteur nulle.
struct TrigPlotCanvas: View {

    let fitRadius: Double
    var onDragBegan: ((CGPoint, TrigSpace) -> Void)? = nil
    var onDragChanged: ((CGPoint, TrigSpace) -> Void)? = nil
    var onDragEnded: (() -> Void)? = nil
    let content: (inout GraphicsContext, TrigSpace) -> Void

    @State private var side: CGFloat = 0
    @State private var dragging = false

    var body: some View {
        Canvas { ctx, size in
            let space = TrigSpace(side: min(size.width, size.height), fitRadius: fitRadius)
            let frame = Path(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 22)
            ctx.fill(frame, with: .linearGradient(
                Gradient(colors: [Color(.secondarySystemBackground), Color(.systemBackground)]),
                startPoint: .zero, endPoint: CGPoint(x: 0, y: size.height)))
            ctx.clip(to: frame)

            ctx.drawGrid(space)
            ctx.drawAxes(space)
            content(&ctx, space)
        }
        .aspectRatio(1, contentMode: .fit)
        .background(GeometryReader { g in
            Color.clear.preference(key: TrigSideKey.self,
                                   value: min(g.size.width, g.size.height))
        })
        .onPreferenceChange(TrigSideKey.self) { side = $0 }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { g in
                    guard side > 0 else { return }
                    let space = TrigSpace(side: side, fitRadius: fitRadius)
                    if !dragging { dragging = true; onDragBegan?(g.location, space) }
                    onDragChanged?(g.location, space)
                }
                .onEnded { _ in dragging = false; onDragEnded?() }
        )
        .shadow(color: .black.opacity(0.10), radius: 12, y: 6)
    }
}

private struct TrigSideKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - Primitives de dessin

extension GraphicsContext {

    mutating func line(_ a: CGPoint, _ b: CGPoint, _ color: Color,
                       width: CGFloat = 1, dash: [CGFloat] = []) {
        var p = Path(); p.move(to: a); p.addLine(to: b)
        stroke(p, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round, dash: dash))
    }

    mutating func ring(_ s: TrigSpace, radius r: Double, _ color: Color,
                       width: CGFloat = 1, dash: [CGFloat] = []) {
        let rr = s.unit * CGFloat(r)
        let box = CGRect(x: s.center.x - rr, y: s.center.y - rr, width: rr * 2, height: rr * 2)
        stroke(Path(ellipseIn: box), with: .color(color),
               style: StrokeStyle(lineWidth: width, dash: dash))
    }

    /// Point manipulable : halo + cœur, lisible sur fond clair comme sombre.
    mutating func dot(_ p: CGPoint, _ color: Color, radius r: CGFloat) {
        fill(Path(ellipseIn: CGRect(x: p.x - r * 1.9, y: p.y - r * 1.9,
                                    width: r * 3.8, height: r * 3.8)),
             with: .color(color.opacity(0.18)))
        fill(Path(ellipseIn: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2)),
             with: .color(color))
    }

    mutating func label(_ string: String, at p: CGPoint, size: CGFloat,
                        _ color: Color, bold: Bool = false) {
        var t = resolve(Text(string).font(.system(size: size,
                                                  weight: bold ? .bold : .regular,
                                                  design: .monospaced)))
        t.shading = .color(color)
        draw(t, at: p, anchor: .center)
    }

    /// A label on its own filled plate. Plain text over the grid was legible
    /// on an empty plot and unreadable the moment a vector, the circle or the
    /// other point ran underneath it, which is exactly when it matters most.
    /// Stays inside `bounds` so a point dragged to the edge keeps its readout.
    /// Non-mutating so the algebra views, which hand their context around by
    /// value, can label their vectors the same way.
    func chip(_ string: String, at p: CGPoint, size: CGFloat,
              _ color: Color, within bounds: CGSize) {
        var t = resolve(Text(string).font(.system(size: size, weight: .bold, design: .monospaced)))
        t.shading = .color(.white)

        let m = t.measure(in: CGSize(width: 500, height: 100))
        let w = m.width + 10, h = m.height + 6

        let cx = min(max(p.x, w / 2 + 2), max(bounds.width - w / 2 - 2, w / 2 + 2))
        let cy = min(max(p.y, h / 2 + 2), max(bounds.height - h / 2 - 2, h / 2 + 2))
        let plate = Path(roundedRect: CGRect(x: cx - w / 2, y: cy - h / 2, width: w, height: h),
                         cornerRadius: 5)

        fill(plate, with: .color(color))
        stroke(plate, with: .color(.white.opacity(0.55)), lineWidth: 0.8)
        draw(t, at: CGPoint(x: cx, y: cy), anchor: .center)
    }

    mutating func drawGrid(_ s: TrigSpace) {
        let e = s.halfExtent
        var path = Path()
        var v = -(e / 0.5).rounded(.up) * 0.5
        while v <= e {
            path.move(to: s.point(v, -e)); path.addLine(to: s.point(v, e))
            path.move(to: s.point(-e, v)); path.addLine(to: s.point(e, v))
            v += 0.5
        }
        stroke(path, with: .color(TrigPalette.ghost.opacity(0.15)), lineWidth: 0.5)
    }

    mutating func drawAxes(_ s: TrigSpace) {
        let e = s.halfExtent
        line(s.point(-e, 0), s.point(e, 0), TrigPalette.ghost.opacity(0.5), width: 1.2)
        line(s.point(0, -e), s.point(0, e), TrigPalette.ghost.opacity(0.5), width: 1.2)
    }

    /// Cercle unité + points des angles remarquables.
    mutating func drawUnitCircle(_ s: TrigSpace, labels: Bool = true) {
        ring(s, radius: 1, TrigPalette.ink.opacity(0.5), width: 1.5)

        var dots = Path()
        for m in TrigAngles.all {
            let p = s.point(cos(m.angle), sin(m.angle))
            dots.addEllipse(in: CGRect(x: p.x - 2, y: p.y - 2, width: 4, height: 4))
        }
        fill(dots, with: .color(TrigPalette.ghost.opacity(0.5)))

        // Sous 300 pt les 16 étiquettes se chevauchent et brouillent le cercle.
        guard labels, s.side > 300 else { return }
        for m in TrigAngles.all {
            label(m.label, at: s.point(cos(m.angle) * 1.17, sin(m.angle) * 1.17),
                  size: 9, TrigPalette.ghost)
        }
    }

    /// Arc balayé depuis l'axe des x jusqu'à `angle`.
    mutating func drawArc(_ s: TrigSpace, to angle: Double, radius r: Double = 0.22) {
        var path = Path()
        for i in 0...40 {
            let t = angle * Double(i) / 40
            let p = s.point(r * cos(t), r * sin(t))
            if i == 0 { path.move(to: p) } else { path.addLine(to: p) }
        }
        stroke(path, with: .color(TrigPalette.ink.opacity(0.6)), lineWidth: 1.5)
    }

    mutating func arrow(_ s: TrigSpace, to p: CGPoint, _ color: Color, width: CGFloat) {
        line(s.center, p, color, width: width)
        let dx = p.x - s.center.x, dy = p.y - s.center.y
        guard hypot(dx, dy) > 12 else { return }
        let a = atan2(dy, dx), len = width * 3.2, spread = CGFloat.pi / 7
        var head = Path()
        head.move(to: p)
        head.addLine(to: CGPoint(x: p.x - len * cos(a - spread), y: p.y - len * sin(a - spread)))
        head.addLine(to: CGPoint(x: p.x - len * cos(a + spread), y: p.y - len * sin(a + spread)))
        head.closeSubpath()
        fill(head, with: .color(color))
    }
}

// MARK: - Contrôle partagé

struct TrigSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let tint: Color
    var asMultipleOfPi = false
    /// Applied to whatever the thumb produces. The canvas magnetises a dragged
    /// point onto the notable angles; without the same treatment here, the two
    /// controls disagree about which values of θ exist.
    var snap: ((Double) -> Double)? = nil

    private var proxy: Binding<Double> {
        Binding(get: { value },
                set: { new in value = snap.map { $0(new) } ?? new })
    }

    var body: some View {
        VizSlider(label: title, value: proxy, range: range, accent: tint,
                  valueText: asMultipleOfPi ? String(format: "%.2fπ", value / .pi)
                                            : String(format: "%.2f", value))
    }
}
