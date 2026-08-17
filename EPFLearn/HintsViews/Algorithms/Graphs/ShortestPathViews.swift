

import SwiftUI
import Combine

// MARK: - Directed weighted model

struct SPEdge: Identifiable {
    let id = UUID()
    let from: Int, to: Int
    let w: Int
}

enum SPEdgeState { case idle, relaxing, candidate, tree, negCycle }

struct SPFrame {
    var dist: [Int?]            // nil = +∞
    var nodeFill: [Color]
    var edgeState: [SPEdgeState]
    var current: Int?           // index of the edge being relaxed
    var message: String
    var info: String            // settled count / pass number
}

// MARK: - Shortest-path engine

enum SP {

    enum Algo: String, CaseIterable { case dijkstra = "Dijkstra", bellman = "Bellman-Ford" }

    static let nodeSettled = Color.green
    static let nodeSeen    = Color.cyan
    static let nodeFar     = Color.gray

    /// Directed weighted edges, reusing Graph.generate for positions + structure.
    /// Tree edges point away from the roots, so vertices stay reachable from 0.
    static func build(n: Int, connected: Bool, allowNegative: Bool,
                      in rect: CGRect) -> (pos: [CGPoint], edges: [SPEdge]) {
        let safe = rect.insetBy(dx: 28, dy: 28)
        let g = Graph.generate(n: n, extra: max(1, n / 2), connected: connected, in: safe)
        let pos = g.vertices.map { $0.pos }

        var seen = Set<Int>()
        var edges: [SPEdge] = []
        for e in g.edges {
            let key = e.from * 10_000 + e.to
            if seen.contains(key) { continue }
            seen.insert(key)
            edges.append(SPEdge(from: e.from, to: e.to, w: weight(allowNegative)))
        }
        return (pos, edges)
    }

    /// Re-roll only the weights, keeping the same topology (algo / sign toggle).
    static func reweight(_ edges: [SPEdge], allowNegative: Bool) -> [SPEdge] {
        edges.map { SPEdge(from: $0.from, to: $0.to, w: weight(allowNegative)) }
    }

    private static func weight(_ allowNegative: Bool) -> Int {
        if allowNegative && Int.random(in: 0..<10) < 3 { return Int.random(in: -3 ... -1) }
        return Int.random(in: 1...9)
    }

    private static func fills(n: Int, dist: [Int?], settled: [Bool]) -> [Color] {
        (0..<n).map { settled[$0] ? nodeSettled : (dist[$0] != nil ? nodeSeen : nodeFar) }
    }

    // MARK: Dijkstra

    static func dijkstra(n: Int, edges: [SPEdge], start: Int) -> [SPFrame] {
        var dist = [Int?](repeating: nil, count: n); dist[start] = 0
        var settled = [Bool](repeating: false, count: n)
        var treeEdge = [Int?](repeating: nil, count: n)   // chosen predecessor edge
        var states = [SPEdgeState](repeating: .idle, count: edges.count)
        var frames: [SPFrame] = []

        var out = [[Int]](repeating: [], count: n)
        for (i, e) in edges.enumerated() { out[e.from].append(i) }

        func snap(_ cur: Int?, _ msg: String, _ count: Int) {
            frames.append(SPFrame(dist: dist, nodeFill: fills(n: n, dist: dist, settled: settled),
                                  edgeState: states, current: cur, message: msg,
                                  info: "settled \(count)/\(n)"))
        }

        snap(nil, "Dijkstra from \(start): distance 0; every other vertex ∞.", 0)
        var done = 0
        while true {
            var u: Int? = nil; var best = Int.max
            for v in 0..<n where !settled[v] {
                if let d = dist[v], d < best { best = d; u = v }
            }
            guard let node = u else { break }
            settled[node] = true; done += 1
            if let te = treeEdge[node] { states[te] = .tree }
            snap(treeEdge[node], "Settle \(node) (distance \(best)): its distance is now final.", done)

            for ei in out[node] {
                let e = edges[ei]
                if settled[e.to] { continue }
                states[ei] = .relaxing
                let nd = best + e.w
                if dist[e.to] == nil || nd < dist[e.to]! {
                    dist[e.to] = nd
                    if let old = treeEdge[e.to] { states[old] = .idle }
                    treeEdge[e.to] = ei
                    snap(ei, "Relax \(e.from)→\(e.to) (w \(e.w)): improve \(e.to) to \(nd).", done)
                    states[ei] = .candidate
                } else {
                    snap(ei, "Edge \(e.from)→\(e.to) (w \(e.w)): no improvement.", done)
                    states[ei] = .idle
                }
            }
        }

        let far = (0..<n).filter { dist[$0] == nil }.count
        snap(nil, far == 0
             ? "Done. Shortest distances from \(start) are computed."
             : "Done. \(far) vertex(es) unreachable from \(start) (stay ∞).", done)
        return frames
    }

    // MARK: Bellman-Ford

    static func bellman(n: Int, edges: [SPEdge], start: Int) -> [SPFrame] {
        var dist = [Int?](repeating: nil, count: n); dist[start] = 0
        var treeEdge = [Int?](repeating: nil, count: n)
        var states = [SPEdgeState](repeating: .idle, count: edges.count)
        var frames: [SPFrame] = []

        func nodeFills() -> [Color] {
            (0..<n).map { $0 == start ? nodeSettled : (dist[$0] != nil ? nodeSeen : nodeFar) }
        }
        func snap(_ cur: Int?, _ msg: String, _ info: String) {
            frames.append(SPFrame(dist: dist, nodeFill: nodeFills(),
                                  edgeState: states, current: cur, message: msg, info: info))
        }

        snap(nil, "Bellman-Ford from \(start): relax all edges, V−1 times.", "pass 0")

        for pass in 1...max(n - 1, 1) {
            var changed = false
            snap(nil, "Pass \(pass)/\(n - 1): sweep every edge and relax.", "pass \(pass)")
            for (ei, e) in edges.enumerated() {
                guard let du = dist[e.from] else { continue }
                let nd = du + e.w
                if dist[e.to] == nil || nd < dist[e.to]! {
                    dist[e.to] = nd
                    if let old = treeEdge[e.to] { states[old] = .idle }
                    treeEdge[e.to] = ei
                    states[ei] = .relaxing
                    snap(ei, "Pass \(pass): \(e.from)→\(e.to) (w \(e.w)) improves \(e.to) to \(nd).", "pass \(pass)")
                    states[ei] = .idle
                    changed = true
                }
            }
            if !changed {
                snap(nil, "No change during pass \(pass): distances have converged early.", "pass \(pass)")
                break
            }
        }

        for te in treeEdge.compactMap({ $0 }) { states[te] = .tree }

        // Extra pass: any further relaxation ⇒ a reachable negative cycle.
        var trigger: Int? = nil          // an edge that still relaxes
        for (ei, e) in edges.enumerated() {
            if let du = dist[e.from], let dv = dist[e.to], du + e.w < dv { trigger = ei; break }
        }

        guard let t = trigger else {
            snap(nil, "Done. V−1 passes were enough; the distances are final.", "converged")
            return frames
        }

        // Recover the actual cycle: from the relaxed endpoint, walk predecessors
        // n times to land inside the cycle, then loop around collecting its edges.
        var y = edges[t].to
        for _ in 0..<n {
            guard let pe = treeEdge[y] else { break }
            y = edges[pe].from
        }

        var cycleEdges = Set<Int>()
        var cycleNodes = Set<Int>()
        var cur = y
        repeat {
            guard let pe = treeEdge[cur] else { break }
            cycleEdges.insert(pe)
            cycleNodes.insert(cur)
            cur = edges[pe].from
        } while cur != y && cycleEdges.count <= n

        for ei in cycleEdges { states[ei] = .negCycle }
        var fills = nodeFills()
        for v in cycleNodes { fills[v] = .red }
        frames.append(SPFrame(dist: dist, nodeFill: fills, edgeState: states,
                              current: nil,
                              message: "NEGATIVE CYCLE reachable (highlighted in red): looping it lowers the distance forever, so no shortest paths exist.",
                              info: "neg. cycle"))
        return frames
    }
}

// MARK: - Frame rendering (directed, with arrowheads)

struct SPGraphView: View {
    let n: Int
    let positions: [CGPoint]
    let edges: [SPEdge]
    let frame: SPFrame
    var canvasSize: CGSize = .zero

    private let margin: CGFloat = 18

    private func clamp(_ p: CGPoint) -> CGPoint {
        guard canvasSize.width > 0, canvasSize.height > 0 else { return p }
        return CGPoint(x: min(max(p.x, margin), canvasSize.width  - margin),
                       y: min(max(p.y, margin), canvasSize.height - margin))
    }

    private func color(_ s: SPEdgeState) -> Color {
        switch s {
        case .idle:      return .primary.opacity(0.22)
        case .relaxing:  return .cyan
        case .candidate: return .green.opacity(0.55)
        case .tree:      return .green
        case .negCycle:  return .red
        }
    }
    private func width(_ s: SPEdgeState) -> CGFloat {
        (s == .tree || s == .relaxing || s == .negCycle) ? 3 : 1.5
    }

    /// Line from a to b with an arrowhead stopping just short of b's circle.
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

    private func label(_ d: Int?) -> String { d == nil ? "∞" : "\(d!)" }

    var body: some View {
        let p = positions.map(clamp)
        ZStack {
            ForEach(edges.indices, id: \.self) { i in
                let st = frame.edgeState[i]
                let a = p[edges[i].from], b = p[edges[i].to]
                arrow(a, b).stroke(color(st), lineWidth: width(st))
                Text("\(edges[i].w)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(edges[i].w < 0 ? .orange : (st == .tree ? .green : .primary))
                    .padding(.horizontal, 4).padding(.vertical, 1)
                    .background(.thinMaterial, in: Capsule())
                    .position(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
            }
            ForEach(0..<n, id: \.self) { i in
                ZStack {
                    Circle().fill(frame.nodeFill[i]).frame(width: 26, height: 26)
                    if let c = frame.current, edges[c].from == i || edges[c].to == i {
                        Circle().stroke(Color.cyan, lineWidth: 3).frame(width: 32, height: 32)
                    }
                    Text("\(i)").font(.system(size: 11, weight: .bold)).foregroundColor(.primary)
                    Text(label(frame.dist[i]))
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 4).padding(.vertical, 1)
                        .background(.thinMaterial, in: Capsule())
                        .offset(y: -20)
                }
                .position(p[i])
            }
        }
    }
}

// MARK: - Interactive lab

struct ShortestPathLab: View {

    var lockedAlgo: SP.Algo? = nil

    @State private var n: Int
    @State private var start: Int = 0
    @State private var connected: Bool
    @State private var allowNegative: Bool
    @State private var algo: SP.Algo

    @State private var positions: [CGPoint] = []
    @State private var edges: [SPEdge] = []
    @State private var frames: [SPFrame] = []
    @State private var idx = 0
    @State private var size: CGSize = .zero

    private let nRange = 3...7

    init(n: Int = 6, connected: Bool = true, lockedAlgo: SP.Algo? = nil) {
        self.lockedAlgo = lockedAlgo
        _n = State(initialValue: n)
        _connected = State(initialValue: connected)
        _algo = State(initialValue: lockedAlgo ?? .dijkstra)
        _allowNegative = State(initialValue: false)
    }

    private var effectiveAlgo: SP.Algo { lockedAlgo ?? algo }
    private var negAllowed: Bool { effectiveAlgo == .bellman && allowNegative }
    private var current: SPFrame? { frames.indices.contains(idx) ? frames[idx] : nil }

    var body: some View {
        VStack(spacing: 10) {
            VizHeader(effectiveAlgo.rawValue,
                      subtitle: "Shortest distance from the source to every vertex.")

            GeometryReader { proxy in
                ZStack {
                    Color(.secondarySystemBackground)
                    if let f = current {
                        SPGraphView(n: n, positions: positions, edges: edges,
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

            VStack(spacing: 10) {
                VizSlider(label: "Vertices",
                          intValue: Binding(get: { n },
                                            set: { n = $0; if start >= n { start = n - 1 }; generate() }),
                          range: nRange)
                VizSlider(label: "Source",
                          intValue: Binding(get: { start },
                                            set: { start = $0; rebuildFrames() }),
                          range: 0...max(n - 1, 0))
                Toggle("Connected graph", isOn: $connected)
                    .tint(.cyan).foregroundColor(.primary)
                    .onChange(of: connected) { _ in generate() }
                if effectiveAlgo == .bellman {
                    Toggle("Allow negative weights", isOn: $allowNegative)
                        .tint(.orange).foregroundColor(.primary)
                        .onChange(of: allowNegative) { _ in reweight() }
                }
            }

            if lockedAlgo == nil {
                Picker("", selection: $algo) {
                    ForEach(SP.Algo.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .onChange(of: algo) { _ in reweight() }   // non-neg enforced for Dijkstra
            }

            if let f = current {
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
        let g = SP.build(n: n, connected: connected, allowNegative: negAllowed,
                         in: CGRect(origin: .zero, size: size))
        positions = g.pos
        edges = g.edges
        if start >= n { start = max(0, n - 1) }
        rebuildFrames()
    }

    private func reweight() {
        edges = SP.reweight(edges, allowNegative: negAllowed)
        rebuildFrames()
    }

    private func rebuildFrames() {
        frames = (effectiveAlgo == .dijkstra)
            ? SP.dijkstra(n: n, edges: edges, start: start)
            : SP.bellman(n: n, edges: edges, start: start)
        idx = 0
    }
}


struct DijkstraView: View {
    var n: Int = 6
    var connected: Bool = true
    var body: some View { ShortestPathLab(n: n, connected: connected, lockedAlgo: .dijkstra) }
}

struct BellmanFordView: View {
    var n: Int = 6
    var connected: Bool = true
    var body: some View { ShortestPathLab(n: n, connected: connected, lockedAlgo: .bellman) }
}

/// Free version (Dijkstra / Bellman-Ford picker).
struct ShortestPathView: View {
    var n: Int = 6
    var connected: Bool = true
    var body: some View { ShortestPathLab(n: n, connected: connected) }
}

// MARK: - Previews

#Preview("Dijkstra")     { DijkstraView(n: 7) }
#Preview("Bellman-Ford") { BellmanFordView(n: 7) }
#Preview("Free")         { ShortestPathView(n: 8) }
