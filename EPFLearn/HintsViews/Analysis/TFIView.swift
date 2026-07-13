//
//  TFIView.swift
//  EPFLearn
//
//  Created by Mat on 06.04.2026.
//
//  Idée pédagogique : f et g coïncident jusqu'à un point de rupture, puis
//  divergent. Tant que x reste avant ce point, F(x) = ∫₀ˣ f et G(x) = ∫₀ˣ g
//  restent rigoureusement égales — parce que f = g sur toute la zone
//  parcourue. Dès que x dépasse le point de rupture, f ≠ g localement, et
//  F(x) et G(x) se mettent à diverger. C'est la contraposée du théorème :
//  F = G partout ⟺ f = g partout (puisque F' = f et G' = g).

import SwiftUI

// MARK: - Aire sous la courbe entre deux bornes mathématiques

struct AreaUnderCurve: Shape {
    var from: Double
    var to:   Double
    let f:    @Sendable (Double) -> Double
    let scale: Double

    func path(in rect: CGRect) -> Path {
        let cs = MathCoordinateSpace(rect: rect, scale: scale)
        var path = Path()
        let lo = min(from, to)
        let hi = max(from, to)
        guard hi > lo else { return path }

        let steps = max(Int((hi - lo) * scale / 2), 2)
        path.move(to: cs.toScreen(x: lo, y: 0))
        for i in 0...steps {
            let x = lo + (hi - lo) * Double(i) / Double(steps)
            path.addLine(to: cs.toScreen(x: x, y: f(x)))
        }
        path.addLine(to: cs.toScreen(x: hi, y: 0))
        path.closeSubpath()
        return path
    }
}

// MARK: - Modèle : f et g coïncident jusqu'à splitPoint, puis divergent

private struct TFICase: Identifiable {
    let id: Int
    let chip: String
    let shared: (Double) -> Double
    let splitPoint: Double
    let bumpAmplitude: Double
    let bumpFreq: Double

    // g suit toujours "shared". f suit "shared" avant splitPoint, puis
    // ajoute un terme qui vaut 0 pile à splitPoint (continuité garantie).
    func f(_ x: Double) -> Double {
        guard x > splitPoint else { return shared(x) }
        return shared(x) + bumpAmplitude * sin(bumpFreq * (x - splitPoint))
    }
    func g(_ x: Double) -> Double { shared(x) }
}

private let tfiCases: [TFICase] = [
    TFICase(id: 0, chip: "sin(x)", shared: { sin($0) }, splitPoint: 0.0, bumpAmplitude: 0.4, bumpFreq: 3),
    TFICase(id: 1, chip: "x",      shared: { $0 },      splitPoint: 0.5, bumpAmplitude: 0.3, bumpFreq: 4),
    TFICase(id: 2, chip: "cos(x)", shared: { cos($0) }, splitPoint: -0.4, bumpAmplitude: -0.35, bumpFreq: 2.5),
]

// MARK: - TFIView

struct TFIView: View {

    @State private var selectedCase: Int = 0
    @State private var target: Double = -1.2

    let graphSize: CGFloat = 300
    let scale: Double = 90.0

    private var current: TFICase { tfiCases[selectedCase] }

    // Intégrale numérique (trapèzes) — évite les pièges de signe des
    // primitives par morceaux, et reste exacte au pixel près pour l'affichage.
    func integral(of fn: (Double) -> Double, from a: Double, to b: Double, steps: Int = 400) -> Double {
        guard b != a else { return 0 }
        let lo = min(a, b), hi = max(a, b)
        let dx = (hi - lo) / Double(steps)
        var sum = 0.0
        var yPrev = fn(lo)
        for i in 1...steps {
            let x = lo + dx * Double(i)
            let y = fn(x)
            sum += (yPrev + y) / 2 * dx
            yPrev = y
        }
        return b >= a ? sum : -sum
    }

    var F: Double { integral(of: current.f, from: 0, to: target) }
    var G: Double { integral(of: current.g, from: 0, to: target) }
    var areEqual: Bool { abs(F - G) < 0.01 }

    var cs: MathCoordinateSpace { MathCoordinateSpace(size: graphSize, scale: scale) }

    var body: some View {
        VStack(spacing: 14) {

            Text("F(x) = ∫₀ˣ f  vs  G(x) = ∫₀ˣ g")
                .font(.caption)
                .foregroundStyle(.secondary)

            Picker("Function pair", selection: $selectedCase) {
                ForEach(tfiCases) { c in
                    Text(c.chip).tag(c.id)
                }
            }
            .pickerStyle(.menu)
            .frame(width: graphSize)

            ZStack {
                GridDrawing(step: 10)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal).stroke(Color.blue.opacity(0.6), lineWidth: 1)
                AxisDrawing(axis: .vertical).stroke(Color.blue.opacity(0.6), lineWidth: 1)

                // Aires sous f et g, de 0 à target — se superposent
                // parfaitement tant que target reste avant le point de rupture.
                AreaUnderCurve(from: 0, to: target, f: current.g, scale: scale)
                    .fill(Color.blue.opacity(0.25))
                AreaUnderCurve(from: 0, to: target, f: current.f, scale: scale)
                    .fill(Color.red.opacity(0.25))

                FunctionDrawing(f: current.g, integrF: { _ in 0 }, scale: scale)
                    .stroke(Color.blue, lineWidth: 2)
                FunctionDrawing(f: current.f, integrF: { _ in 0 }, scale: scale)
                    .stroke(Color.red, lineWidth: 1.5)

                // Point de rupture : simple repère de ligne, pas de fond coloré
                // (un rectangle semi-transparent se mélangeait aux aires rouge/bleu
                // et donnait une teinte orange trouble).
                Path { p in
                    let screenX = cs.toScreen(x: current.splitPoint, y: 0).x
                    p.move(to: CGPoint(x: screenX, y: 0))
                    p.addLine(to: CGPoint(x: screenX, y: graphSize))
                }
                .stroke(Color.secondary.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [2, 3]))

                // Curseur x
                Path { p in
                    let screenX = cs.toScreen(x: target, y: 0).x
                    p.move(to: CGPoint(x: screenX, y: 0))
                    p.addLine(to: CGPoint(x: screenX, y: graphSize))
                }
                .stroke(Color.primary.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
            }
            .frame(width: graphSize, height: graphSize)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Rectangle().fill(Color.red).frame(width: 16, height: 3)
                        Text("f(x)").font(.caption2).foregroundStyle(.red)
                    }
                    HStack(spacing: 6) {
                        Rectangle().fill(Color.blue).frame(width: 16, height: 3)
                        Text("g(x)").font(.caption2).foregroundStyle(.blue)
                    }
                }
                .padding(8)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("x = \(target, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Slider(value: $target, in: -1.6...1.6)
            }
            .frame(width: graphSize - 40)

            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("F(x) = \(F, specifier: "%.3f")")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundStyle(.red)
                    Text("G(x) = \(G, specifier: "%.3f")")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundStyle(.blue)
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: areEqual ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(areEqual ? .green : .orange)
                    Text(areEqual ? "F(x) = G(x)" : "F(x) ≠ G(x)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(areEqual ? .green : .orange)
                }
            }
            .frame(width: graphSize)

            Text(target <= current.splitPoint
                 ? "f = g partout sur [0, x] → les aires coïncident exactement, donc F(x) = G(x)."
                 : "f ≠ g après le point de rupture → dès que la zone parcourue contient une différence entre f et g, F(x) et G(x) divergent.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(width: graphSize)
        }
        .padding()
    }
}

#Preview {
    TFIView()
        .preferredColorScheme(.dark)
}
