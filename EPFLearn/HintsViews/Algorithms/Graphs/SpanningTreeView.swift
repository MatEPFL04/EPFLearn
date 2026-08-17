
import SwiftUI
import Combine

// MARK: - Weighted model

struct STEdge: Identifiable {
    let id = UUID()
    let u: Int, v: Int
    let a: CGPoint, b: CGPoint
    let w: Int

    var path: Path {
        Path { p in p.move(to: a); p.addLine(to: b) }
    }
    var mid: CGPoint { CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2) }
}

enum STEdgeState { case idle, candidate, tree, rejected }

struct STFrame {
    var nodeFill: [Color]
    var edgeState: [STEdgeState]
    var current: Int?            // index of the edge being examined
    var totalWeight: Int
    var message: String
}

// MARK: - Union-Find (for Kruskal)

struct DSU {
    private var parent: [Int]
    private var rank: [Int]
    init(_ n: Int) { parent = Array(0..<n); rank = Array(repeating: 0, count: n) }

    mutating func find(_ x: Int) -> Int {
        var x = x
        while parent[x] != x { parent[x] = parent[parent[x]]; x = parent[x] }
        return x
    }
    mutating func union(_ a: Int, _ b: Int) -> Bool {
        let ra = find(a), rb = find(b)
        guard ra != rb else { return false }
        if rank[ra] < rank[rb] { parent[ra] = rb }
        else if rank[ra] > rank[rb] { parent[rb] = ra }
        else { parent[rb] = ra; rank[ra] += 1 }
        return true
    }
}

// MARK: - MST engine

enum MST {

    enum Algo: String, CaseIterable { case kruskal = "Kruskal", prim = "Prim" }

    private static let idleNode = Color.gray
    private static let treeNode = Color.green

    /// Builds a weighted graph: reuses Graph.generate for layout + structure,
    /// deduplicates edges, and weights them by length (a "visually sensible"
    /// MST favors shorter edges).
    static func build(n: Int, connected: Bool, in rect: CGRect) -> (pos: [CGPoint], edges: [STEdge]) {
        // Inset so node circles (radius ~13) and weight labels never spill out.
        let safe = rect.insetBy(dx: 28, dy: 28)
        let g = Graph.generate(n: n, extra: max(1, n / 2), connected: connected, in: safe)
        let pos = g.vertices.map { $0.pos }

        var seen = Set<Int>()
        var edges: [STEdge] = []
        for e in g.edges {
            let key = min(e.from, e.to) * 10_000 + max(e.from, e.to)
            if seen.contains(key) { continue }
            seen.insert(key)
            let a = pos[e.from], b = pos[e.to]
            let dist = hypot(a.x - b.x, a.y - b.y)
            let weight = (dist / 38).rounded()
            let w = weight.isFinite ? max(1, Int(weight)) : 1
            edges.append(STEdge(u: e.from, v: e.to, a: a, b: b, w: w))
        }
        return (pos, edges)
    }

    // MARK: Kruskal

    static func kruskalFrames(n: Int, edges: [STEdge]) -> [STFrame] {
        var states = Array(repeating: STEdgeState.idle, count: edges.count)
        var fills  = Array(repeating: idleNode, count: n)
        var frames: [STFrame] = []
        var total = 0
        var dsu = DSU(n)

        func snap(_ current: Int?, _ msg: String) {
            frames.append(STFrame(nodeFill: fills, edgeState: states,
                                  current: current, totalWeight: total, message: msg))
        }

        let order = edges.indices.sorted { edges[$0].w < edges[$1].w }
        snap(nil, "Kruskal: sort the edges by increasing weight.")

        for idx in order {
            let e = edges[idx]
            states[idx] = .candidate
            snap(idx, "Edge (\(e.u), \(e.v)) of weight \(e.w): examine it.")
            if dsu.union(e.u, e.v) {
                states[idx] = .tree; total += e.w
                fills[e.u] = treeNode; fills[e.v] = treeNode
                snap(idx, "Endpoints in two different components → keep the edge.")
            } else {
                states[idx] = .rejected
                snap(idx, "Endpoints already connected → would create a cycle, reject it.")
            }
        }

        let comps = Set((0..<n).map { dsu.find($0) }).count
        snap(nil, comps == 1
             ? "Done. Minimum spanning tree, total weight = \(total)."
             : "Done. Disconnected graph → spanning forest (\(comps) trees), weight = \(total).")
        return frames
    }

    // MARK: Prim

    static func primFrames(n: Int, edges: [STEdge], start: Int) -> [STFrame] {
        var states = Array(repeating: STEdgeState.idle, count: edges.count)
        var fills  = Array(repeating: idleNode, count: n)
        var inTree = Array(repeating: false, count: n)
        var frames: [STFrame] = []
        var total = 0

        func snap(_ current: Int?, _ msg: String) {
            frames.append(STFrame(nodeFill: fills, edgeState: states,
                                  current: current, totalWeight: total, message: msg))
        }

        func grow(from s: Int) {
            inTree[s] = true; fills[s] = treeNode
            snap(nil, "Prim: start the tree at vertex \(s).")
            while true {
                // Smallest edge crossing the cut (exactly one endpoint in the tree).
                var best: Int? = nil
                for i in edges.indices where states[i] != .tree {
                    let e = edges[i]
                    if inTree[e.u] != inTree[e.v] {
                        if best == nil || e.w < edges[best!].w { best = i }
                    }
                }
                guard let b = best else { break }
                let e = edges[b]
                states[b] = .candidate
                snap(b, "Smallest edge leaving the tree: (\(e.u), \(e.v)), weight \(e.w).")
                states[b] = .tree; total += e.w
                let newV = inTree[e.u] ? e.v : e.u
                inTree[newV] = true; fills[newV] = treeNode
                snap(b, "Attach \(newV) to the tree.")
            }
        }

        grow(from: start)
        for i in 0..<n where !inTree[i] {
            snap(nil, "Component covered. \(i) is outside the tree → new tree (forest).")
            grow(from: i)
        }

        snap(nil, "Done. Total weight = \(total).")
        return frames
    }
}

// MARK: - Frame rendering

struct STGraphView: View {
    let n: Int
    let positions: [CGPoint]
    let edges: [STEdge]
    let frame: STFrame
    var canvasSize: CGSize = .zero

    private let margin: CGFloat = 18   // node radius (13) + a little breathing room

    /// Keep every vertex fully inside the visible canvas, whatever the layout produced.
    private func clamp(_ p: CGPoint) -> CGPoint {
        guard canvasSize.width > 0, canvasSize.height > 0 else { return p }
        return CGPoint(x: min(max(p.x, margin), canvasSize.width  - margin),
                       y: min(max(p.y, margin), canvasSize.height - margin))
    }

    private func edgeColor(_ s: STEdgeState) -> Color {
        switch s {
        case .idle:      return .primary.opacity(0.22)
        case .candidate: return .cyan
        case .tree:      return .green
        case .rejected:  return .red.opacity(0.55)
        }
    }
    private func edgeWidth(_ s: STEdgeState) -> CGFloat {
        (s == .tree || s == .candidate) ? 3 : 1.5
    }

    var body: some View {
        let p = positions.map(clamp)   // clamped positions, single source of truth
        ZStack {
            ForEach(edges.indices, id: \.self) { i in
                let st = frame.edgeState[i]
                let a = p[edges[i].u], b = p[edges[i].v]
                Path { path in path.move(to: a); path.addLine(to: b) }
                    .stroke(edgeColor(st),
                            style: StrokeStyle(lineWidth: edgeWidth(st),
                                               dash: st == .rejected ? [5, 4] : []))
                Text("\(edges[i].w)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(st == .tree ? .green : .primary)
                    .padding(.horizontal, 4).padding(.vertical, 1)
                    .background(.thinMaterial, in: Capsule())
                    .position(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
            }
            ForEach(0..<n, id: \.self) { i in
                ZStack {
                    Circle().fill(frame.nodeFill[i]).frame(width: 26, height: 26)
                    if let c = frame.current, edges[c].u == i || edges[c].v == i {
                        Circle().stroke(Color.cyan, lineWidth: 3).frame(width: 32, height: 32)
                    }
                    Text("\(i)").font(.system(size: 11, weight: .bold)).foregroundColor(.primary)
                }
                .position(p[i])
            }
        }
    }
}

// MARK: - Interactive lab

struct SpanningTreeLab: View {

    var lockedAlgo: MST.Algo? = nil

    @State private var n: Int
    @State private var start: Int = 0
    @State private var connected: Bool
    @State private var algo: MST.Algo

    @State private var positions: [CGPoint] = []
    @State private var edges: [STEdge] = []
    @State private var frames: [STFrame] = []
    @State private var idx = 0
    @State private var size: CGSize = .zero

    private let nRange = 3...8

    init(n: Int = 6, connected: Bool = true, lockedAlgo: MST.Algo? = nil) {
        self.lockedAlgo = lockedAlgo
        _n = State(initialValue: n)
        _connected = State(initialValue: connected)
        _algo = State(initialValue: lockedAlgo ?? .kruskal)
    }

    private var current: STFrame? { frames.indices.contains(idx) ? frames[idx] : nil }

    var body: some View {
        VStack(spacing: 10) {
            VizHeader(lockedAlgo?.rawValue ?? algo.rawValue,
                      subtitle: "Cheapest set of edges that still connects everything.")

            GeometryReader { proxy in
                ZStack {
                    Color(.secondarySystemBackground)
                    if let f = current {
                        STGraphView(n: n, positions: positions, edges: edges,
                                    frame: f, canvasSize: proxy.size)
                    }
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
            .frame(height: 250)   // fixed: the GeometryReader needs a height; the ring is spread by width, so this is the height the controls can spare
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.primary.opacity(0.1)))

            // Settings
            VStack(spacing: 10) {
                VizSlider(label: "Vertices",
                          intValue: Binding(get: { n },
                                            set: { n = $0; if start >= n { start = n - 1 }; generate() }),
                          range: nRange)
                if (lockedAlgo ?? algo) == .prim {
                    VizSlider(label: "Start",
                              intValue: Binding(get: { start },
                                                set: { start = $0; rebuildFrames() }),
                              range: 0...max(n - 1, 0))
                }
                Toggle("Connected graph", isOn: $connected)
                    .tint(.cyan).foregroundColor(.primary)
                    .onChange(of: connected) { _ in generate() }
            }

            if lockedAlgo == nil {
                Picker("", selection: $algo) {
                    ForEach(MST.Algo.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .onChange(of: algo) { _ in rebuildFrames() }
            }

            // Total weight + message
            if let f = current {
                HStack {
                    Text("Weight sum: \(f.totalWeight)")
                        .font(.caption.monospaced()).foregroundColor(.green)
                    Spacer()
                    Text("Step \(idx + 1)/\(frames.count)")
                        .font(.caption2).foregroundColor(.primary.opacity(0.6))
                }
                Text(f.message)
                    .font(.callout).foregroundColor(.primary)
                    .frame(maxWidth: .infinity, minHeight: 38, alignment: .leading)
                    .padding(8)
                    .background(.primary.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            HStack(spacing: 10) {
                StepSlider(step: $idx, total: max(frames.count - 1, 0), accent: .cyan)
                Button("New") { generate() }
                    .buttonStyle(.bordered)
                    .tint(.cyan)
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    private func generate() {
        guard size.width > 0 && size.height > 0 else { return }
        let g = MST.build(n: n, connected: connected, in: CGRect(origin: .zero, size: size))
        positions = g.pos
        edges = g.edges
        if start >= n { start = max(0, n - 1) }
        rebuildFrames()
    }

    private func rebuildFrames() {
        let a = lockedAlgo ?? algo
        frames = (a == .kruskal)
            ? MST.kruskalFrames(n: n, edges: edges)
            : MST.primFrames(n: n, edges: edges, start: start)
        idx = 0
    }
}

// MARK: - Ready-to-plug views

struct KruskalView: View {
    var n: Int = 6
    var connected: Bool = true
    var body: some View { SpanningTreeLab(n: n, connected: connected, lockedAlgo: .kruskal) }
}

struct PrimView: View {
    var n: Int = 6
    var connected: Bool = true
    var body: some View { SpanningTreeLab(n: n, connected: connected, lockedAlgo: .prim) }
}

/// Free version (Kruskal/Prim picker).
struct MSTView: View {
    var n: Int = 6
    var connected: Bool = true
    var body: some View { SpanningTreeLab(n: n, connected: connected) }
}

// MARK: - Previews

#Preview("Kruskal") { KruskalView(n: 7, connected: true) }
#Preview("Prim") { PrimView(n: 7, connected: true) }
#Preview("Free MST") { MSTView(n: 8) }
