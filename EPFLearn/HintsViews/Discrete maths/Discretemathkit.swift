//
//  DiscreteMathKit.swift
//  EPFLearn
//
//  Shared design language for the Discrete Maths visualisations.
//  Import once — every discrete-maths view is built on these primitives.
//

import SwiftUI

// MARK: - Palette

enum DMTheme {
    static let violet = Color(red: 0.55, green: 0.36, blue: 0.96)
    static let indigo = Color(red: 0.36, green: 0.42, blue: 0.98)
    static let cyan   = Color(red: 0.14, green: 0.72, blue: 0.94)
    static let mint   = Color(red: 0.10, green: 0.80, blue: 0.63)
    static let amber  = Color(red: 0.99, green: 0.68, blue: 0.15)
    static let rose   = Color(red: 0.98, green: 0.33, blue: 0.52)

    /// Colours used for the interchangeable "items" (balls, tokens, pigeons…).
    static let tokens: [Color] = [rose, amber, mint, cyan, indigo, violet]

    static func grad(_ c: Color) -> LinearGradient {
        LinearGradient(colors: [c, c.opacity(0.55)],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static func grad(_ a: Color, _ b: Color) -> LinearGradient {
        LinearGradient(colors: [a, b], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    /// A, B, C, … for labelling items.
    static func letter(_ i: Int) -> String {
        String(UnicodeScalar(UInt8(65 + (i % 26))))
    }

    static func token(_ i: Int) -> Color { tokens[i % tokens.count] }
}

// MARK: - Background

/// Soft animated aurora behind every view. Cheap (two blurred circles) but gives depth.
struct DMAurora: View {
    var tint: Color = DMTheme.violet
    var accent: Color = DMTheme.cyan
    @State private var drift: CGFloat = 0

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)

            Circle()
                .fill(tint.opacity(0.30))
                .frame(width: 360, height: 360)
                .blur(radius: 100)
                .offset(x: -130, y: -220 + drift * 40)

            Circle()
                .fill(accent.opacity(0.22))
                .frame(width: 320, height: 320)
                .blur(radius: 110)
                .offset(x: 150, y: 120 - drift * 50)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) {
                drift = 1
            }
        }
    }
}

// MARK: - Card

struct DMCard<Content: View>: View {
    var tint: Color
    var padding: CGFloat
    private let content: Content

    init(tint: Color = DMTheme.violet,
         padding: CGFloat = 16,
         @ViewBuilder content: () -> Content) {
        self.tint = tint
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(
                        LinearGradient(colors: [tint.opacity(0.45), tint.opacity(0.06)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
            )
            .shadow(color: tint.opacity(0.15), radius: 18, x: 0, y: 8)
    }
}

// MARK: - Header

struct DMHero: View {
    let title: String
    let subtitle: String
    let symbol: String
    let tint: Color

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(DMTheme.grad(tint))
                )
                .shadow(color: tint.opacity(0.45), radius: 12, y: 6)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(.title2, design: .rounded).bold())
                    .foregroundStyle(DMTheme.grad(tint, tint.opacity(0.7)))
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }
}

struct DMSectionTitle: View {
    let text: String
    var symbol: String? = nil
    var tint: Color = .secondary

    var body: some View {
        HStack(spacing: 6) {
            if let symbol {
                Image(systemName: symbol).font(.caption.bold()).foregroundStyle(tint)
            }
            Text(text.uppercased())
                .font(.caption.weight(.bold))
                .kerning(0.8)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Big animated number

struct DMBigNumber: View {
    let value: Int
    let caption: String
    let tint: Color
    var footnote: String? = nil

    var body: some View {
        VStack(spacing: 2) {
            Text(caption)
                .font(.system(.subheadline, design: .monospaced).weight(.medium))
                .foregroundStyle(.secondary)
            Text("\(value)")
                .font(.system(size: 52, weight: .heavy, design: .rounded))
                .foregroundStyle(DMTheme.grad(tint))
                .contentTransition(.numericText())
                .shadow(color: tint.opacity(0.35), radius: 14, y: 6)
            if let footnote {
                Text(footnote)
                    .font(.caption2.monospaced())
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(tint.opacity(0.10))
        )
    }
}

// MARK: - Segmented control

struct DMSegmented<T: Hashable>: View {
    @Binding var selection: T
    let options: [T]
    let label: (T) -> String
    var tint: Color = DMTheme.violet

    @Namespace private var ns

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { option in
                let isOn = option == selection
                Text(label(option))
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(isOn ? Color.white : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background {
                        if isOn {
                            Capsule()
                                .fill(DMTheme.grad(tint))
                                .matchedGeometryEffect(id: "dm.segment", in: ns)
                                .shadow(color: tint.opacity(0.40), radius: 8, y: 3)
                        }
                    }
                    .contentShape(Capsule())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
                            selection = option
                        }
                    }
            }
        }
        .padding(4)
        .background(Capsule().fill(.ultraThinMaterial))
        .overlay(Capsule().strokeBorder(Color.primary.opacity(0.07)))
    }
}

// MARK: - Stepper

struct DMStepper: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    var tint: Color = DMTheme.violet

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 0) {
                button("minus", enabled: value > range.lowerBound) {
                    value = max(range.lowerBound, value - 1)
                }
                Text("\(value)")
                    .font(.system(.title3, design: .rounded).weight(.heavy))
                    .foregroundStyle(tint)
                    .frame(maxWidth: .infinity)
                    .contentTransition(.numericText())
                button("plus", enabled: value < range.upperBound) {
                    value = min(range.upperBound, value + 1)
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(tint.opacity(0.25))
            )
        }
    }

    private func button(_ symbol: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) { action() }
        } label: {
            Image(systemName: symbol)
                .font(.footnote.weight(.black))
                .foregroundStyle(enabled ? tint : Color.secondary.opacity(0.4))
                .frame(width: 32, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(tint.opacity(enabled ? 0.14 : 0.05))
                )
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

// MARK: - Token (an interchangeable item)

struct DMToken: View {
    let index: Int
    var size: CGFloat = 44
    var dimmed: Bool = false
    var showsLetter: Bool = true

    private var colour: Color { DMTheme.token(index) }

    var body: some View {
        Circle()
            .fill(DMTheme.grad(colour))
            .frame(width: size, height: size)
            .overlay(
                Circle().strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
            )
            .overlay {
                if showsLetter {
                    Text(DMTheme.letter(index))
                        .font(.system(size: size * 0.46, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
            .shadow(color: colour.opacity(dimmed ? 0 : 0.45), radius: 6, y: 3)
            .opacity(dimmed ? 0.22 : 1)
            .saturation(dimmed ? 0.2 : 1)
    }
}

// MARK: - Formula chip

struct DMFormula: View {
    let text: String
    var tint: Color = DMTheme.violet
    var emphasised: Bool = false

    var body: some View {
        Text(text)
            .font(.system(emphasised ? .body : .callout, design: .monospaced)
                .weight(emphasised ? .bold : .regular))
            .foregroundStyle(emphasised ? tint : .primary)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(tint.opacity(emphasised ? 0.16 : 0.07))
            )
    }
}

// MARK: - Callout banner

struct DMBanner: View {
    let text: String
    let symbol: String
    let tint: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.headline)
                .foregroundStyle(tint)
            Text(text)
                .font(.footnote.weight(.medium))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(tint.opacity(0.14))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(tint.opacity(0.35))
        )
    }
}

// MARK: - Geometry helpers

/// Polyline through normalised points (0…1, origin top-left).
struct DMPolyline: Shape {
    var points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var p = Path()
        guard let first = points.first else { return p }
        p.move(to: map(first, rect))
        for pt in points.dropFirst() { p.addLine(to: map(pt, rect)) }
        return p
    }

    private func map(_ pt: CGPoint, _ rect: CGRect) -> CGPoint {
        CGPoint(x: rect.minX + pt.x * rect.width, y: rect.minY + pt.y * rect.height)
    }
}

/// Same polyline, closed down to the baseline — used for the gradient area fill.
struct DMAreaShape: Shape {
    var points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var p = Path()
        guard let first = points.first, let last = points.last else { return p }
        func map(_ pt: CGPoint) -> CGPoint {
            CGPoint(x: rect.minX + pt.x * rect.width, y: rect.minY + pt.y * rect.height)
        }
        p.move(to: CGPoint(x: map(first).x, y: rect.maxY))
        p.addLine(to: map(first))
        for pt in points.dropFirst() { p.addLine(to: map(pt)) }
        p.addLine(to: CGPoint(x: map(last).x, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

// MARK: - Maths helpers shared by the views

enum DMMath {
    static func factorial(_ n: Int) -> Int {
        guard n > 1 else { return 1 }
        return (1...n).reduce(1, *)
    }

    static func permutations(_ n: Int, _ k: Int) -> Int {
        guard k >= 0, k <= n else { return 0 }
        guard k > 0 else { return 1 }
        return ((n - k + 1)...n).reduce(1, *)
    }

    static func binomial(_ n: Int, _ k: Int) -> Int {
        guard k >= 0, k <= n else { return 0 }
        let k = min(k, n - k)
        var result = 1
        for i in 0..<k { result = result * (n - i) / (i + 1) }
        return result
    }

    static func subscriptDigits(_ n: Int) -> String {
        let table = ["₀", "₁", "₂", "₃", "₄", "₅", "₆", "₇", "₈", "₉"]
        return String(n).compactMap { Int(String($0)).map { table[$0] } }.joined()
    }
}
