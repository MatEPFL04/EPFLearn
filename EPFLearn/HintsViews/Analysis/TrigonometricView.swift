import SwiftUI

// MARK: - Palette

enum TrigPalette {
    static let cosColor = Color(red: 0.98, green: 0.55, blue: 0.12)   // x / cos θ / partie réelle
    static let sinColor = Color(red: 0.15, green: 0.62, blue: 0.86)   // y / sin θ / partie imaginaire
    static let tanColor = Color(red: 0.16, green: 0.72, blue: 0.46)
    static let radius = Color(red: 0.48, green: 0.38, blue: 0.78)     // z₁
    static let z2 = Color(red: 0.87, green: 0.32, blue: 0.55)         // z₂
    static let result = Color(red: 0.85, green: 0.62, blue: 0.08)     // z₁ combiné z₂
    static let ghost = Color(.secondaryLabel)
    static let ink = Color(.label)
}

struct TrigoView: View {


    @State private var theta: Double = .pi / 4    // angle de z₁, partagé avec le mode Réel
   
    @State private var r1: Double = 1.0           // rayon de z₁ — uniquement en mode Complexe
    @State private var theta2: Double = .pi / 3   // angle de z₂
    @State private var r2: Double = 0.7           // rayon de z₂

    let graphSize: CGFloat = 320
    let scale: Double = 110

    // Repère mathématique <-> écran, comme dans les autres vues du projet.
    var cs: MathCoordinateSpace { MathCoordinateSpace(size: graphSize, scale: scale) }

    // Angles remarquables affichés autour du cercle (et utilisés pour l'aimantation)
    static let markers: [(Double, String)] = [
        (0, "0"), (.pi / 6, "π/6"), (.pi / 4, "π/4"), (.pi / 3, "π/3"),
        (.pi / 2, "π/2"), (2 * .pi / 3, "2π/3"), (3 * .pi / 4, "3π/4"), (5 * .pi / 6, "5π/6"),
        (.pi, "π"), (7 * .pi / 6, "7π/6"), (5 * .pi / 4, "5π/4"), (4 * .pi / 3, "4π/3"),
        (3 * .pi / 2, "3π/2"), (5 * .pi / 3, "5π/3"), (7 * .pi / 4, "7π/4"), (11 * .pi / 6, "11π/6")
    ]

    var cosT: Double { cos(theta) }
    var sinT: Double { sin(theta) }
    var tanT: Double? { abs(cosT) < 0.05 ? nil : sinT / cosT }


    func fmt(_ v: Double) -> String { String(format: "%.2f", v) }



    // exprime un angle comme un multiple de π (ex. 0.05π), plus lisible qu'un radian brut
    func piCoeff(_ angle: Double) -> String {
        var normalized = angle.truncatingRemainder(dividingBy: 2 * .pi)
        if normalized < 0 { normalized += 2 * .pi }
        return String(format: "%.2fπ", normalized / .pi)
    }

    // écart angulaire signé le plus court entre deux angles (gère le passage par 0/2π)
    func angleDistance(_ a: Double, _ b: Double) -> Double {
        var diff = a.truncatingRemainder(dividingBy: 2 * .pi) - b
        if diff > .pi { diff -= 2 * .pi }
        if diff < -.pi { diff += 2 * .pi }
        return diff
    }

    func snappedAngle(near raw: Double) -> Double {
        for (value, _) in Self.markers where abs(angleDistance(raw, value)) < 0.035 {
            return value
        }
        return raw
    }

    func angle(at location: CGPoint) -> Double {
        let dx = Double(location.x - graphSize / 2)
        let dy = Double(-(location.y - graphSize / 2))
        var a = atan2(dy, dx)
        if a < 0 { a += 2 * .pi }
        return a
    }

    var body: some View {
        VStack(spacing: 12) {
            
            Text("Trigonometric circle")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            
                .pickerStyle(.segmented)
                .frame(width: graphSize)
            
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(LinearGradient(colors: [Color(.secondarySystemBackground), Color(.systemBackground)],
                                         startPoint: .top, endPoint: .bottom))
                
                GridDrawing(step: 20)
                    .stroke(TrigPalette.ghost.opacity(0.15), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal).stroke(TrigPalette.ghost.opacity(0.5), lineWidth: 1.2)
                AxisDrawing(axis: .vertical).stroke(TrigPalette.ghost.opacity(0.5), lineWidth: 1.2)
                
                // cercle unité — repère constant pour lire les angles
                Circle()
                    .stroke(TrigPalette.ink.opacity(0.5), lineWidth: 1.5)
                    .frame(width: scale * 2, height: scale * 2)
                    .position(cs.toScreen(x: 0, y: 0))
                
                
                ForEach(Array(Self.markers.enumerated()), id: \.offset) { _, marker in
                    let (value, label) = marker
                    Circle().fill(TrigPalette.ghost.opacity(0.5)).frame(width: 4, height: 4)
                        .position(cs.toScreen(x: cos(value), y: sin(value)))
                    Text(label)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(TrigPalette.ghost)
                        .position(cs.toScreen(x: cos(value) * 1.18, y: sin(value) * 1.18))
                }
                
                // arc balayant l'angle θ depuis l'axe des x
                Path { path in
                    let steps = 40
                    let points = (0...steps).map { i -> CGPoint in
                        let t = theta * Double(i) / Double(steps)
                        return cs.toScreen(x: 0.22 * cos(t), y: 0.22 * sin(t))
                    }
                    path.move(to: points[0])
                    for p in points.dropFirst() { path.addLine(to: p) }
                }
                .stroke(TrigPalette.ink.opacity(0.6), lineWidth: 1.5)
                
                // ===================== MODE RÉEL =====================
                // segment cos θ le long de l'axe x
                Path { p in
                    p.move(to: cs.toScreen(x: 0, y: 0))
                    p.addLine(to: cs.toScreen(x: cosT, y: 0))
                }
                .stroke(TrigPalette.cosColor, lineWidth: 3)
                
                Path { p in
                    p.move(to: cs.toScreen(x: cosT, y: 0))
                    p.addLine(to: cs.toScreen(x: cosT, y: sinT))
                }
                .stroke(TrigPalette.cosColor.opacity(0.4), style: StrokeStyle(lineWidth: 1.2, dash: [3, 3]))
                
                // segment sin θ le long de l'axe y
                Path { p in
                    p.move(to: cs.toScreen(x: 0, y: 0))
                    p.addLine(to: cs.toScreen(x: 0, y: sinT))
                }
                .stroke(TrigPalette.sinColor, lineWidth: 3)
                
                Path { p in
                    p.move(to: cs.toScreen(x: 0, y: sinT))
                    p.addLine(to: cs.toScreen(x: cosT, y: sinT))
                }
                .stroke(TrigPalette.sinColor.opacity(0.4), style: StrokeStyle(lineWidth: 1.2, dash: [3, 3]))
                
                // rayon
                Path { p in
                    p.move(to: cs.toScreen(x: 0, y: 0))
                    p.addLine(to: cs.toScreen(x: cosT, y: sinT))
                }
                .stroke(TrigPalette.radius, lineWidth: 2)
                
                // droite tangente en (1,0) — n'a de sens qu'en mode Réel
                Path { p in
                    p.move(to: cs.toScreen(x: 1, y: -2.6))
                    p.addLine(to: cs.toScreen(x: 1, y: 2.6))
                }
                .stroke(TrigPalette.tanColor.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                
                if let tv = tanT {
                    Path { p in
                        p.move(to: cs.toScreen(x: cosT, y: sinT))
                        p.addLine(to: cs.toScreen(x: 1, y: tv))
                    }
                    .stroke(TrigPalette.radius.opacity(0.4), style: StrokeStyle(lineWidth: 1.2, dash: [2, 3]))
                    
                    Path { p in
                        p.move(to: cs.toScreen(x: 1, y: 0))
                        p.addLine(to: cs.toScreen(x: 1, y: tv))
                    }
                    .stroke(TrigPalette.tanColor, lineWidth: 3)
                    
                    let tanPoint = cs.toScreen(x: 1, y: tv)
                    Text("tan θ")
                        .font(.caption2.bold())
                        .foregroundStyle(TrigPalette.tanColor)
                        .position(x: tanPoint.x + 20, y: tanPoint.y)
                }
                
                // point mobile
                Circle()
                    .fill(TrigPalette.radius)
                    .frame(width: 13, height: 13)
                    .shadow(color: TrigPalette.radius.opacity(0.5), radius: 5)
                    .position(cs.toScreen(x: cosT, y: sinT))
                
                let cosLabelPoint = cs.toScreen(x: cosT / 2, y: 0)
                Text("cos θ")
                    .font(.caption2.bold())
                    .foregroundStyle(TrigPalette.cosColor)
                    .position(x: cosLabelPoint.x, y: cosLabelPoint.y + 12)
                
                let sinLabelPoint = cs.toScreen(x: 0, y: sinT / 2)
                Text("sin θ")
                    .font(.caption2.bold())
                    .foregroundStyle(TrigPalette.sinColor)
                    .position(x: sinLabelPoint.x - 18, y: sinLabelPoint.y)
                
                
                HStack(spacing: 8) {
                    Text("θ").font(.caption).foregroundStyle(TrigPalette.radius).frame(width: 20)
                    Slider(value: $theta, in: 0...(2 * .pi)).tint(TrigPalette.radius)
                }
                .frame(width: graphSize - 40)
                
                HStack(spacing: 18) {
                    Text("cos θ = \(fmt(cosT))").foregroundStyle(TrigPalette.cosColor)
                    Text("sin θ = \(fmt(sinT))").foregroundStyle(TrigPalette.sinColor)
                    Text(tanT.map { "tan θ = \(fmt($0))" } ?? "tan θ indéfinie")
                        .foregroundStyle(TrigPalette.tanColor)
                }
                .font(.system(.footnote, design: .monospaced))
                .frame(width: graphSize)
            }
        }
    }
}

#Preview {
    TrigoView()
    
}
