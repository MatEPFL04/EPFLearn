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

    enum Mode: String, CaseIterable { case reel = "Réel", complexe = "Complexe" }
    enum ComplexOp: String, CaseIterable { case add = "+", multiply = "×" }

    @State private var theta: Double = .pi / 4    // angle de z₁, partagé avec le mode Réel
    @State private var mode: Mode = .reel

    @State private var r1: Double = 1.0           // rayon de z₁ — uniquement en mode Complexe
    @State private var theta2: Double = .pi / 3   // angle de z₂
    @State private var r2: Double = 0.7           // rayon de z₂
    @State private var operation: ComplexOp = .multiply

    init(mode initialMode: Mode = .reel) {
        _mode = State(initialValue: initialMode)
    }

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

    // z₁ = r₁·e^{iθ}
    var z1Real: Double { r1 * cosT }
    var z1Imag: Double { r1 * sinT }

    // z₂ = r₂·e^{iθ₂}
    var z2Real: Double { r2 * cos(theta2) }
    var z2Imag: Double { r2 * sin(theta2) }

    // z₁ combiné à z₂ (somme ou produit selon le mode choisi)
    var combinedModulus: Double {
        switch operation {
        case .add: return sqrt(pow(z1Real + z2Real, 2) + pow(z1Imag + z2Imag, 2))
        case .multiply: return r1 * r2
        }
    }
    var combinedArgument: Double {
        switch operation {
        case .add: return atan2(z1Imag + z2Imag, z1Real + z2Real)
        case .multiply:
            var a = (theta + theta2).truncatingRemainder(dividingBy: 2 * .pi)
            if a < 0 { a += 2 * .pi }
            return a
        }
    }
    var combinedReal: Double { combinedModulus * cos(combinedArgument) }
    var combinedImag: Double { combinedModulus * sin(combinedArgument) }

    func fmt(_ v: Double) -> String { String(format: "%.2f", v) }

    // affiche a + bi proprement (pas de "+ -1.01i")
    func complexString(_ re: Double, _ im: Double) -> String {
        let sign = im < 0 ? "−" : "+"
        return "\(fmt(re)) \(sign) \(fmt(abs(im)))i"
    }

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

            Text("Unit circle: real & complex view")
                .font(.caption)
                .foregroundStyle(.secondary)

            Picker("", selection: $mode) {
                ForEach(Mode.allCases, id: \.self) { m in Text(m.rawValue).tag(m) }
            }
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

                // en mode Complexe, cercle pointillé au rayon réel de z₁ si différent de 1
                if mode == .complexe {
                    Circle()
                        .stroke(TrigPalette.radius.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                        .frame(width: scale * 2 * r1, height: scale * 2 * r1)
                        .position(cs.toScreen(x: 0, y: 0))
                }

                // marqueurs des angles remarquables
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
                if mode == .reel {
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
                }

                // ===================== MODE COMPLEXE =====================
                if mode == .complexe {
                    // guides du parallélogramme pour la somme z₁ + z₂
                    if operation == .add {
                        Path { p in
                            p.move(to: cs.toScreen(x: z1Real, y: z1Imag))
                            p.addLine(to: cs.toScreen(x: z1Real + z2Real, y: z1Imag + z2Imag))
                        }
                        .stroke(TrigPalette.z2.opacity(0.35), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))

                        Path { p in
                            p.move(to: cs.toScreen(x: z2Real, y: z2Imag))
                            p.addLine(to: cs.toScreen(x: z1Real + z2Real, y: z1Imag + z2Imag))
                        }
                        .stroke(TrigPalette.radius.opacity(0.35), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                    }

                    // vecteur z₁
                    Path { p in
                        p.move(to: cs.toScreen(x: 0, y: 0))
                        p.addLine(to: cs.toScreen(x: z1Real, y: z1Imag))
                    }
                    .stroke(TrigPalette.radius, lineWidth: 2.4)
                    Circle().fill(TrigPalette.radius).frame(width: 11, height: 11)
                        .shadow(color: TrigPalette.radius.opacity(0.5), radius: 4)
                        .position(cs.toScreen(x: z1Real, y: z1Imag))
                    let z1Point = cs.toScreen(x: z1Real, y: z1Imag)
                    Text("z₁").font(.caption2.bold()).foregroundStyle(TrigPalette.radius)
                        .position(x: z1Point.x + 14, y: z1Point.y - 10)

                    // vecteur z₂
                    Path { p in
                        p.move(to: cs.toScreen(x: 0, y: 0))
                        p.addLine(to: cs.toScreen(x: z2Real, y: z2Imag))
                    }
                    .stroke(TrigPalette.z2, lineWidth: 2.4)
                    Circle().fill(TrigPalette.z2).frame(width: 11, height: 11)
                        .shadow(color: TrigPalette.z2.opacity(0.5), radius: 4)
                        .position(cs.toScreen(x: z2Real, y: z2Imag))
                    let z2Point = cs.toScreen(x: z2Real, y: z2Imag)
                    Text("z₂").font(.caption2.bold()).foregroundStyle(TrigPalette.z2)
                        .position(x: z2Point.x + 14, y: z2Point.y - 10)

                    // vecteur résultat (mis en avant)
                    Path { p in
                        p.move(to: cs.toScreen(x: 0, y: 0))
                        p.addLine(to: cs.toScreen(x: combinedReal, y: combinedImag))
                    }
                    .stroke(TrigPalette.result, lineWidth: 3)
                    Circle().fill(TrigPalette.result).frame(width: 14, height: 14)
                        .shadow(color: TrigPalette.result.opacity(0.6), radius: 6)
                        .position(cs.toScreen(x: combinedReal, y: combinedImag))
                    let resultPoint = cs.toScreen(x: combinedReal, y: combinedImag)
                    Text("z₁ \(operation.rawValue) z₂")
                        .font(.caption2.bold()).foregroundStyle(TrigPalette.result)
                        .position(x: resultPoint.x + 26, y: resultPoint.y - 10)
                }
            }
            .frame(width: graphSize, height: graphSize)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in theta = angle(at: value.location) }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            theta = snappedAngle(near: angle(at: value.location))
                        }
                    }
            )
            .shadow(color: .black.opacity(0.1), radius: 12, y: 6)

            // Sliders volontairement plus étroits que l'écran : un slider qui
            // touche les bords entre en conflit avec le geste de retour
            // (swipe depuis le bord) quand on arrive d'une autre page.
            if mode == .reel {
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
            } else {
                VStack(spacing: 6) {
                    Text("z₁").font(.caption).foregroundStyle(TrigPalette.radius)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack(spacing: 8) {
                        Text("θ₁").font(.caption).foregroundStyle(TrigPalette.radius).frame(width: 24)
                        Slider(value: $theta, in: 0...(2 * .pi)).tint(TrigPalette.radius)
                    }
                    HStack(spacing: 8) {
                        Text("r₁").font(.caption).foregroundStyle(TrigPalette.radius).frame(width: 24)
                        Slider(value: $r1, in: 0...2).tint(TrigPalette.radius)
                        Text(fmt(r1)).font(.system(.caption2, design: .monospaced)).frame(width: 34)
                    }

                    Text("z₂").font(.caption).foregroundStyle(TrigPalette.z2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)
                    HStack(spacing: 8) {
                        Text("θ₂").font(.caption).foregroundStyle(TrigPalette.z2).frame(width: 24)
                        Slider(value: $theta2, in: 0...(2 * .pi)).tint(TrigPalette.z2)
                    }
                    HStack(spacing: 8) {
                        Text("r₂").font(.caption).foregroundStyle(TrigPalette.z2).frame(width: 24)
                        Slider(value: $r2, in: 0...2).tint(TrigPalette.z2)
                        Text(fmt(r2)).font(.system(.caption2, design: .monospaced)).frame(width: 34)
                    }

                    Picker("", selection: $operation) {
                        ForEach(ComplexOp.allCases, id: \.self) { op in Text(op.rawValue).tag(op) }
                    }
                    .pickerStyle(.segmented)
                    .padding(.top, 4)
                }
                .frame(width: graphSize - 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text("z₁ = \(fmt(r1))∠\(piCoeff(theta)) = \(complexString(z1Real, z1Imag))")
                        .foregroundStyle(TrigPalette.radius)
                    Text("z₂ = \(fmt(r2))∠\(piCoeff(theta2)) = \(complexString(z2Real, z2Imag))")
                        .foregroundStyle(TrigPalette.z2)
                    Text("z₁ \(operation.rawValue) z₂ = \(fmt(combinedModulus))∠\(piCoeff(combinedArgument)) = \(complexString(combinedReal, combinedImag))")
                        .foregroundStyle(TrigPalette.result)
                        .fontWeight(.semibold)
                }
                .font(.system(.footnote, design: .monospaced))
                .frame(width: graphSize)
            }
        }
        .padding()
    }
}

#Preview {
    TrigoView()
        .preferredColorScheme(.dark)
}
