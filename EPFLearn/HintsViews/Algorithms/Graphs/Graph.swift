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

    // Place `count` points bien répartis : grille (cellules ~carrées selon le
    // ratio de la zone) + jitter borné dans chaque cellule, puis mélange.
    // L'amplitude limitée du jitter garantit un écart minimum entre cellules
    // voisines (plus de nœuds collés). Signature + contrat identiques.
    private static func scatter(_ count: Int,
                                xRange: ClosedRange<CGFloat>,
                                yRange: ClosedRange<CGFloat>) -> [CGPoint] {
        guard count > 0 else { return [] }
        
        // Protection contre les ranges invalides
        guard xRange.lowerBound <= xRange.upperBound,
              yRange.lowerBound <= yRange.upperBound,
              xRange.lowerBound.isFinite, xRange.upperBound.isFinite,
              yRange.lowerBound.isFinite, yRange.upperBound.isFinite else {
            // Ranges invalides → grille simple centrée autour de (100, 100)
            let side = sqrt(Double(count)).rounded(.up)
            let spacing: CGFloat = 40
            var pts: [CGPoint] = []
            for i in 0..<count {
                let row = Int(i) / Int(side)
                let col = Int(i) % Int(side)
                pts.append(CGPoint(x: 100 + CGFloat(col) * spacing,
                                   y: 100 + CGFloat(row) * spacing))
            }
            pts.shuffle()
            return pts
        }
        
        let w = max(xRange.upperBound - xRange.lowerBound, 1)
        let h = max(yRange.upperBound - yRange.lowerBound, 1)

        // Cols proportionnels au ratio largeur/hauteur -> cellules quasi carrées.
        let aspect = Double(w / h)
        var cols: Int
        var rows: Int
        
        if aspect.isFinite && aspect > 0 {
            let colsCalc = (Double(count) * aspect).squareRoot().rounded()
            cols = colsCalc.isFinite ? max(1, Int(colsCalc)) : max(1, Int(sqrt(Double(count))))
            cols = min(cols, count)
            rows = Int(ceil(Double(count) / Double(cols)))
        } else {
            // Fallback : grille carrée
            cols = max(1, Int(ceil(sqrt(Double(count)))))
            rows = cols
        }

        let cw = w / CGFloat(cols)
        let ch = h / CGFloat(rows)
        
        // Protection finale contre les NaN dans les cellules
        guard cw.isFinite && ch.isFinite && cw > 0 && ch > 0 else {
            // Dernière ligne de défense : grille uniforme simple
            let side = sqrt(Double(count)).rounded(.up)
            let stepX = w / max(1, CGFloat(side))
            let stepY = h / max(1, CGFloat(side))
            var pts: [CGPoint] = []
            for i in 0..<count {
                let row = CGFloat(i) / CGFloat(side)
                let col = CGFloat(i).truncatingRemainder(dividingBy: CGFloat(side))
                pts.append(CGPoint(x: xRange.lowerBound + col * stepX + stepX / 2,
                                   y: yRange.lowerBound + row * stepY + stepY / 2))
            }
            pts.shuffle()
            return pts
        }

        // Jitter centre +/-j : deux cellules adjacentes restent separees d'au
        // moins (1 - 2j)*taille_cellule. j = 0.22 -> garde du desordre visuel
        // tout en assurant ~0.56 cellule de marge.
        let j: CGFloat = 0.22
        func jitter() -> CGFloat { CGFloat.random(in: (0.5 - j)...(0.5 + j)) }

        var cells: [CGPoint] = []
        for r in 0..<rows {
            for c in 0..<cols {
                let x = xRange.lowerBound + (CGFloat(c) + jitter()) * cw
                let y = yRange.lowerBound + (CGFloat(r) + jitter()) * ch
                // Vérification finale avant d'ajouter le point
                if x.isFinite && y.isFinite {
                    cells.append(CGPoint(x: x, y: y))
                }
            }
        }
        cells.shuffle()
        return Array(cells.prefix(count))
    }

    /// Génère un graphe. `connected == false` => deux composantes disjointes.
    static func generate(n: Int, extra: Int, connected: Bool = true,
                         in rect: CGRect) -> (vertices: [Vertex], edges: [Edge]) {
        let pad: CGFloat = 24
        let yRange = (rect.minY + pad)...(rect.maxY - pad)

        var pts: [CGPoint]
        var edges: [Edge] = []

        if connected || n < 2 {
            pts = scatter(n, xRange: (rect.minX + pad)...(rect.maxX - pad), yRange: yRange)
            if n > 1 {
                for child in 1..<n {                  // arbre couvrant -> connexe
                    let parent = Int.random(in: 0..<child)
                    edges.append(Edge(from: parent, to: child, a: pts[parent], b: pts[child]))
                }
                for _ in 0..<extra {                  // arêtes en plus (cycles)
                    let i = Int.random(in: 0..<n), j = (i + Int.random(in: 1..<n)) % n
                    edges.append(Edge(from: i, to: j, a: pts[i], b: pts[j]))
                }
            }
        } else {
            // Deux groupes : [0, split) à gauche, [split, n) à droite.
            let split = max(1, n / 2)
            let mid = rect.midX
            
            // S'assurer que les ranges sont valides (lowerBound < upperBound)
            let leftMin = rect.minX + pad
            let leftMax = max(leftMin + 1, mid - pad)
            let rightMin = max(leftMax + 1, mid + pad)
            let rightMax = max(rightMin + 1, rect.maxX - pad)
            
            let left  = scatter(split,     xRange: leftMin...leftMax, yRange: yRange)
            let right = scatter(n - split, xRange: rightMin...rightMax, yRange: yRange)
            pts = left + right

            func buildTree(_ range: Range<Int>) {
                guard range.count > 1 else { return }
                for child in (range.lowerBound + 1)..<range.upperBound {
                    let parent = Int.random(in: range.lowerBound..<child)
                    edges.append(Edge(from: parent, to: child, a: pts[parent], b: pts[child]))
                }
            }
            buildTree(0..<split)
            buildTree(split..<n)

            // Arêtes en plus, mais UNIQUEMENT à l'intérieur d'un groupe
            // (sinon on reconnecterait les deux composantes).
            for _ in 0..<extra {
                let range = Bool.random() ? 0..<split : split..<n
                guard range.count > 1 else { continue }
                let i = Int.random(in: range)
                var j = Int.random(in: range)
                if i == j { j = range.lowerBound + ((i - range.lowerBound + 1) % range.count) }
                edges.append(Edge(from: i, to: j, a: pts[i], b: pts[j]))
            }
        }

        let vertices = pts.enumerated().map { Vertex(id: $0.offset, pos: $0.element) }
        return (vertices, edges)
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
