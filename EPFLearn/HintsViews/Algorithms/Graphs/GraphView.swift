
import Combine

import SwiftUI

struct GraphLab: View {

    enum Algo: String, CaseIterable { case bfs = "BFS", dfs = "DFS" }

    let directed: Bool
    var lockedAlgo: Algo? = nil

    @State private var n: Int
    @State private var start: Int = 0
    @State private var connected: Bool
    @State private var algo: Algo

    @State private var vertices: [Vertex] = []
    @State private var edges: [Edge] = []
    @State private var size: CGSize = .zero
    @State private var frames: [GraphFrame] = []
    @State private var step = 0

    private let nRange = 2...12

    init(n: Int, directed: Bool, connected: Bool = true, lockedAlgo: Algo? = nil) {
        self.directed = directed
        self.lockedAlgo = lockedAlgo
        _n = State(initialValue: n)
        _algo = State(initialValue: lockedAlgo ?? .bfs)
        _connected = State(initialValue: connected)
    }

    private let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    private var running: Bool { step < frames.count }

    var body: some View {
        VStack(spacing: 14) {
            Text(lockedAlgo?.rawValue ?? algo.rawValue)
                .font(.headline).foregroundColor(.primary)

            GeometryReader { proxy in
                ZStack {
                    Color(.secondarySystemBackground)

                    ForEach(edges.indices, id: \.self) { i in
                        edges[i].stroke(edges[i].highlighted ? .cyan : .primary.opacity(0.3),
                                        lineWidth: edges[i].highlighted ? 3 : 1.5)
                    }
                    ForEach(vertices) { $0 }
                }
                .onChange(of: proxy.size) { newSize in
                    // Éviter les re-générations infinies : seulement si le size change significativement
                    let changed = abs(size.width - newSize.width) > 1 || abs(size.height - newSize.height) > 1
                    if changed && newSize.width > 0 && newSize.height > 0 {
                        size = newSize
                        generate()
                    }
                }
                .onAppear {
                    if proxy.size.width > 0 && proxy.size.height > 0 {
                        size = proxy.size
                        generate()
                    }
                }
            }
            .frame(height: 300)  // ← HAUTEUR FIXE POUR LE GEOMETRYREADER
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.primary.opacity(0.1)))

            // Réglages
            VStack(spacing: 10) {
                sliderRow(title: "Vertices", value: "\(n)") {
                    Slider(value: Binding(
                        get: { Double(n) },
                        set: { n = Int($0); if start >= n { start = n - 1 }; generate() }
                    ), in: Double(nRange.lowerBound)...Double(nRange.upperBound), step: 1)
                }

                sliderRow(title: "Start", value: "\(start)") {
                    Slider(value: Binding(
                        get: { Double(start) },
                        set: { start = Int($0); reset() }
                    ), in: 0...Double(max(n - 1, 0)), step: 1)
                    .disabled(n <= 1)
                }

                Toggle("Connected graph", isOn: $connected)
                    .tint(.cyan).foregroundColor(.primary)
                    .onChange(of: connected) { _ in generate() }
            }

            if lockedAlgo == nil {
                Picker("", selection: $algo) {
                    ForEach(Algo.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .onChange(of: algo) { _ in reset() }
            }

            HStack(spacing: 20) {
                Button("New") { generate() }.buttonStyle(.bordered)
                Button("Run") { run() }.buttonStyle(.borderedProminent).disabled(running)
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onReceive(timer) { _ in tick() }
    }

    // Title + value + slider, one row, kept minimal
    @ViewBuilder
    private func sliderRow<S: View>(title: String, value: String, @ViewBuilder slider: () -> S) -> some View {
        HStack(spacing: 10) {
            Text(title).font(.caption).foregroundColor(.primary).frame(width: 64, alignment: .leading)
            slider()
            Text(value).font(.caption.monospaced()).foregroundColor(.cyan).frame(width: 26, alignment: .trailing)
        }
    }

    private func tick() {
        guard step < frames.count else { return }
        let f = frames[step]
        withAnimation(.easeOut(duration: 0.25)) {
            for i in vertices.indices {
                vertices[i].fill = f.fill[i]
                vertices[i].label = f.label[i]
            }
            for i in edges.indices {
                edges[i].highlighted = f.on.contains(i)
            }
        }
        step += 1
    }

    private func generate() {
        guard size.width > 0 && size.height > 0 else { return }
        let g = Graph.generate(n: n, extra: max(1, n / 2), connected: connected,
                               in: CGRect(origin: .zero, size: size))
        vertices = g.vertices
        edges = g.edges
        if start >= n { start = max(0, n - 1) }
        reset()
    }

    private func run() {
        let count = vertices.count
        guard count > 0 else { return }
        let adj = Graph.adjacency(n: count, edges: edges, directed: directed)
        let em  = Graph.edgeMap(n: count, edges)
        reset()
        frames = (algo == .bfs)
            ? Graph.bfsFrames(start, n: count, adj, em)
            : Graph.dfsFrames(start, n: count, adj, em)
        step = 0
    }

    private func reset() {
        for i in vertices.indices {
            vertices[i].fill = (i == start) ? .cyan : .gray
            vertices[i].label = (i == start) ? "0" : "∞"
        }
        for i in edges.indices { edges[i].highlighted = false }
        frames = []
        step = 0
    }
}

// MARK: - Vues simples prêtes à brancher

struct BFSView: View {
    var n: Int = 6
    var connected: Bool = true
    var body: some View {
        GraphLab(n: n, directed: false, connected: connected, lockedAlgo: .bfs)
    }
}

struct DFSView: View {
    var n: Int = 6
    var connected: Bool = true
    var body: some View {
        GraphLab(n: n, directed: false, connected: connected, lockedAlgo: .dfs)
    }
}

// MARK: - Previews

#Preview("BFS - connexe") { BFSView(n: 6, connected: true) }
#Preview("DFS - non connexe") { DFSView(n: 6, connected: false) }
