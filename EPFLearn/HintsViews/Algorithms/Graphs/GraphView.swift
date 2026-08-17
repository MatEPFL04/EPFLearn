
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

    private let nRange = 3...8

    init(n: Int, directed: Bool, connected: Bool = true, lockedAlgo: Algo? = nil) {
        self.directed = directed
        self.lockedAlgo = lockedAlgo
        _n = State(initialValue: n)
        _algo = State(initialValue: lockedAlgo ?? .bfs)
        _connected = State(initialValue: connected)
    }


    var body: some View {
        VStack(spacing: 10) {
            VizHeader(lockedAlgo?.rawValue ?? algo.rawValue,
                      subtitle: "Visit order from one start vertex.")

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
            .frame(height: 270)   // fixed: the GeometryReader needs a height; 270 spreads the ring without pushing the controls off screen
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.primary.opacity(0.1)))

            // Réglages
            VStack(spacing: 10) {
                VizSlider(label: "Vertices",
                          intValue: Binding(get: { n },
                                            set: { n = $0; if start >= n { start = n - 1 }; generate() }),
                          range: nRange)

                VizSlider(label: "Start",
                          intValue: Binding(get: { start },
                                            set: { start = $0; buildFrames() }),
                          range: 0...max(n - 1, 0))
                    .disabled(n <= 1)

                Toggle("Connected graph", isOn: $connected)
                    .tint(.cyan).foregroundColor(.primary)
                    .onChange(of: connected) { _ in generate() }
            }

            if lockedAlgo == nil {
                Picker("", selection: $algo) {
                    ForEach(Algo.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .onChange(of: algo) { _ in buildFrames() }
            }

            HStack(spacing: 10) {
                StepSlider(step: $step, total: frames.count, accent: .cyan)
                Button("New") { generate() }
                    .buttonStyle(.bordered)
                    .tint(.cyan)
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onChange(of: step) { _ in applyState() }
    }

    private func generate() {
        guard size.width > 0 && size.height > 0 else { return }
        let g = Graph.generate(n: n, extra: max(1, n / 2), connected: connected,
                               in: CGRect(origin: .zero, size: size))
        vertices = g.vertices
        edges = g.edges
        if start >= n { start = max(0, n - 1) }
        buildFrames()
    }

    /// The whole traversal is computed as soon as the graph exists, so the
    /// slider can walk it in both directions; nothing advances on its own.
    private func buildFrames() {
        let count = vertices.count
        guard count > 0 else { frames = []; step = 0; return }
        let adj = Graph.adjacency(n: count, edges: edges, directed: directed)
        let em  = Graph.edgeMap(n: count, edges)
        frames = (algo == .bfs)
            ? Graph.bfsFrames(start, n: count, adj, em)
            : Graph.dfsFrames(start, n: count, adj, em)
        step = 0
        applyState()
    }

    /// Step 0 is the untouched graph; step k is the state after k frames.
    private func applyState() {
        withAnimation(.easeOut(duration: 0.25)) {
            guard step > 0, !frames.isEmpty else {
                for i in vertices.indices {
                    vertices[i].fill = (i == start) ? .cyan : .gray
                    vertices[i].label = (i == start) ? "0" : "∞"
                }
                for i in edges.indices { edges[i].highlighted = false }
                return
            }
            let f = frames[min(step, frames.count) - 1]
            for i in vertices.indices where i < f.fill.count {
                vertices[i].fill = f.fill[i]
                vertices[i].label = f.label[i]
            }
            for i in edges.indices { edges[i].highlighted = f.on.contains(i) }
        }
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

#Preview("BFS, connected") { BFSView(n: 6, connected: true) }
#Preview("DFS, disconnected") { DFSView(n: 6, connected: false) }
