//
//  ProbabilityView.swift
//  EPFLearn
//
//  La loi de probabilité, rien d'autre : un diagramme en bâtons exact.
//  Un événement se construit en tapant PLUSIEURS bâtons : sa probabilité est
//  la somme de celles des issues qu'il contient, et pour deux dés on voit
//  aussi les couples ordonnés qui produisent chaque somme.
//
//  Habillage aligné sur les vues de tri : Picker natif, panneau
//  secondarySystemBackground, couleurs système pleines.
//

import SwiftUI

struct ProbabilityView: View {

    // MARK: Expérience

    enum Experiment: String, CaseIterable, Hashable {
        case coin = "Coin", die = "Die", twoDice = "2 dice"

        var outcomes: [Int] {
            switch self {
            case .coin:    return [0, 1]
            case .die:     return Array(1...6)
            case .twoDice: return Array(2...12)
            }
        }

        var initial: Int {
            switch self {
            case .coin:    return 1
            case .die:     return 6
            case .twoDice: return 7
            }
        }

        /// Nombre de cas élémentaires équiprobables.
        var denominator: Int {
            switch self {
            case .coin:    return 2
            case .die:     return 6
            case .twoDice: return 36
            }
        }

        /// Combien de cas élémentaires produisent cette issue.
        func weight(_ v: Int) -> Int {
            self == .twoDice ? max(6 - abs(v - 7), 0) : 1
        }

        func label(_ v: Int) -> String {
            switch self {
            case .coin: return v == 1 ? "H" : "T"
            case .die, .twoDice: return "\(v)"
            }
        }

        func expr(_ v: Int) -> String {
            switch self {
            case .twoDice: return "S = \(v)"
            case .die:     return "X = \(v)"
            default:       return label(v)
            }
        }

        func p(_ v: Int) -> Double { Double(weight(v)) / Double(denominator) }

        /// Les couples ordonnés (dé 1, dé 2) derrière une somme.
        func orderedPairs(_ v: Int) -> [(Int, Int)] {
            guard self == .twoDice else { return [] }
            var out: [(Int, Int)] = []
            for i in 1...6 where (1...6).contains(v - i) { out.append((i, v - i)) }
            return out
        }
    }

    // MARK: State

    @State private var experiment: Experiment = .twoDice
    @State private var selected: Set<Int> = [7]

    private var event: [Int] {
        let valid = selected.filter { experiment.outcomes.contains($0) }.sorted()
        return valid.isEmpty ? [experiment.initial] : valid
    }

    private var eventWeight: Int { event.reduce(0) { $0 + experiment.weight($1) } }

    private var eventName: String {
        if event.count == 1 { return experiment.expr(event[0]) }
        let items = event.map { experiment.label($0) }.joined(separator: ", ")
        return "\(experiment == .twoDice ? "S" : "X") ∈ {\(items)}"
    }

    // MARK: Body

    var body: some View {
        VStack(spacing: 12) {
            VizHeader("Probability", subtitle: "Equally likely outcomes; an event is a set of them.")

            readout

            bars
                .frame(height: 150)
                .padding(.vertical, 8)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(.gray.opacity(0.2)))

            if experiment == .twoDice { pairsRow }

            Text("Tap several bars to build an event: outcomes cannot happen together, so their probabilities add.")
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Under the bars, like every other picker in the app.
            Picker("Experiment", selection: $experiment) {
                ForEach(Experiment.allCases, id: \.self) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .onChange(of: experiment) { selected = [experiment.initial] }

            Spacer(minLength: 0)
        }
        .padding(10)
        .animation(.easeInOut(duration: 0.2), value: selected)
        .animation(.easeInOut(duration: 0.2), value: experiment)
    }

    // MARK: P(·) = a/b

    private var readout: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text("P(\(eventName))")
                .font(.system(.subheadline, design: .monospaced).bold())
                .foregroundStyle(.blue)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            if event.count > 1 {
                Text("= (" + event.map { "\(experiment.weight($0))" }.joined(separator: "+") + ")/\(experiment.denominator)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }

            Text("= \(eventWeight)/\(experiment.denominator)")
                .font(.system(.subheadline, design: .monospaced).bold())

            if let simplified = simplify(eventWeight, experiment.denominator) {
                Text("= \(simplified)")
                    .font(.system(.subheadline, design: .monospaced).bold())
                    .foregroundStyle(.orange)
            }

            Spacer(minLength: 0)
        }
        .contentTransition(.numericText())
    }

    // MARK: Bâtons

    private var bars: some View {
        let outs = experiment.outcomes
        let peak = outs.map { experiment.p($0) }.max() ?? 1
        let dense = outs.count > 8

        return GeometryReader { geo in
            let plotH = geo.size.height - 30
            HStack(alignment: .bottom, spacing: dense ? 4 : 8) {
                ForEach(outs, id: \.self) { v in
                    let on = event.contains(v)
                    VStack(spacing: 4) {
                        Spacer(minLength: 0)

                        if experiment == .twoDice {
                            Text("\(experiment.weight(v))")
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundStyle(on ? .orange : .secondary)
                        }

                        RoundedRectangle(cornerRadius: 3)
                            .fill(on ? Color.orange : Color.blue)
                            .frame(height: max(3, plotH * CGFloat(experiment.p(v) / peak)))

                        Text(experiment.label(v))
                            .font(.system(size: dense ? 10 : 12, design: .monospaced))
                            .foregroundStyle(on ? .orange : .secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selected.contains(v) {
                            if selected.count > 1 { selected.remove(v) }
                        } else {
                            selected.insert(v)
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
        }
    }

    // MARK: Couples ordonnés

    private var pairsRow: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(event.count == 1
                 ? "\(experiment.weight(event[0])) ordered pair(s) give \(event[0]):"
                 : "ordered pairs behind the selection:")
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(event, id: \.self) { v in
                        ForEach(Array(experiment.orderedPairs(v).enumerated()), id: \.offset) { _, pair in
                            Text("(\(pair.0),\(pair.1))")
                                .font(.system(size: 11, design: .monospaced))
                                .padding(.vertical, 3).padding(.horizontal, 6)
                                .background(RoundedRectangle(cornerRadius: 5).fill(Color.orange.opacity(0.15)))
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func simplify(_ a: Int, _ b: Int) -> String? {
        guard a > 0, b > 0 else { return nil }
        var x = a, y = b
        while y != 0 { (x, y) = (y, x % y) }
        guard x > 1 else { return nil }
        return "\(a / x)/\(b / x)"
    }
}

#Preview {
    ProbabilityView()
}
