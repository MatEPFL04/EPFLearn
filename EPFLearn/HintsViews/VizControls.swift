//
//  VizControls.swift
//  EPFLearn
//
//  The controls every visualization is driven by, in one place.
//
//  The views used to mix three idioms: play/pause transports (graphs, sorting),
//  chevron steppers (programming) and drag-to-edit strips. A student switching
//  subjects had to re-learn the control each time, and an animation that plays
//  by itself moves whether or not you are ready for the next frame. Everything
//  now scrubs: `StepSlider` for a frame index, `VizSlider` for a parameter,
//  both drawn as the same one-line strip.
//

import SwiftUI

// MARK: - Header

/// The title strip every visualization opens with. Titles used to be `.headline`
/// in Analysis, `.title3.bold()` in Programming and `.title2.bold()` in Discrete
/// Maths, so flipping between subjects moved the first line of the screen.
///
/// `subtitle` carries either a short sentence (default) or the formula the view
/// is about (`mono: true`).
struct VizHeader<Trailing: View>: View {
    let title: String
    var subtitle: String? = nil
    var mono: Bool = false
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.title3.bold())
                if let subtitle {
                    Text(subtitle)
                        .font(mono ? .system(size: 11.5, design: .monospaced) : .footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 0)
            trailing
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension VizHeader where Trailing == EmptyView {
    init(_ title: String, subtitle: String? = nil, mono: Bool = false) {
        self.init(title: title, subtitle: subtitle, mono: mono) { EmptyView() }
    }
}

// MARK: - Shared row chrome

/// Label, control and live value on one line - a stepped visualization has to
/// leave room for the thing being stepped, so the control strip stays 32pt
/// high and only grows when it carries a caption.
private struct VizControlRow<Control: View>: View {
    let label: String
    let valueText: String
    let accent: Color
    let caption: String?
    @ViewBuilder var control: Control

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 8) {
                Text(label.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.7)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .frame(maxWidth: 96, alignment: .leading)
                    .fixedSize(horizontal: true, vertical: false)

                control

                Text(valueText)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(accent)
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
            if let caption {
                Text(caption)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12)
            .fill(Color(.secondarySystemGroupedBackground)))
    }
}

// MARK: - Integer slider (frame index, loop bound, bit offset, …)

struct StepSlider: View {

    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    var accent: Color = .cyan
    /// Overrides the readout (e.g. "3 / 12"); defaults to the raw value.
    var valueText: String? = nil
    /// One short line about the position currently shown.
    var caption: String? = nil
    var onEdit: () -> Void = {}

    // A Slider needs a non-empty range; a one-value range still has to render.
    private var lo: Double { Double(range.lowerBound) }
    private var hi: Double { Double(max(range.upperBound, range.lowerBound + 1)) }
    private var degenerate: Bool { range.upperBound <= range.lowerBound }

    private var proxy: Binding<Double> {
        Binding(
            get: { Double(value) },
            set: { new in
                let next = min(max(Int(new.rounded()), range.lowerBound), range.upperBound)
                if next != value {
                    value = next
                    onEdit()
                }
            }
        )
    }

    var body: some View {
        VizControlRow(label: label,
                      valueText: valueText ?? "\(value)",
                      accent: accent,
                      caption: caption) {
            HStack(spacing: 4) {
                arrow("chevron.left", enabled: value > range.lowerBound) { move(to: value - 1) }
                Slider(value: proxy, in: lo...hi, step: 1)
                    .tint(accent)
                    .disabled(degenerate)
                    .opacity(degenerate ? 0.4 : 1)
                arrow("chevron.right", enabled: value < range.upperBound) { move(to: value + 1) }
            }
        }
    }

    private func move(to target: Int) {
        let next = min(max(target, range.lowerBound), range.upperBound)
        guard next != value else { return }
        withAnimation(.spring(duration: 0.22)) { value = next }
        onEdit()
    }

    private func arrow(_ symbol: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 9, weight: .black))
                .foregroundStyle(enabled ? accent : .secondary.opacity(0.35))
                .frame(width: 22, height: 22)
                .background(RoundedRectangle(cornerRadius: 6).fill(accent.opacity(enabled ? 0.14 : 0.05)))
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

extension StepSlider {
    /// Frame scrubber: 0 … total, read out as "step / total".
    init(step: Binding<Int>, total: Int, accent: Color = .cyan,
         label: String = "Step", caption: String? = nil) {
        self.init(label: label,
                  value: step,
                  range: 0...max(total, 0),
                  accent: accent,
                  valueText: "\(step.wrappedValue) / \(max(total, 0))",
                  caption: caption)
    }
}

// MARK: - Continuous slider (a parameter of the plot)

struct VizSlider: View {

    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double? = nil
    var accent: Color = .cyan
    /// Overrides the readout; defaults to `value` formatted with `format`.
    var valueText: String? = nil
    var format: String = "%.2f"
    var caption: String? = nil
    var onEditingChanged: (Bool) -> Void = { _ in }

    /// A one-point range would make the track meaningless (and the thumb
    /// position undefined), so it is widened and the control disabled.
    private var degenerate: Bool { range.upperBound <= range.lowerBound }
    private var safeRange: ClosedRange<Double> {
        degenerate ? range.lowerBound...(range.lowerBound + 1) : range
    }

    var body: some View {
        VizControlRow(label: label,
                      valueText: valueText ?? String(format: format, value),
                      accent: accent,
                      caption: caption) {
            Group {
                if let step {
                    Slider(value: $value, in: safeRange, step: step,
                           onEditingChanged: onEditingChanged)
                } else {
                    Slider(value: $value, in: safeRange,
                           onEditingChanged: onEditingChanged)
                }
            }
            .tint(accent)
            .disabled(degenerate)
            .opacity(degenerate ? 0.4 : 1)
        }
    }
}

extension VizSlider {
    /// Integer-valued parameter that the caller keeps as an `Int`.
    init(label: String, intValue: Binding<Int>, range: ClosedRange<Int>,
         accent: Color = .cyan, caption: String? = nil,
         onEdit: @escaping () -> Void = {}) {
        self.init(label: label,
                  value: Binding(
                    get: { Double(intValue.wrappedValue) },
                    set: { new in
                        let next = min(max(Int(new.rounded()), range.lowerBound), range.upperBound)
                        if next != intValue.wrappedValue {
                            intValue.wrappedValue = next
                            onEdit()
                        }
                    }),
                  range: Double(range.lowerBound)...Double(max(range.upperBound, range.lowerBound + 1)),
                  step: 1,
                  accent: accent,
                  valueText: "\(intValue.wrappedValue)",
                  caption: caption)
    }
}

#Preview {
    VStack(spacing: 12) {
        StepSlider(step: .constant(3), total: 9, accent: .green, caption: "pass 3 of the loop body")
        StepSlider(label: "k", value: .constant(4), range: 0...7, accent: .orange)
        VizSlider(label: "x", value: .constant(1.5), range: 0...3, accent: .cyan)
        VizSlider(label: "vertices", intValue: .constant(7), range: 2...12)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
