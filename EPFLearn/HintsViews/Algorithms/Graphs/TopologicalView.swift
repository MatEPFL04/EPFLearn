
import SwiftUI
import Combine

struct TEdge: Identifiable {
    let id = UUID()
    let from: Int, to: Int
}

enum TEdgeState { case idle, active, done }

struct TopoFrame {
    var nodeFill: [Color]
    var nodeLabel: [String]      // in-degree (Kahn) or "" (DFS)
    var edgeState: [TEdgeState]
    var current: Int?
    var order: [Int]             // output built so far
    var message: String
    var info: String
}

enum Topo {

    enum Algo: String, CaseIterable { case kahn = "Kahn", dfs = "DFS" }

    static let ready    = Color.cyan     // in-degree 0 / discovered
    static let active   = Color.orange   // in progress (DFS)
    static let done     = Color.green    // placed in the order
    static let idleNode = Color.gray

    /// Builds a DAG and lays it out in LAYERS (left→right by dependency depth),
    /// so every edge points rightward and the topological order is readable.
    /// Edge structure comes from Graph.generate; positions are computed here.
    static func buildDAG(n: Int, in rect: CGRect) -> (pos: [CGPoint], edges: [TEdge]) {
        let safe = rect.insetBy(dx: 28, dy: 28)
        let g = Graph.generate(n: n, extra: max(1, n / 2), connected: true, in: safe)

        // Random rank ⇒ orient every edge low-rank → high-rank ⇒ acyclic.
        var rankOf = [Int](repeating: 0, count: n)
        for (i, node) in Array(0..<n).shuffled().enumerated() { rankOf[node] = i }

        var seen = Set<Int>()
        var edges: [TEdge] = []
        for e in g.edges {
            let lo = rankOf[e.from] < rankOf[e.to] ? e.from : e.to
            let hi = lo == e.from ? e.to : e.from
            if lo == hi { continue }
            let key = lo * 10_000 + hi
            if seen.contains(key) { continue }
            seen.insert(key)
            edges.append(TEdge(from: lo, to: hi))
        }

        // Longest-path layering: layer[v] = longest chain of edges ending at v.
        var outAdj = [[Int]](repeating: [], count: n)
        for e in edges { outAdj[e.from].append(e.to) }
        let topoOrder = (0..<n).sorted { rankOf[$0] < rankOf[$1] }
        var layer = [Int](repeating: 0, count: n)
        for u in topoOrder {
            for v in outAdj[u] { layer[v] = max(layer[v], layer[u] + 1) }
        }
        let maxLayer = max(layer.max() ?? 0, 1)

        // Place: x by layer, y spread evenly within each layer.
        var byLayer: [Int: [Int]] = [:]
        for v in 0..<n { byLayer[layer[v], default: []].append(v) }

        var pos = [CGPoint](repeating: .zero, count: n)
        for (l, nodes) in byLayer {
            let x = safe.minX + CGFloat(l) / CGFloat(maxLayer) * safe.width
            let k = nodes.count
            for (i, v) in nodes.enumerated() {
                let y = safe.minY + (CGFloat(i) + 0.5) / CGFloat(k) * safe.height
                pos[v] = CGPoint(x: x, y: y)
            }
        }
        return (pos, edges)
    }

    private static func outEdges(n: Int, _ edges: [TEdge]) -> [[Int]] {
        var out = [[Int]](repeating: [], count: n)
        for (i, e) in edges.enumerated() { out[e.from].append(i) }
        return out
    }

    // MARK: Kahn's algorithm

    static func kahnFrames(n: Int, edges: [TEdge]) -> [TopoFrame] {
        var indeg = [Int](repeating: 0, count: n)
        for e in edges { indeg[e.to] += 1 }

        var fills = (0..<n).map { indeg[$0] == 0 ? ready : idleNode }
        var labels = (0..<n).map { "\(indeg[$0])" }
        var states = [TEdgeState](repeating: .idle, count: edges.count)
        var order: [Int] = []
        var frames: [TopoFrame] = []
        let out = outEdges(n: n, edges)

        func snap(_ cur: Int?, _ msg: String) {
            frames.append(TopoFrame(nodeFill: fills, nodeLabel: labels, edgeState: states,
                                    current: cur, order: order, message: msg,
                                    info: "placed \(order.count)/\(n)"))
        }

        var queue = (0..<n).filter { indeg[$0] == 0 }
        snap(nil, "Kahn: label each vertex with its in-degree; queue the 0-in-degree ones.")

        while !queue.isEmpty {
            let u = queue.removeFirst()
            fills[u] = done; order.append(u)
            snap(nil, "Remove \(u) (in-degree 0) → append it to the order.")
            for ei in out[u] {
                let v = edges[ei].to
                states[ei] = .active
                indeg[v] -= 1; labels[v] = "\(indeg[v])"
                snap(ei, "Edge \(u)→\(v): drop \(v)'s in-degree to \(indeg[v]).")
                states[ei] = .done
                if indeg[v] == 0 {
                    queue.append(v); fills[v] = ready
                    snap(nil, "\(v) now has in-degree 0 → enqueue it.")
                }
            }
        }

        snap(nil, order.count == n
             ? "Done. A valid topological order: \(order.map(String.init).joined(separator: " → "))."
             : "Stuck with vertices left ⇒ the graph has a cycle (not a DAG).")
        return frames
    }

    // MARK: DFS-based (decreasing finishing time)

    static func dfsFrames(n: Int, edges: [TEdge]) -> [TopoFrame] {
        var fills = [Color](repeating: idleNode, count: n)
        var labels = [String](repeating: "", count: n)
        var states = [TEdgeState](repeating: .idle, count: edges.count)
        var visited = [Bool](repeating: false, count: n)
        var order: [Int] = []
        var frames: [TopoFrame] = []
        var time = 0
        let out = outEdges(n: n, edges)

        func snap(_ cur: Int?, _ msg: String) {
            frames.append(TopoFrame(nodeFill: fills, nodeLabel: labels, edgeState: states,
                                    current: cur, order: order, message: msg,
                                    info: "placed \(order.count)/\(n)"))
        }

        func visit(_ u: Int) {
            visited[u] = true; fills[u] = active
            time += 1
            labels[u] = "\(time)/·"          // discovery time, finish pending
            snap(nil, "Discover \(u) (start time \(time)).")
            for ei in out[u] {
                let v = edges[ei].to
                if !visited[v] {
                    states[ei] = .active
                    snap(ei, "Follow \(u)→\(v): descend.")
                    visit(v)
                    states[ei] = .done
                }
            }
            time += 1
            let start = labels[u].split(separator: "/").first.map(String.init) ?? ""
            labels[u] = "\(start)/\(time)"   // start/finish, classic DFS
            fills[u] = done
            order.insert(u, at: 0)           // prepend ⇒ decreasing finishing time
            snap(nil, "Finish \(u) (finish time \(time)). Prepend it ⇒ vertices end up by DECREASING finish time.")
        }

        snap(nil, "DFS topological sort: order vertices by DECREASING finishing time.")
        for s in 0..<n where !visited[s] { visit(s) }
        snap(nil, "Done. By decreasing finish time: \(order.map(String.init).joined(separator: " → ")).")
        return frames
    }
}

// MARK: - Order strip

struct TopoOrderStrip: View {
    let order: [Int]
    let n: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Order").font(.caption2).foregroundColor(.primary.opacity(0.6))
            HStack(spacing: 4) {
                if order.isEmpty {
                    Text("—").font(.caption).foregroundColor(.primary.opacity(0.4))
                } else {
                    ForEach(Array(order.enumerated()), id: \.offset) { i, node in
                        Text("\(node)")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.black)
                            .frame(width: 24, height: 24)
                            .background(Color.green).clipShape(RoundedRectangle(cornerRadius: 5))
                        if i < order.count - 1 {
                            Image(systemName: "arrow.right").font(.system(size: 9))
                                .foregroundColor(.primary.opacity(0.5))
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Frame rendering (directed, arrowheads)

struct TopoGraphView: View {
    let n: Int
    let positions: [CGPoint]
    let edges: [TEdge]
    let frame: TopoFrame
    var canvasSize: CGSize = .zero

    private let margin: CGFloat = 18

    private func clamp(_ p: CGPoint) -> CGPoint {
        guard canvasSize.width > 0, canvasSize.height > 0 else { return p }
        return CGPoint(x: min(max(p.x, margin), canvasSize.width  - margin),
                       y: min(max(p.y, margin), canvasSize.height - margin))
    }
    private func color(_ s: TEdgeState) -> Color {
        switch s {
        case .idle:   return .primary.opacity(0.22)
        case .active: return .cyan
        case .done:   return .green.opacity(0.5)
        }
    }
    private func arrow(_ a: CGPoint, _ b: CGPoint) -> Path {
        var path = Path()
        let dx = b.x - a.x, dy = b.y - a.y
        let len = max(hypot(dx, dy), 0.001)
        let ux = dx / len, uy = dy / len
        let tip = CGPoint(x: b.x - ux * 16, y: b.y - uy * 16)
        path.move(to: a); path.addLine(to: tip)
        let back = CGPoint(x: tip.x - ux * 9, y: tip.y - uy * 9)
        let px = -uy, py = ux
        path.move(to: CGPoint(x: back.x + px * 5, y: back.y + py * 5))
        path.addLine(to: tip)
        path.addLine(to: CGPoint(x: back.x - px * 5, y: back.y - py * 5))
        return path
    }

    var body: some View {
        let p = positions.map(clamp)
        ZStack {
            ForEach(edges.indices, id: \.self) { i in
                let st = frame.edgeState[i]
                arrow(p[edges[i].from], p[edges[i].to])
                    .stroke(color(st), lineWidth: st == .active ? 3 : 1.5)
            }
            ForEach(0..<n, id: \.self) { i in
                ZStack {
                    Circle().fill(frame.nodeFill[i]).frame(width: 28, height: 28)
                    if let c = frame.current, edges[c].from == i || edges[c].to == i {
                        Circle().stroke(Color.cyan, lineWidth: 3).frame(width: 34, height: 34)
                    }
                    Text("\(i)").font(.system(size: 11, weight: .bold)).foregroundColor(.primary)
                    if !frame.nodeLabel[i].isEmpty {
                        Text(frame.nodeLabel[i])   // in-degree (Kahn)
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 4).padding(.vertical, 1)
                            .background(.thinMaterial, in: Capsule())
                            .offset(y: -21)
                    }
                }
                .position(p[i])
            }
        }
    }
}

// MARK: - Interactive lab

struct TopoSortLab: View {

    var lockedAlgo: Topo.Algo? = nil

    @State private var n: Int
    @State private var algo: Topo.Algo
    @State private var positions: [CGPoint] = []
    @State private var edges: [TEdge] = []
    @State private var frames: [TopoFrame] = []
    @State private var idx = 0
    @State private var playing = false
    @State private var size: CGSize = .zero

    private let nRange = 3...11
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    init(n: Int = 7, lockedAlgo: Topo.Algo? = nil) {
        self.lockedAlgo = lockedAlgo
        _n = State(initialValue: n)
        _algo = State(initialValue: lockedAlgo ?? .kahn)
    }

    private var effectiveAlgo: Topo.Algo { lockedAlgo ?? algo }
    private var current: TopoFrame? { frames.indices.contains(idx) ? frames[idx] : nil }

    var body: some View {
        VStack(spacing: 14) {
            Text("Topological sort: \(effectiveAlgo.rawValue)")
                .font(.headline).foregroundColor(.primary)

            GeometryReader { proxy in
                ZStack {
                    Color(.secondarySystemBackground)
                    if let f = current {
                        TopoGraphView(n: n, positions: positions, edges: edges,
                                      frame: f, canvasSize: proxy.size)
                    }
                }
                .onAppear {
                    size = proxy.size
                    if positions.isEmpty { generate() }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.primary.opacity(0.1)))

            sliderRow(title: "Vertices", value: "\(n)") {
                Slider(value: Binding(
                    get: { Double(n) },
                    set: { n = Int($0); generate() }
                ), in: Double(nRange.lowerBound)...Double(nRange.upperBound), step: 1)
            }

            if lockedAlgo == nil {
                Picker("", selection: $algo) {
                    ForEach(Topo.Algo.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .onChange(of: algo) { _ in rebuildFrames() }
            }

            if let f = current {
                TopoOrderStrip(order: f.order, n: n)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Text(f.info).font(.caption.monospaced()).foregroundColor(.cyan)
                    Spacer()
                    Text("Step \(idx + 1)/\(frames.count)")
                        .font(.caption2).foregroundColor(.primary.opacity(0.6))
                }
                Text(f.message)
                    .font(.callout).foregroundColor(.primary)
                    .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
                    .padding(8)
                    .background(.primary.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            HStack(spacing: 18) {
                Button { idx = 0; playing = false } label: { Image(systemName: "backward.end.fill") }
                Button { if idx > 0 { idx -= 1 } } label: { Image(systemName: "backward.fill") }
                Button { playing.toggle() } label: {
                    Image(systemName: playing ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 34))
                }
                Button { if idx < frames.count - 1 { idx += 1 } } label: { Image(systemName: "forward.fill") }
                Button { idx = frames.count - 1; playing = false } label: { Image(systemName: "forward.end.fill") }
                Spacer()
                Button("New") { generate() }.buttonStyle(.bordered)
            }
            .tint(.cyan)
        }
        .padding()
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onReceive(timer) { _ in
            guard playing, !frames.isEmpty else { return }
            if idx < frames.count - 1 { idx += 1 } else { playing = false }
        }
    }

    @ViewBuilder
    private func sliderRow<S: View>(title: String, value: String, @ViewBuilder slider: () -> S) -> some View {
        HStack(spacing: 10) {
            Text(title).font(.caption).foregroundColor(.primary).frame(width: 64, alignment: .leading)
            slider()
            Text(value).font(.caption.monospaced()).foregroundColor(.cyan).frame(width: 26, alignment: .trailing)
        }
    }

    private func generate() {
        guard size.width > 0 else { return }
        let g = Topo.buildDAG(n: n, in: CGRect(origin: .zero, size: size))
        positions = g.pos
        edges = g.edges
        rebuildFrames()
    }

    private func rebuildFrames() {
        frames = (effectiveAlgo == .kahn)
            ? Topo.kahnFrames(n: n, edges: edges)
            : Topo.dfsFrames(n: n, edges: edges)
        idx = 0
        playing = false
    }
}

struct KahnView: View {
    var n: Int = 7
    var body: some View { TopoSortLab(n: n, lockedAlgo: .kahn) }
}

struct TopoDFSView: View {
    var n: Int = 7
    var body: some View { TopoSortLab(n: n, lockedAlgo: .dfs) }
}

/// Free version (Kahn / DFS picker).
struct TopoSortView: View {
    var n: Int = 7
    var body: some View { TopoSortLab(n: n) }
}

// MARK: - Previews


#Preview("DFS")  { TopoDFSView(n: 7) }
