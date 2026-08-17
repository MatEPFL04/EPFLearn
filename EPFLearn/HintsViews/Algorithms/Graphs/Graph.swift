//
//  BFS_view.swift
//  EPFLearn
//
//  Created by Mat on 26.06.2026.
//

//  Created by Mat on 26.06.2026.
//

import Foundation
import CoreGraphics
import SwiftUI

struct GraphFrame {
    let fill: [Color]
    let label: [String]
    let on: Set<Int>            // indices des arêtes allumées
}

struct Vertex: Identifiable, View {
    let id: Int
    let pos: CGPoint
    var fill: Color = .gray
    var label: String = ""

    var body: some View {
        ZStack {
            Circle()
                .fill(fill)
                .frame(width: 26, height: 26)
            Text("\(id)")
                .font(.system(size: 11, weight: .bold)).foregroundColor(.white)
            if !label.isEmpty {
                Text(label)
                    .font(.system(size: 9, weight: .bold, design: .monospaced)).foregroundColor(.white)
                    .padding(.horizontal, 4).padding(.vertical, 1)
                    .background(.thinMaterial, in: Capsule())
                    .offset(y: -20)
            }
        }.position(pos)
    }
}

struct Edge: Identifiable {
    let id = UUID()
    let from: Int, to: Int, a: CGPoint, b: CGPoint
    var highlighted: Bool = false

    func stroke(_ color: Color, lineWidth: CGFloat) -> some View {
        Path { p in
            p.move(to: a)
            p.addLine(to: b)
        }.stroke(color, lineWidth: lineWidth)
    }
}

// MARK: - Moteur algorithmique épuré

enum Graph {

    /// Builds a graph and lays it out so the drawing can be read.
    ///
    /// The old version scattered the vertices on a jittered grid and then
    /// shuffled them, so a vertex's position said nothing about who it was
    /// connected to: every edge was a random diagonal and, past a handful of
    /// vertices, the circles sat almost on top of each other.
    ///
    /// Now the structure is built first and the vertices are placed on a ring
    /// in breadth-first order, so neighbours end up side by side, the chords
    /// stay short, and the spacing between two circles is fixed by the ring
    /// rather than by chance. A disconnected graph gets one ring per component.
    static func generate(n: Int, extra: Int, connected: Bool = true,
                         in rect: CGRect) -> (vertices: [Vertex], edges: [Edge]) {
        guard n > 0, rect.width > 0, rect.height > 0 else { return ([], []) }

        // 1. Structure, as index pairs. No self-loops, no repeated edge.
        var pairs: [(Int, Int)] = []
        var adj = [[Int]](repeating: [], count: n)

        func link(_ a: Int, _ b: Int) {
            guard a != b, !adj[a].contains(b) else { return }
            pairs.append((a, b))
            adj[a].append(b)
            adj[b].append(a)
        }

        // Two components need at least three vertices (an isolated one and a
        // pair); below that the "connected" toggle has nothing to express.
        let groups: [Range<Int>] = (connected || n < 3) ? [0..<n]
                                                        : [0..<(n / 2), (n / 2)..<n]
        for g in groups where g.count > 1 {
            for child in (g.lowerBound + 1)..<g.upperBound {
                link(Int.random(in: g.lowerBound..<child), child)   // spanning tree
            }
        }

        // Extra edges close cycles, but never bridge two components.
        var added = 0
        var attempts = 0
        while added < extra, attempts < 60 {
            attempts += 1
            guard let g = groups.randomElement(), g.count > 2 else { continue }
            let before = pairs.count
            link(Int.random(in: g), Int.random(in: g))
            if pairs.count > before { added += 1 }
        }

        // 2. Layout: one ring per component, walked breadth-first.
        var pos = [CGPoint](repeating: .zero, count: n)
        let inset: CGFloat = 30
        let boxes: [CGRect] = groups.count == 1
            ? [rect.insetBy(dx: inset, dy: inset)]
            : [CGRect(x: rect.minX, y: rect.minY, width: rect.width / 2, height: rect.height)
                    .insetBy(dx: inset * 0.8, dy: inset),
               CGRect(x: rect.midX, y: rect.minY, width: rect.width / 2, height: rect.height)
                    .insetBy(dx: inset * 0.8, dy: inset)]

        for (gi, g) in groups.enumerated() where !g.isEmpty {
            let box = boxes[min(gi, boxes.count - 1)]
            let centre = CGPoint(x: box.midX, y: box.midY)
            // An ellipse, not a circle: a circle inscribed in a landscape canvas
            // is capped by the height and wastes the width, which pushed the
            // vertices closer together than they needed to be. Spreading them
            // over the full width buys real distance between neighbours.
            let rx = max(box.width / 2, 1)
            let ry = max(box.height / 2, 1)
            let order = breadthFirstOrder(of: g, adj: adj)

            if order.count == 1 {
                pos[order[0]] = centre
                continue
            }
            for (k, v) in order.enumerated() {
                // Start at the top and go clockwise; vertex 0 always sits there,
                // which makes "start from 0" easy to follow across a rerun.
                let angle = -CGFloat.pi / 2 + 2 * .pi * CGFloat(k) / CGFloat(order.count)
                pos[v] = CGPoint(x: centre.x + rx * cos(angle),
                                 y: centre.y + ry * sin(angle))
            }
        }

        let vertices = (0..<n).map { Vertex(id: $0, pos: pos[$0]) }
        let edges = pairs.map { Edge(from: $0.0, to: $0.1, a: pos[$0.0], b: pos[$0.1]) }
        return (vertices, edges)
    }

    /// Vertices of one component, in BFS order from its lowest index. Placing
    /// the ring in this order is what keeps connected vertices near each other.
    private static func breadthFirstOrder(of group: Range<Int>, adj: [[Int]]) -> [Int] {
        var seen = Set<Int>()
        var order: [Int] = []
        for root in group where !seen.contains(root) {
            var queue = [root]
            seen.insert(root)
            while !queue.isEmpty {
                let u = queue.removeFirst()
                order.append(u)
                for v in adj[u] where group.contains(v) && !seen.contains(v) {
                    seen.insert(v)
                    queue.append(v)
                }
            }
        }
        return order
    }

    // Listes d'adjacence : [u] -> [v1, v2, ...]
    static func adjacency(n: Int, edges: [Edge], directed: Bool) -> [[Int]] {
        var adj = Array(repeating: [Int](), count: n)
        for e in edges {
            adj[e.from].append(e.to)
            if !directed { adj[e.to].append(e.from) }
        }
        return adj
    }

    // Retrouve l'index d'une arête à partir des deux sommets.
    static func edgeMap(n: Int, _ edges: [Edge]) -> [Int: Int] {
        var m: [Int: Int] = [:]
        for (i, e) in edges.enumerated() {
            m[e.from * n + e.to] = i
            m[e.to * n + e.from] = i
        }
        return m
    }

    /// Connexe ssi tous les sommets sont atteints depuis `start` (non orienté).
    static func isConnected(n: Int, _ adj: [[Int]], from start: Int = 0) -> Bool {
        guard n > 0 else { return true }
        var seen = [Bool](repeating: false, count: n)
        var stack = [start]; seen[start] = true; var visited = 1
        while let u = stack.popLast() {
            for v in adj[u] where !seen[v] { seen[v] = true; visited += 1; stack.append(v) }
        }
        return visited == n
    }

    // MARK: - Animation BFS (étiquette = distance à la source)
    static func bfsFrames(_ s: Int, n: Int, _ adj: [[Int]], _ em: [Int: Int]) -> [GraphFrame] {
        var fill = [Color](repeating: .gray, count: n)
        var label = [String](repeating: "∞", count: n)
        var on = Set<Int>(); var fr: [GraphFrame] = []
        var dist = [Int](repeating: -1, count: n); var q = [s]

        dist[s] = 0; fill[s] = .cyan; label[s] = "0"
        fr.append(.init(fill: fill, label: label, on: on))

        while !q.isEmpty {
            let u = q.removeFirst()
            for v in adj[u] where dist[v] == -1 {
                dist[v] = dist[u] + 1
                label[v] = "\(dist[v])"; fill[v] = .cyan
                if let e = em[u * n + v] { on.insert(e) }
                fr.append(.init(fill: fill, label: label, on: on))
                q.append(v)
            }
            fill[u] = .green
            fr.append(.init(fill: fill, label: label, on: on))
        }
        // Les sommets d'une autre composante restent gris / ∞ : la déconnexion se voit.
        return fr
    }

    // MARK: - Animation DFS (étiquette = début/fin)
    static func dfsFrames(_ s: Int, n: Int, _ adj: [[Int]], _ em: [Int: Int]) -> [GraphFrame] {
        var fill = [Color](repeating: .gray, count: n)
        var label = [String](repeating: "∞", count: n)
        var on = Set<Int>(); var fr: [GraphFrame] = []
        var visited = [Bool](repeating: false, count: n); var time = 0

        func visit(_ u: Int) {
            visited[u] = true; time += 1
            label[u] = "\(time)/"; fill[u] = .orange
            fr.append(.init(fill: fill, label: label, on: on))

            for v in adj[u] where !visited[v] {
                if let e = em[u * n + v] { on.insert(e) }
                visit(v)
            }
            time += 1; label[u] += "\(time)"; fill[u] = .green
            fr.append(.init(fill: fill, label: label, on: on))
        }

        visit(s)
        for i in 0..<n where !visited[i] { visit(i) }  // relance -> forêt DFS
        return fr
    }
}

// MARK: - Vue réutilisable : rend un état figé (GraphFrame)

struct GraphFrameView: View {
    let vertices: [Vertex]
    let edges: [Edge]
    let frame: GraphFrame

    var body: some View {
        ZStack {
            ForEach(Array(edges.enumerated()), id: \.offset) { i, e in
                e.stroke(frame.on.contains(i) ? .orange : .gray.opacity(0.35),
                         lineWidth: frame.on.contains(i) ? 3 : 1)
            }
            ForEach(vertices) { v in
                Vertex(id: v.id, pos: v.pos, fill: frame.fill[v.id], label: frame.label[v.id])
            }
        }
        .frame(height: 220)
    }
}
