//
//  VennDiagramView.swift
//  EPFLearn
//
//

import SwiftUI

struct VennDiagramView: View {

    enum Region: String, CaseIterable, Identifiable {
        // 2 sets
        case a = "A", b = "B"
        case unionAB = "A ∪ B", interAB = "A ∩ B"
        case aMinusB = "A \\ B", bMinusA = "B \\ A"
        case symmAB = "A △ B", compA = "Aᶜ"
           // 3 sets
        case unionABC = "A ∪ B ∪ C", interABC = "A ∩ B ∩ C"
        case pairAB = "A ∩ B (among 3)"
        case exactlyOne = "Exactly one", none3 = "None"

        var id: String { rawValue }

        var caption: String {
            switch self {
            case .a, .b:
                return "The whole set. Drag to move, drag the knob to resize."
            case .unionAB:
                return "In A or B (union)"
            case .interAB:
                return "In both A and B."
            case .aMinusB:
                return "In A but not in B."
            case .bMinusA:
                return "In B but not in A."
            case .symmAB:
                return "In exactly one of the two (symmetric difference)."
            case .compA:
                return "All of Ω except A"
            case .unionABC:
                return "In at least one of the three."
            case .interABC:
                return "In all three at the same time."
            case .pairAB:
                return "In A and B, whether C is in it or not"
            case .exactlyOne:
                return "In exactly one of the three sets."
            case .none3:
                return "In none of the three: (A∪B∪C)ᶜ."
            }
        }

    }

    @State private var threeSets = false
    @State private var region: Region = .unionAB
    @State private var cA = CGPoint(x: 125, y: 150)
    @State private var cB = CGPoint(x: 195, y: 150)
    @State private var cC = CGPoint(x: 160, y: 205)
    @State private var rA: CGFloat = 72
    @State private var rB: CGFloat = 72
    @State private var rC: CGFloat = 72

    let board: CGFloat = 320
    let fill = Color.blue.opacity(0.45)

    private var regions: [Region] {
        threeSets
        ? [.unionABC, .interABC, .pairAB, .exactlyOne, .none3]
        : [.a, .b, .unionAB, .interAB, .aMinusB, .bMinusA, .symmAB, .compA]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                Toggle("Third circle on the diagram", isOn: $threeSets)
                    .onChange(of: threeSets) { _, on in
                        region = on ? .unionABC : .unionAB
                    }

                ZStack {
                    Canvas { ctx, size in draw(&ctx, size) }

                    DraggableDisc(board: board, knobAngle: .pi, center: $cA, radius: $rA)
                    DraggableDisc(board: board, knobAngle: 0, center: $cB, radius: $rB)
                    if threeSets {
                        DraggableDisc(board: board, knobAngle: .pi / 2, center: $cC, radius: $rC)
                    }
                }
                .frame(width: board, height: board)
                .coordinateSpace(name: "venn")
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))

                Text(region.caption)
                    .font(.footnote).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: board, minHeight: 40)

                Picker("Region", selection: $region) {
                    ForEach(regions) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.menu)
            }
            .padding()
        }
    }

    private func disc(_ c: CGPoint, _ r: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: 2*r, height: 2*r))
    }

    private func draw(_ ctx: inout GraphicsContext, _ size: CGSize) {
        let a = disc(cA, rA), b = disc(cB, rB), c = disc(cC, rC)
        let universe = Path(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        // --- Remplissage de la région choisie (opacité uniforme) ---
        switch region {
        case .a:
            ctx.fill(a, with: .color(fill))
        case .b:
            ctx.fill(b, with: .color(fill))
        case .unionAB:
            var u = Path(); u.addPath(a); u.addPath(b)
            ctx.fill(u, with: .color(fill))                       // union = 1 seul remplissage
        case .interAB:
            ctx.drawLayer { l in l.clip(to: a); l.fill(b, with: .color(fill)) }
        case .aMinusB:
            ctx.drawLayer { l in l.clip(to: b, options: .inverse); l.fill(a, with: .color(fill)) }
        case .bMinusA:
            ctx.drawLayer { l in l.clip(to: a, options: .inverse); l.fill(b, with: .color(fill)) }
        case .symmAB:
            ctx.drawLayer { l in l.clip(to: b, options: .inverse); l.fill(a, with: .color(fill)) }
            ctx.drawLayer { l in l.clip(to: a, options: .inverse); l.fill(b, with: .color(fill)) }
        case .compA:
            ctx.drawLayer { l in l.clip(to: a, options: .inverse); l.fill(universe, with: .color(fill)) }
        case .unionABC:
            var u = Path(); u.addPath(a); u.addPath(b); u.addPath(c)
            ctx.fill(u, with: .color(fill))
        case .interABC:
            ctx.drawLayer { l in l.clip(to: a); l.clip(to: b); l.fill(c, with: .color(fill)) }
        case .pairAB:
            ctx.drawLayer { l in l.clip(to: a); l.fill(b, with: .color(fill)) }
        case .exactlyOne:
            ctx.drawLayer { l in l.clip(to: b, options: .inverse); l.clip(to: c, options: .inverse); l.fill(a, with: .color(fill)) }
            ctx.drawLayer { l in l.clip(to: a, options: .inverse); l.clip(to: c, options: .inverse); l.fill(b, with: .color(fill)) }
            ctx.drawLayer { l in l.clip(to: a, options: .inverse); l.clip(to: b, options: .inverse); l.fill(c, with: .color(fill)) }
        case .none3:
            ctx.drawLayer { l in
                l.clip(to: a, options: .inverse)
                l.clip(to: b, options: .inverse)
                l.clip(to: c, options: .inverse)
                l.fill(universe, with: .color(fill))
            }
        }

        // --- Contours ---
        ctx.stroke(universe, with: .color(.gray.opacity(0.5)), lineWidth: 1)
        ctx.stroke(a, with: .color(.blue), lineWidth: 2)
        ctx.stroke(b, with: .color(.blue), lineWidth: 2)
        if threeSets { ctx.stroke(c, with: .color(.blue), lineWidth: 2) }

        // --- Poignées (points centraux) ---
        for center in (threeSets ? [cA, cB, cC] : [cA, cB]) {
            ctx.fill(Path(ellipseIn: CGRect(x: center.x - 3, y: center.y - 3, width: 6, height: 6)),
                     with: .color(.blue.opacity(0.7)))
        }

        // --- Étiquettes ---
        ctx.draw(Text("A").font(.headline).foregroundColor(.blue),
                 at: CGPoint(x: cA.x - rA * 0.55, y: cA.y - rA * 0.55))
        ctx.draw(Text("B").font(.headline).foregroundColor(.blue),
                 at: CGPoint(x: cB.x + rB * 0.55, y: cB.y - rB * 0.55))
        if threeSets {
            ctx.draw(Text("C").font(.headline).foregroundColor(.blue),
                     at: CGPoint(x: cC.x, y: cC.y + rC * 0.6))
        }
        ctx.draw(Text("Ω").font(.caption).foregroundColor(.gray),
                 at: CGPoint(x: size.width - 22, y: 22))
    }
}

// Cercle transparent déplaçable au doigt, borné au plateau,
// avec une poignée sur le bord pour changer son rayon.
struct DraggableDisc: View {
    let board: CGFloat
    let knobAngle: Double
    @Binding var center: CGPoint
    @Binding var radius: CGFloat
    @State private var start: CGPoint? = nil

    private var knob: CGPoint {
        CGPoint(x: center.x + radius * cos(knobAngle),
                y: center.y + radius * sin(knobAngle))
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.001))
                .frame(width: radius * 2, height: radius * 2)
                .contentShape(Circle())
                .position(center)
                .gesture(
                    DragGesture()
                        .onChanged { v in
                            let base = start ?? center
                            if start == nil { start = center }
                            center = CGPoint(x: base.x + v.translation.width,
                                             y: base.y + v.translation.height)
                            clamp()
                        }
                        .onEnded { _ in start = nil }
                )

            Circle()
                .fill(Color.blue)
                .overlay(Circle().strokeBorder(.white.opacity(0.7), lineWidth: 1.5))
                .frame(width: 10, height: 10)
                .position(knob)
                .gesture(
                    DragGesture(coordinateSpace: .named("venn"))
                        .onChanged { v in
                            let d = hypot(v.location.x - center.x, v.location.y - center.y)
                            radius = min(max(d, 24), board / 2 - 4)
                            clamp()
                        }
                )
        }
    }

    private func clamp() {
        center.x = min(max(center.x, radius), board - radius)
        center.y = min(max(center.y, radius), board - radius)
    }
}

#Preview { VennDiagramView() }
