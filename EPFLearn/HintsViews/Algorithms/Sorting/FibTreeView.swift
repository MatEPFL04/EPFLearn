
import SwiftUI
import Combine


private func fib(_ n: Int) -> Int {
    if n < 2 { return n }
    var a = 0, b = 1
    for _ in 2...n { (a, b) = (b, a + b) }
    return b
}

private func totalCalls(_ n: Int) -> Int { 2 * fib(n + 1) - 1 }           // nb de nœuds (naïf)
private func distinctSub(_ n: Int) -> Int { n <= 1 ? 1 : n + 1 }          // sous-problèmes distincts

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

// Coordonnées normalisées -> écran (comme ArrayView / FunctionDrawing mappent vers rect)
private enum FibLayout {
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

    // Position x : feuilles décalées d'un demi-pas (comme ArrayView : i + 0.5) → arbre centré
    var leaf = 0.0
    func assignX(_ node: FibNode) {
        if node.children.isEmpty { node.x = leaf + 0.5; leaf += 1 }
        else {
            node.children.forEach(assignX)
            node.x = node.children.map(\.x).reduce(0, +) / Double(node.children.count)
        }
    }
    assignX(root)

    // Annotation : simule l'exécution pré-fixe gauche→droite pour repérer cache / élagage
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
        maxLeaf: Swift.max(leaf, 1),        // = nb de feuilles → marges symétriques
        maxDepth: Swift.max(n, 1),
        totalNodes: order,
        distinct: memoOrder
    )
}

// MARK: - Arêtes (Shape, dans l'esprit d'ArrayView)

private struct FibEdges: Shape {
    let tree: FibTree
    let memoized: Bool
    let revealed: Int
    let drawFaded: Bool   // true : arêtes vers les cache hits ; false : arêtes pleines

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for node in tree.nodes {
            guard nodeVisibility(node, memoized: memoized, revealed: revealed).shown else { continue }
            let from = FibLayout.place(leafX: node.leafX, depth: node.depth,
                                       maxLeaf: tree.maxLeaf, maxDepth: tree.maxDepth, in: rect)
            for cid in node.childIDs {
                guard let child = tree.byID[cid] else { continue }
                let cv = nodeVisibility(child, memoized: memoized, revealed: revealed)
                guard cv.shown, cv.faded == drawFaded else { continue }
                let to = FibLayout.place(leafX: child.leafX, depth: child.depth,
                                         maxLeaf: tree.maxLeaf, maxDepth: tree.maxDepth, in: rect)
                path.move(to: from)
                path.addLine(to: to)
            }
        }
        return path
    }
}

// MARK: - Vue

struct FibTreeView: View {

    @State private var n: Double = 6
    @State private var memoized = false
    @State private var revealed = 0
    @State private var isPlaying = false

    private let viewW: CGFloat = 320
    private let viewH: CGFloat = 240
    private let timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()

    private var maxReveal: Int { memoized ? distinctSub(Int(n)) : totalCalls(Int(n)) }

    var body: some View {
        let tree = makeTree(n: Int(n))
        let rect = CGRect(x: 0, y: 0, width: viewW, height: viewH)
        let leaves = fib(Int(n) + 1)
        let dia: CGFloat = min(20, max(5, (viewW - 32) / CGFloat(max(leaves, 1)) * 0.85))

        return Form {
            Section {
                Text("fib(n) = fib(n−1) + fib(n−2)")
                    .font(.system(.subheadline, design: .monospaced))

                ZStack {
                    Color.black
                    FibEdges(tree: tree, memoized: memoized, revealed: revealed, drawFaded: false)
                        .stroke(Color.white.opacity(0.28), lineWidth: 1)
                    FibEdges(tree: tree, memoized: memoized, revealed: revealed, drawFaded: true)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)

                    ForEach(tree.nodes) { node in
                        let v = nodeVisibility(node, memoized: memoized, revealed: revealed)
                        if v.shown {
                            let p = FibLayout.place(leafX: node.leafX, depth: node.depth,
                                                    maxLeaf: tree.maxLeaf, maxDepth: tree.maxDepth, in: rect)
                            ZStack {
                                Circle()
                                    .fill(v.faded ? Color.white.opacity(0.18) : colorFor(node.value, max: Int(n)))
                                    .overlay(Circle().stroke(Color.white.opacity(v.faded ? 0.12 : 0.25), lineWidth: 0.5))
                                    .frame(width: dia, height: dia)
                                if dia >= 10 && !v.faded {
                                    Text("\(node.value)")
                                        .font(.system(size: dia * 0.55, weight: .bold))
                                        .foregroundStyle(.black)   // chiffres lisibles sur les cercles clairs
                                }
                            }
                            .position(p)
                        }
                    }
                }
                .frame(width: viewW, height: viewH)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.15), lineWidth: 0.5))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(0...Int(n), id: \.self) { v in
                            HStack(spacing: 3) {
                                Circle().fill(colorFor(v, max: Int(n))).frame(width: 9, height: 9)
                                Text("f\(v)").font(.system(size: 10))
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
            }

            Section("Coût") {
                VStack {
                    HStack {
                        Text("Recursive (calls without memo)")
                        Spacer()
                        Text("\(tree.totalNodes)").bold().foregroundStyle(.red)
                    }
                    HStack {
                        Text("Distinct subproblems"); Spacer()
                        Text("\(tree.distinct)").bold().foregroundStyle(.green)
                    }
                }
            }

            Section {
                Picker("Mode", selection: $memoized) {
                    Text("Non-memoized").tag(false)
                    Text("Memoized").tag(true)
                }
                .pickerStyle(.segmented)

                VStack(alignment: .leading) {
                    Text("n = \(Int(n))  —  \(tree.totalNodes) nœuds")
                    Slider(value: $n, in: 1...8, step: 1) { editing in
                        if !editing { revealed = 0; isPlaying = true }   // relâché → relance
                    }
                }
                Button(isPlaying ? "Pause" : "Replay") {
                    if isPlaying { isPlaying = false } else { revealed = 0; isPlaying = true }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { revealed = maxReveal }
        .onChange(of: memoized) { revealed = 0; isPlaying = true }    // bascule de mode → relance en direct
        .onChange(of: n) { isPlaying = false; revealed = maxReveal }  // pendant le drag : redimensionne en direct
        .onReceive(timer) { _ in
            guard isPlaying, revealed < maxReveal else { isPlaying = false; return }
            let stepSize = max(1, maxReveal / 50)   // ~50 frames quelle que soit la taille → durée constante
            revealed = min(revealed + stepSize, maxReveal)
        }
    }
}

#Preview {
    FibTreeView()
        .preferredColorScheme(.dark)
}
