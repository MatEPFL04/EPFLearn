//
//  ProbabilityView.swift
//  EPFLearn
//
//  La loi de probabilité, rien d'autre : un diagramme en bâtons exact,
//  une sélection au tap, une mini-légende.
//

import SwiftUI

struct ProbabilityView: View {

    // MARK: Expérience

    enum Experiment: String, CaseIterable, Hashable {
        case coin, die, twoDice, cards

        var title: String {
            switch self {
            case .coin:    return "Pièce"
            case .die:     return "Dé"
            case .twoDice: return "2 dés"
            case .cards:   return "Couleurs"
            }
        }

        var outcomes: [Int] {
            switch self {
            case .coin:    return [0, 1]
            case .die:     return Array(1...6)
            case .twoDice: return Array(2...12)
            case .cards:   return [0, 1, 2, 3]
            }
        }

        var initial: Int {
            switch self {
            case .coin:    return 1
            case .die:     return 6
            case .twoDice: return 7
            case .cards:   return 1
            }
        }

        var tint: Color {
            switch self {
            case .coin:    return DMTheme.amber
            case .die:     return DMTheme.cyan
            case .twoDice: return DMTheme.violet
            case .cards:   return DMTheme.rose
            }
        }

        /// Étiquette sous le bâton.
        func label(_ v: Int) -> String {
            switch self {
            case .coin: return v == 1 ? "P" : "F"
            case .die, .twoDice: return "\(v)"
            case .cards:
                let suits = ["♠", "♥", "♦", "♣"]
                return suits.indices.contains(v) ? suits[v] : "—"
            }
        }

        /// Ce qui s'écrit dans P( … ).
        func expr(_ v: Int) -> String {
            switch self {
            case .twoDice: return "S = \(v)"
            case .die:     return "X = \(v)"
            default:       return label(v)
            }
        }

        func p(_ v: Int) -> Double {
            switch self {
            case .coin:    return 1.0 / 2.0
            case .die:     return 1.0 / 6.0
            case .twoDice: return Double(max(6 - abs(v - 7), 0)) / 36.0
            case .cards:   return 1.0 / 4.0
            }
        }

        func fraction(_ v: Int) -> String {
            switch self {
            case .coin:    return "1/2"
            case .die:     return "1/6"
            case .twoDice: return "\(max(6 - abs(v - 7), 0))/36"
            case .cards:   return "1/4"
            }
        }
    }

    // MARK: State

    @State private var experiment: Experiment = .twoDice
    @State private var picked = 7

    private var tint: Color { experiment.tint }

    /// `picked` peut encore appartenir à l'expérience précédente le temps d'un rendu.
    private var event: Int {
        experiment.outcomes.contains(picked) ? picked : experiment.initial
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                DMSegmented(selection: $experiment, options: Experiment.allCases,
                            label: { $0.title }, tint: tint)
                    .onChange(of: experiment) { _, new in picked = new.initial }

                DMCard(tint: tint) {
                    VStack(alignment: .leading, spacing: 14) {
                        readout
                        bars
                        legend
                    }
                }
            }
            .padding(20)
            .animation(.spring(response: 0.32, dampingFraction: 0.85), value: experiment)
            .animation(.spring(response: 0.28, dampingFraction: 0.8), value: picked)
        }
        .background(DMAurora(tint: tint, accent: DMTheme.indigo))
    }

    // MARK: P(·) = a/b = x %

    private var readout: some View {
        HStack(alignment: .firstTextBaseline, spacing: 7) {
            Text("P(\(experiment.expr(event)))")
                .font(.system(.headline, design: .rounded).weight(.heavy))
                .foregroundStyle(tint)

            Text("=")
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(.secondary)

            Text(experiment.fraction(event))
                .font(.system(.subheadline, design: .monospaced).weight(.heavy))
                .foregroundStyle(.primary)

            Text("=")
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(.secondary)

            Text(pct(experiment.p(event)))
                .font(.system(.subheadline, design: .monospaced).weight(.heavy))
                .foregroundStyle(DMTheme.mint)

            Spacer(minLength: 0)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .contentTransition(.numericText())
    }

    // MARK: Bâtons

    private var bars: some View {
        let outs = experiment.outcomes
        let peak = outs.map { experiment.p($0) }.max() ?? 1
        let height: CGFloat = 160
        let dense = outs.count > 8

        return HStack(alignment: .bottom, spacing: dense ? 3 : 8) {
            ForEach(outs, id: \.self) { v in
                let on = v == event
                VStack(spacing: 5) {
                    Spacer(minLength: 0)

                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(DMTheme.grad(on ? tint : tint.opacity(0.30)))
                        .frame(height: max(3, height * CGFloat(experiment.p(v) / peak)))

                    Text(experiment.label(v))
                        .font(.system(size: dense ? 10 : 12,
                                      weight: on ? .heavy : .medium, design: .rounded))
                        .foregroundStyle(on ? tint : .secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                .frame(maxWidth: .infinity)
                .frame(height: height + 20)
                .contentShape(Rectangle())
                .onTapGesture { picked = v }
            }
        }
    }

    // MARK: Mini-légende

    private var legend: some View {
        HStack(spacing: 10) {
            swatch(DMTheme.grad(tint), "P(\(experiment.expr(event)))")
            swatch(DMTheme.grad(tint.opacity(0.30)), "P(x)")

            Spacer(minLength: 0)

            Text("Σ = 1")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(DMTheme.mint)
        }
    }

    private func swatch(_ style: some ShapeStyle, _ text: String) -> some View {
        HStack(spacing: 4) {
            Capsule().fill(style).frame(width: 13, height: 6)
            Text(text)
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .lineLimit(1)
    }

    private func pct(_ v: Double) -> String {
        String(format: "%.1f %%", v * 100)
    }
}

#Preview {
    ProbabilityView()
}
