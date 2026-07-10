//
//  VisualizationView.swift
//  EPFLearn
//
//  Created by Mat on 05.04.2026.
//
import SwiftUI

struct VisualizationView: View {
    let type: VisualizationType
    let hint: String
    let hintRevealed: Bool
    
    @ViewBuilder
    private var vizContent: some View {
        switch type {
        case .darboux:      DarbouxView()
        case .sequence:     SequenceView()
        case .derivative:   DerivateView()
        case .meanTheorem:  MeanThmView()
        case .TFI:          TFIView()
        case .fixedPoint:   FixedPointView()
        case .TAF:          TAFView()
        case .lhopital:     LHopitalView()
        case .sandwich:     SandwichView()
        case .taylor:       TaylorView()
        case .convergence:  ConvergenceView()
        case .trigo:
            TrigoView(mode: .reel)
        case .complexNumbers:
            TrigoView(mode: .complexe)
            
        case .sorting_zigzag: SortingView(algo: .insertion, shape: .zigzag)
        case .sorting_reverse_merge: SortingView(algo: .merge, shape: .reversed)
        case .sorting_bubble: SortingView(algo: .merge, shape: .random)
        case .quickSort: QuickSortView()
        case .sorting_basic: SortingView(algo: .merge, shape: .random)
        case .search: BinarySearchView()
        case .kadane: KadaneView()
        case .dynamicProgramming: FibTreeView()
            
        case .DFS: DFSView(n: 6, connected: false)
        case .BFS: BFSView(n: 3, connected: true)
        case .prim: PrimView()
        case .kruskal: KruskalView()
        case .djikistra: BellmanFordView()
        case .bellmanford: DijkstraView()
        case .topologicalorder: TopoDFSView()
        }
    }
    
    var body: some View {
        ScrollView {
            vizContent
                .frame(minHeight: 800)
        }
        .safeAreaInset(edge: .bottom) {
            if hintRevealed && !hint.isEmpty {
                Text(hint)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.regularMaterial)
            }
        }
    }
}

#Preview {
    VisualizationView(type: .search, hint: "Observe la diff entre F et G", hintRevealed: true)
}
