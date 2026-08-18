/// Interactive demonstration of the Pigeonhole Principle
import SwiftUI

struct PigeonholePrincipleView: View {

    /// Set in challenge mode so the run can grade the numbers the student picks.
    var onReading: ((ChallengeReading) -> Void)? = nil

    @State private var pigeons: Int = 13
    @State private var holes: Int = 10
    /// How many of the n items have been dropped in, scrubbed by the slider.
    @State private var placed = 0
    @State private var showFormula = false

    /// The fairest possible spread of the first `placed` items: even this one
    /// cannot keep every hole below the bound, which is the whole point.
    private var distribution: [Int] {
        var d = Array(repeating: 0, count: holes)
        for i in 0..<min(placed, pigeons) { d[i % holes] += 1 }
        return d
    }
    
    private var guaranteedMin: Int {
        Int(ceil(Double(pigeons) / Double(holes)))
    }

    /// The largest total that could still avoid the conclusion: if every hole
    /// stopped one short of `guaranteedMin`, this is all the room there is.
    private var capacityBelowBound: Int { holes * (guaranteedMin - 1) }

    private var currentMax: Int { distribution.max() ?? 0 }

    private var reading: PigeonholeReading {
        PigeonholeReading(items: pigeons, holes: holes, guaranteed: guaranteedMin)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VizHeader("Pigeonhole Principle",
                      subtitle: "⌈\(pigeons)/\(holes)⌉ = \(guaranteedMin): some hole must hold at least \(guaranteedMin)",
                      mono: true)

            VStack(spacing: 6) {
                VizSlider(label: "items  n",
                          intValue: Binding(get: { pigeons },
                                            set: { pigeons = $0; placed = min(placed, pigeons) }),
                          range: 1...25, accent: .orange)
                VizSlider(label: "holes  m", intValue: $holes, range: 1...12, accent: .orange)
            }

            // Le raisonnement, avant même de placer un pigeon : c'est lui qui
            // rend le principe certain plutôt que probable.
            argumentCard

            StepSlider(label: "items placed",
                       value: $placed,
                       range: 0...pigeons,
                       accent: .orange,
                       valueText: "\(min(placed, pigeons)) / \(pigeons)")

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8),
                                     count: holes <= 4 ? holes : (holes <= 9 ? 3 : 4)),
                      spacing: 8) {
                ForEach(0..<holes, id: \.self) { index in
                    holeCard(index: index)
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))

            if currentMax > 0 {
                HStack(spacing: 6) {
                    Image(systemName: currentMax >= guaranteedMin ? "checkmark.circle.fill" : "circle.dashed")
                        .foregroundStyle(currentMax >= guaranteedMin ? .green : .secondary)
                    Text(currentMax >= guaranteedMin
                         ? "Fullest hole holds \(currentMax): the bound is reached even by the fairest spread."
                         : "Fullest hole holds \(currentMax) so far.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color(.systemGroupedBackground))
        .onChange(of: reading, initial: true) { _, new in
            onReading?(.pigeonhole(new))
        }
    }

    /// Why the bound is a certainty and not a likelihood: try to keep every
    /// hole below it and you simply run out of room.
    private var argumentCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Why it cannot be avoided")
                .font(.subheadline.weight(.semibold))

            Text("Suppose every hole held at most \(guaranteedMin - 1).")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text("\(holes) × \(guaranteedMin - 1) = \(capacityBelowBound)  \(capacityBelowBound < pigeons ? "<" : "≥")  \(pigeons)")
                .font(.system(.callout, design: .monospaced).weight(.bold))
                .foregroundStyle(capacityBelowBound < pigeons ? .orange : .secondary)

            Text(capacityBelowBound < pigeons
                 ? "There is not enough room for all \(pigeons), so at least one hole must reach \(guaranteedMin). No assumption is made about how the items are spread: this is a proof, not a probability."
                 : "With so few items nothing is forced yet: any hole can stay at \(guaranteedMin - 1) or below.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.orange.opacity(0.10)))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.orange.opacity(0.3)))
    }

    private func holeCard(index: Int) -> some View {
        let count = distribution.indices.contains(index) ? distribution[index] : 0
        let isFull = count >= guaranteedMin
        
        // Items are stacked horizontally and capped: the count is the point,
        // and a tall stack of birds is what made this view need scrolling.
        return HStack(spacing: 5) {
            Text("\(index + 1)")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(.secondary)

            HStack(spacing: -3) {
                ForEach(0..<min(count, 3), id: \.self) { _ in
                    Image(systemName: "bird.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(isFull ? .orange : .blue)
                }
                if count == 0 {
                    Image(systemName: "tray")
                        .font(.system(size: 11))
                        .foregroundStyle(.gray.opacity(0.35))
                }
            }

            Spacer(minLength: 0)

            Text("\(count)")
                .font(.system(.subheadline, design: .rounded).bold())
                .foregroundStyle(isFull ? .orange : (count > 0 ? .blue : .secondary))
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 7)
        .frame(height: 32)
        .background(RoundedRectangle(cornerRadius: 9)
            .fill(isFull ? Color.orange.opacity(0.15) : Color.blue.opacity(0.06)))
        .overlay(RoundedRectangle(cornerRadius: 9)
            .strokeBorder(isFull ? Color.orange : Color.gray.opacity(0.2), lineWidth: isFull ? 1.5 : 1))
        .animation(.spring(duration: 0.4), value: count)
    }
    
}
 
#Preview {
    PigeonholePrincipleView()
}
