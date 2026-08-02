//
//  SharedMatrixComponents.swift
//  LearnViz
//
//  Shared matrix presets and components for every algebra view.
//  STANDARD LAYOUT: matrix editor on the LEFT, preset picker on the RIGHT.
//

import SwiftUI

// MARK: - Presets

struct MatrixPreset {
    let name: String
    let matrix: M3?      // nil = "Custom", leaves the matrix untouched
}

extension MatrixPreset {

    /// Catalogue for the three-dimensional views.
    static let sharedPresets: [MatrixPreset] = {
        let a = Double.pi / 4
        return [
            MatrixPreset(name: "Custom", matrix: nil),
            MatrixPreset(name: "Identity", matrix: .identity),
            MatrixPreset(name: "Scaling ×1.5",
                         matrix: M3(c1: V3(1.5, 0, 0), c2: V3(0, 1.5, 0), c3: V3(0, 0, 1.5))),
            MatrixPreset(name: "Rotation about z",
                         matrix: M3(c1: V3(cos(a), sin(a), 0), c2: V3(-sin(a), cos(a), 0), c3: V3(0, 0, 1))),
            MatrixPreset(name: "Shear",
                         matrix: M3(c1: V3(1, 0, 0), c2: V3(0, 1, 0), c3: V3(1, 0, 1))),
            MatrixPreset(name: "Projection onto xy",
                         matrix: M3(c1: V3(1, 0, 0), c2: V3(0, 1, 0), c3: V3(0, 0, 0))),
            MatrixPreset(name: "Reflection",
                         matrix: M3(c1: V3(1, 0, 0), c2: V3(0, 1, 0), c3: V3(0, 0, -1))),
            MatrixPreset(name: "Plane · rank 2",
                         matrix: M3(c1: V3(1, 0, 0), c2: V3(0, 1, 0), c3: V3(1, 1, 0))),
            MatrixPreset(name: "Line · rank 1",
                         matrix: M3(c1: V3(1, 1, 0.5), c2: V3(2, 2, 1), c3: V3(-1, -1, -0.5))),
            MatrixPreset(name: "Tilted plane",
                         matrix: M3(c1: V3(1, 0, 0.5), c2: V3(0, 1, 0.5), c3: V3(1, 1, 1))),
            MatrixPreset(name: "Dependent columns",
                         matrix: M3(c1: V3(1, 0.5, 0), c2: V3(2, 1, 0), c3: V3(0, 0, 1))),
            MatrixPreset(name: "Flattening twist",
                         matrix: M3(c1: V3(0.6, 0.4, 0), c2: V3(-0.4, 0.6, 0), c3: V3(0.3, 0.3, 0.25))),
            MatrixPreset(name: "Zero map",
                         matrix: M3(c1: .zero, c2: .zero, c3: .zero))
        ]
    }()

    /// Catalogue for the planar views. The 3D list cannot be reused as is:
    /// projection onto xy, reflection in z, plane rank 2 and tilted plane all
    /// leave the first two columns at (1,0) and (0,1), so in ℝ² four different
    /// entries would draw the exact same identity square.
    ///
    /// The third column is never read here, it only keeps the type the same.
    static let planarPresets: [MatrixPreset] = {
        let a = Double.pi / 4
        let k = V3(0, 0, 1)
        return [
            MatrixPreset(name: "Custom", matrix: nil),
            MatrixPreset(name: "Identity",
                         matrix: M3(c1: V3(1, 0, 0), c2: V3(0, 1, 0), c3: k)),
            MatrixPreset(name: "Scaling ×1.5",
                         matrix: M3(c1: V3(1.5, 0, 0), c2: V3(0, 1.5, 0), c3: k)),
            MatrixPreset(name: "Rotation 45°",
                         matrix: M3(c1: V3(cos(a), sin(a), 0), c2: V3(-sin(a), cos(a), 0), c3: k)),
            MatrixPreset(name: "Shear",
                         matrix: M3(c1: V3(1, 0, 0), c2: V3(0.75, 1, 0), c3: k)),
            // Negative determinant: the only way to see an orientation flip in
            // the plane, since a reflection in z is invisible here.
            MatrixPreset(name: "Reflection in y",
                         matrix: M3(c1: V3(-1, 0, 0), c2: V3(0, 1, 0), c3: k)),
            // Stretched one way, squashed the other: area unchanged, shape not.
            MatrixPreset(name: "Squeeze · det 1",
                         matrix: M3(c1: V3(2, 0, 0), c2: V3(0, 0.5, 0), c3: k)),
            // Just barely independent: the parallelogram is a sliver.
            MatrixPreset(name: "Almost flat",
                         matrix: M3(c1: V3(1, 0.5, 0), c2: V3(2, 1.05, 0), c3: k)),
            MatrixPreset(name: "Collinear",
                         matrix: M3(c1: V3(1, 0.5, 0), c2: V3(2, 1, 0), c3: k)),
            MatrixPreset(name: "Opposite directions",
                         matrix: M3(c1: V3(1, 1, 0), c2: V3(-2, -2, 0), c3: k)),
            MatrixPreset(name: "Second vector zero",
                         matrix: M3(c1: V3(2, 1, 0), c2: .zero, c3: k)),
            MatrixPreset(name: "Zero map",
                         matrix: M3(c1: .zero, c2: .zero, c3: k))
        ]
    }()
}

// MARK: - Matrix editor

/// A reusable 3×3 matrix editor with scrub cells.
/// ALWAYS positioned on the LEFT in the control panel.
struct MatrixEditorView: View {
    @Binding var matrix: M3
    @Binding var presetIndex: Int

    var columnColors: [Color] = [.red, .green, .blue]
    var columnLabels: [String] = ["e\u{20D7}\u{2081}", "e\u{20D7}\u{2082}", "e\u{20D7}\u{2083}"]
    var showRowLabels: Bool = false

    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 3) {
                if showRowLabels {
                    Color.clear.frame(width: 11, height: 1)
                }
                ForEach(0..<3, id: \.self) { c in
                    Text(columnLabels[c])
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(columnColors[c])
                        .frame(width: Matrix3DView.cellW)
                }
            }

            HStack(spacing: 2) {
                if showRowLabels {
                    VStack(spacing: 3) {
                        ForEach(0..<3, id: \.self) { r in
                            Text(["x", "y", "z"][r])
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .frame(width: 11, height: Matrix3DView.cellH)
                        }
                    }
                }

                BracketShape(leading: true)
                    .stroke(Color.secondary.opacity(0.5), lineWidth: 1.2)
                    .frame(width: 5)

                VStack(spacing: 3) {
                    ForEach(0..<3, id: \.self) { r in
                        HStack(spacing: 3) {
                            ForEach(0..<3, id: \.self) { c in
                                ScrubCell(value: cellBinding(r, c), tint: columnColors[c])
                            }
                        }
                    }
                }

                BracketShape(leading: false)
                    .stroke(Color.secondary.opacity(0.5), lineWidth: 1.2)
                    .frame(width: 5)
            }

            Text("drag \u{2194} · double-tap to zero")
                .font(.system(size: 8.5))
                .foregroundStyle(.tertiary)
                .padding(.top, 2)
        }
    }

    private func cellBinding(_ r: Int, _ c: Int) -> Binding<Double> {
        Binding(
            get: { matrix[r, c] },
            set: { matrix[r, c] = $0; presetIndex = 0 }
        )
    }
}

// MARK: - Preset picker

/// A reusable preset picker.
/// ALWAYS positioned on the RIGHT in the control panel.
struct MatrixPresetPicker: View {
    @Binding var presetIndex: Int
    var presets: [MatrixPreset]
    var height: CGFloat = 88

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("EXAMPLES")
                .font(.system(size: 9, weight: .bold))
                .tracking(0.7)
                .foregroundStyle(.secondary)

            Picker("Examples", selection: $presetIndex) {
                ForEach(presets.indices, id: \.self) { i in
                    Text(presets[i].name)
                        .font(.system(size: 13, weight: .medium))
                        .tag(i)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .frame(height: height)
            .clipped()
        }
    }
}

// MARK: - Control panel

/// Matrix editor LEFT, preset picker RIGHT, so every algebra view lays out the
/// same way.
struct MatrixControlPanel: View {
    @Binding var matrix: M3
    @Binding var presetIndex: Int
    var presets: [MatrixPreset] = MatrixPreset.sharedPresets
    var onPresetChange: () -> Void

    var columnColors: [Color] = [.red, .green, .blue]
    var columnLabels: [String] = ["e\u{20D7}\u{2081}", "e\u{20D7}\u{2082}", "e\u{20D7}\u{2083}"]
    var showRowLabels: Bool = false
    var pickerHeight: CGFloat = 88
    /// Set to false where the view already edits the matrix somewhere else, so
    /// the same nine cells are not offered twice on one screen.
    var showEditor: Bool = true

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if showEditor {
                MatrixEditorView(
                    matrix: $matrix,
                    presetIndex: $presetIndex,
                    columnColors: columnColors,
                    columnLabels: columnLabels,
                    showRowLabels: showRowLabels
                )
            }

            MatrixPresetPicker(
                presetIndex: $presetIndex,
                presets: presets,
                height: pickerHeight
            )
            .frame(maxWidth: .infinity)
            .onChange(of: presetIndex) { onPresetChange() }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 13).fill(Color(.secondarySystemGroupedBackground)))
    }
}

// MARK: - Shared 3D chrome

/// Header used by every algebra view, so they all open the same way.
struct AlgebraHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.title3.bold())
            Text(subtitle)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

/// The 3D viewport chrome: fixed height, gradient backdrop, rounded corners,
/// orbit gesture, double-tap reset, a HUD slot top-left, a legend slot
/// bottom-left and the zoom slider bottom-right.
///
/// The orbit anchor lives here rather than in each view, so the gesture cannot
/// drift between them.
struct AlgebraViewport<HUD: View, Legend: View>: View {

    @Binding var azimuth: Double
    @Binding var elevation: Double
    @Binding var distance: Double

    var distanceRange: ClosedRange<Double> = 4.5...16
    var home: (azimuth: Double, elevation: Double, distance: Double)
    var height: CGFloat = 380
    var accent: Color = .cyan

    let render: (GraphicsContext, CGSize) -> Void
    @ViewBuilder let hud: () -> HUD
    @ViewBuilder let legend: () -> Legend

    @State private var orbitAnchor: (Double, Double)?

    var body: some View {
        ZStack(alignment: .topLeading) {
            Canvas { ctx, size in render(ctx, size) }
                .frame(height: height)
                .background(
                    LinearGradient(colors: [Color(.secondarySystemBackground),
                                            Color(.tertiarySystemBackground)],
                                   startPoint: .top, endPoint: .bottom)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .contentShape(RoundedRectangle(cornerRadius: 16))
                .highPriorityGesture(orbitGesture)
                .onTapGesture(count: 2) {
                    withAnimation(.easeInOut(duration: 0.45)) {
                        azimuth = home.azimuth
                        elevation = home.elevation
                        distance = home.distance
                    }
                }

            hud().padding(10)
        }
        .overlay(alignment: .bottomLeading) { legend().padding(10) }
        .overlay(alignment: .bottomTrailing) { zoomSlider.padding(9) }
    }

    private var orbitGesture: some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { g in
                if orbitAnchor == nil { orbitAnchor = (azimuth, elevation) }
                guard let a = orbitAnchor else { return }
                azimuth = a.0 - Double(g.translation.width) * 0.008
                elevation = min(max(a.1 + Double(g.translation.height) * 0.006, -1.45), 1.45)
            }
            .onEnded { _ in orbitAnchor = nil }
    }

    /// Plus on the left, minus on the right: the low end of the range is the
    /// close camera, so the left of the track is the zoomed-in end.
    private var zoomSlider: some View {
        HStack(spacing: 5) {
            Image(systemName: "plus.magnifyingglass").font(.system(size: 9))
            Slider(value: $distance, in: distanceRange).frame(width: 88)
            Image(systemName: "minus.magnifyingglass").font(.system(size: 9))
        }
        .foregroundStyle(.secondary)
        .tint(accent)
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(.thinMaterial, in: Capsule())
    }
}

/// Readout badge pinned to the top-left of a viewport.
struct AlgebraHUD: View {
    let headline: String
    let detail: String
    var color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(headline)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            Text(detail)
                .font(.system(size: 9.5))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

/// The identity-to-A slider, identical in every view that has one.
struct MorphCard: View {
    @Binding var morph: Double
    var accent: Color = .cyan

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 0) {
                Text("TRANSFORMATION")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.7)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(readout)
                    .font(.system(size: 10, weight: .heavy, design: .monospaced))
                    .foregroundStyle(accent)
            }
            Slider(value: $morph, in: 0...1).tint(accent)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 13).fill(Color(.secondarySystemGroupedBackground)))
    }

    private var readout: String {
        if morph < 0.001 { return "identity" }
        if morph > 0.999 { return "A applied" }
        return "\(Int(morph * 100))%"
    }
}
