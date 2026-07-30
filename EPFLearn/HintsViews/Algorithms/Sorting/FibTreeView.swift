//
//  FibTreeView.swift
//  EPFLearn
//

import SwiftUI
import Combine

// MARK: - Maths

private func fib(_ n: Int) -> Int {
    if n < 2 { return n }
    var a = 0, b = 1
    for _ in 2...n { (a, b) = (b, a + b) }
    return b
}

private func totalCalls(_ n: Int) -> Int { 2 * fib(n + 1) - 1 }   // nb de nœuds (naïf)
private func distinctSub(_ n: Int) -> Int { n <= 1 ? 1 : n + 1 }  // sous-problèmes distincts

private func colorFor(_ value: Int, max: Int) -> Color {
    Color(hue: Double(value) / Double(max + 1), saturation: 0.62, brightness: 0.92)
}

// MARK: - Modèle d'arbre

private final class FibNode {
    let value: Int
    let depth: Int
    var x: Double = 0
    var children: [FibNode] = []
    var callIndex = 0
    var memoKey = 0
    var isCacheHit = false
    var hiddenInMemo = false
    init(value: Int, depth: Int) { self.value = value; self.depth = depth }
}

private struct LayoutNode: Identifiable {
    let id: Int
    let leafX: Double
    let depth: Int
    let value: Int
    let callIndex: Int
    let memoKey: Int
    let isCacheHit: Bool
    let hiddenInMemo: Bool
    let childIDs: [Int]
}

private struct FibTree {
    let nodes: [LayoutNode]
    let byID: [Int: LayoutNode]
    let maxLeaf: Double
    let maxDepth: Int
    let totalNodes: Int
    let distinct: Int
}

private enum FibLayout {
    /// Coordonnées normalisées -> rect du Canvas (largeur dynamique, plus de taille figée).
    static func place(leafX: Double, depth: Int, maxLeaf: Double, maxDepth: Int, in rect: CGRect) -> CGPoint {
        let mx: CGFloat = 16, mt: CGFloat = 18, mb: CGFloat = 14
        let lx = CGFloat(leafX), ml = CGFloat(Swift.max(maxLeaf, 1))
        let x = rect.minX + mx + lx / ml * (rect.width - 2 * mx)
        let y = rect.minY + mt + CGFloat(depth) / CGFloat(Swift.max(maxDepth, 1)) * (rect.height - mt - mb)
        return CGPoint(x: x, y: y)
    }
}

private func nodeVisibility(_ node: LayoutNode, memoized: Bool, revealed: Int) -> (shown: Bool, faded: Bool) {
    if memoized && node.hiddenInMemo { return (false, false) }
    let key = memoized ? node.memoKey : node.callIndex
    return (key <= revealed, memoized && node.isCacheHit)
}

private func makeTree(n: Int) -> FibTree {
    func build(_ v: Int, depth: Int) -> FibNode {
        let node = FibNode(value: v, depth: depth)
        if v >= 2 {
            node.children = [build(v - 1, depth: depth + 1), build(v - 2, depth: depth + 1)]
        }
        return node
    }
    let root = build(n, depth: 0)

    // Position x : feuilles décalées d'un demi-pas → arbre centré
    var leaf = 0.0
    func assignX(_ node: FibNode) {
        if node.children.isEmpty { node.x = leaf + 0.5; leaf += 1 }
        else {
            node.children.forEach(assignX)
            node.x = node.children.map(\.x).reduce(0, +) / Double(node.children.count)
        }
    }
    assignX(root)

    // Annotation : simule l'exécution préfixe gauche→droite pour repérer cache / élagage
    var seen = Set<Int>()
    var order = 0
    var memoOrder = 0
    func annotate(_ node: FibNode, underCacheHit: Bool, parentMemo: Int) {
        order += 1
        node.callIndex = order
        if underCacheHit {
            node.hiddenInMemo = true
            node.children.forEach { annotate($0, underCacheHit: true, parentMemo: parentMemo) }
            return
        }
        if seen.contains(node.value) {
            node.isCacheHit = true
            node.memoKey = parentMemo
            node.children.forEach { annotate($0, underCacheHit: true, parentMemo: parentMemo) }
        } else {
            seen.insert(node.value)
            memoOrder += 1
            node.memoKey = memoOrder
            node.children.forEach { annotate($0, underCacheHit: false, parentMemo: memoOrder) }
        }
    }
    annotate(root, underCacheHit: false, parentMemo: 0)

    var nodes: [LayoutNode] = []
    func flatten(_ node: FibNode) {
        nodes.append(LayoutNode(
            id: node.callIndex, leafX: node.x, depth: node.depth, value: node.value,
            callIndex: node.callIndex, memoKey: node.memoKey,
            isCacheHit: node.isCacheHit, hiddenInMemo: node.hiddenInMemo,
            childIDs: node.children.map(\.callIndex)
        ))
        node.children.forEach(flatten)
    }
    flatten(root)

    return FibTree(
        nodes: nodes,
        byID: Dictionary(uniqueKeysWithValues: nodes.map { ($0.id, $0) }),
        maxLeaf: Swift.max(leaf, 1),
        maxDepth: Swift.max(n, 1),
        totalNodes: order,
        distinct: memoOrder
    )
}

// MARK: - Vue

struct FibTreeView: View {

    @State private var n: Double = 6
    @State private var memoized = false
    @State private var revealed = 0
    @State private var isPlaying = false

    private let timer = Timer.publish(every: 0.08, on: .main, in: .common).autoconnect()

    private var tree: FibTree { makeTree(n: Int(n)) }
    private var maxReveal: Int { memoized ? distinctSub(Int(n)) : totalCalls(Int(n)) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Dynamic Programming").font(.largeTitle.bold())

                treeSection
                costSection
                controlsSection
                explanationSection
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear { revealed = maxReveal }
        .onChange(of: memoized) { revealed = 0; isPlaying = true }    // bascule de mode → relance
        .onChange(of: n) { isPlaying = false; revealed = maxReveal }  // pendant le drag : redimensionne en direct
        .onReceive(timer) { _ in
            guard isPlaying else { return }
            guard revealed < maxReveal else { isPlaying = false; return }
            let stepSize = max(1, maxReveal / 40)   // ~40 frames quelle que soit la taille → durée constante
            revealed = min(revealed + stepSize, maxReveal)
        }
    }

    // MARK: Arbre

    private var treeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("fib(n) = fib(n−1) + fib(n−2)")
                .font(.system(.subheadline, design: .monospaced))
                .foregroundStyle(.secondary)

            Canvas { ctx, size in draw(ctx, size: size) }
                .frame(maxWidth: .infinity)
                .frame(height: 240)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.black))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            legend
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
    }

    /// Légende : au plus 9 pastilles (n ≤ 8), donc un simple HStack suffit — pas de ScrollView imbriquée.
    private var legend: some View {
        HStack(spacing: 8) {
            ForEach(0...Int(n), id: \.self) { v in
                HStack(spacing: 3) {
                    Circle().fill(colorFor(v, max: Int(n))).frame(width: 9, height: 9)
                    Text("f\(v)").font(.system(size: 10)).foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Tout est dessiné dans un Canvas : une seule passe, taille adaptative, pas de centaines de sous-vues.
    private func draw(_ ctx: GraphicsContext, size: CGSize) {
        let tree = self.tree
        let rect = CGRect(origin: .zero, size: size)
        let leaves = CGFloat(max(tree.maxLeaf, 1))
        let dia = min(22, max(4, (size.width - 32) / leaves * 0.85))

        func point(_ node: LayoutNode) -> CGPoint {
            FibLayout.place(leafX: node.leafX, depth: node.depth,
                            maxLeaf: tree.maxLeaf, maxDepth: tree.maxDepth, in: rect)
        }

        // Arêtes
        var solid = Path()
        var faded = Path()
        for node in tree.nodes {
            guard nodeVisibility(node, memoized: memoized, revealed: revealed).shown else { continue }
            let from = point(node)
            for cid in node.childIDs {
                guard let child = tree.byID[cid] else { continue }
                let cv = nodeVisibility(child, memoized: memoized, revealed: revealed)
                guard cv.shown else { continue }
                let to = point(child)
                if cv.faded { faded.move(to: from); faded.addLine(to: to) }
                else { solid.move(to: from); solid.addLine(to: to) }
            }
        }
        ctx.stroke(solid, with: .color(.white.opacity(0.28)), lineWidth: 1)
        ctx.stroke(faded, with: .color(.white.opacity(0.12)), lineWidth: 1)

        // Nœuds
        for node in tree.nodes {
            let v = nodeVisibility(node, memoized: memoized, revealed: revealed)
            guard v.shown else { continue }
            let p = point(node)
            let box = CGRect(x: p.x - dia / 2, y: p.y - dia / 2, width: dia, height: dia)
            let circle = Path(ellipseIn: box)

            ctx.fill(circle, with: .color(v.faded ? .white.opacity(0.18)
                                                 : colorFor(node.value, max: Int(n))))
            ctx.stroke(circle, with: .color(.white.opacity(v.faded ? 0.12 : 0.25)), lineWidth: 0.5)

            if dia >= 12 && !v.faded {
                var label = ctx.resolve(Text("\(node.value)")
                    .font(.system(size: dia * 0.55, weight: .bold)))
                label.shading = .color(.black)   // lisible sur les cercles clairs
                ctx.draw(label, at: p, anchor: .center)
            }
        }
    }

    // MARK: Coût

    private var costSection: some View {
        VStack(spacing: 12) {
            costRow(title: "Recursive (calls without memo)",
                    value: tree.totalNodes, color: .red, icon: "arrow.triangle.branch")
            Divider()
            costRow(title: "Distinct subproblems",
                    value: tree.distinct, color: .green, icon: "square.stack.3d.up")
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
    }

    private func costRow(title: String, value: Int, color: Color, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 32)
            Text(title).font(.subheadline)
            Spacer()
            Text("\(value)")
                .font(.title3.bold().monospacedDigit())
                .foregroundStyle(color)
                .contentTransition(.numericText())
        }
    }

    // MARK: Contrôles

    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Mode", selection: $memoized) {
                Text("Non-memoized").tag(false)
                Text("Memoized").tag(true)
            }
            .pickerStyle(.segmented)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("n = \(Int(n))").font(.subheadline.weight(.medium))
                    Spacer()
                    Text("\(min(revealed, maxReveal)) / \(maxReveal)")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                Slider(value: $n, in: 1...8, step: 1) { editing in
                    if !editing { revealed = 0; isPlaying = true }   // relâché → relance l'animation
                }
            }

            Button {
                if isPlaying { isPlaying = false }
                else { revealed = 0; isPlaying = true }
            } label: {
                Label(isPlaying ? "Pause" : "Replay",
                      systemImage: isPlaying ? "pause.fill" : "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
    }

    // MARK: Explication

    private var explanationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(memoized ? "Avec mémoïsation" : "Sans mémoïsation")
                .font(.headline)
            Text(memoized
                 ? "Chaque valeur n'est calculée qu'une seule fois : les branches grisées sont des cache hits, l'arbre se réduit à n+1 appels → O(n)."
                 : "Les mêmes sous-problèmes sont recalculés encore et encore : le nombre d'appels explose de façon exponentielle → O(φⁿ).")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
    }
}

#Preview {
    // Reproduit le contexte réel : VisualizationView enveloppe déjà la vue dans une ScrollView.
    ScrollView { FibTreeView() }
}
