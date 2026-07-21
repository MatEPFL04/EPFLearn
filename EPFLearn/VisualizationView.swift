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
        
        // Discrete Maths visualizations
        case .combinatorics: CombinatoricsView()
        case .permutations: CombinatoricsView()
        case .binomialCoefficients: BinomialCoefficientsView()
        case .pigeonholePrinciple: PigeonholePrincipleView()
        case .inclusionExclusion: CombinatoricsView()
        case .recurrenceRelations: RecurrenceRelationsView()
        case .generatingFunctions: RecurrenceRelationsView()
        case .probability: ExpectationView()
        case .expectation: ExpectationView()
        
        // Linear Algebra visualizations
        case .matrixOperations: MatrixOperationsView()
        case .determinant: DeterminantView()
        case .eigenvalues: EigenvalueView()
        case .vectorSpaces: VectorSpaceView()
        case .linearTransformations: LinearTransformationView()
        case .gaussianElimination: GaussianEliminationView()
        case .gramSchmidt: GramSchmidtView()
        case .svd: SVDView()
        case .diagonalization: DiagonalizationView()
        }
    }

    var body: some View {
        ScrollView {
            vizContent
                // .top plutôt que le centrage par défaut : sinon une vue plus
                // courte que 800pt (ex. TrigoView, ~600pt) se retrouve centrée
                // dans la boîte de 800, avec du vide au-dessus ET en dessous —
                // ce qui donne l'impression que la vue "descend" au chargement,
                // car la ScrollView démarre en haut de cet espace vide.
                .frame(minHeight: 800, alignment: .top)
        }
        .safeAreaInset(edge: .bottom) {
            if !hint.isEmpty {
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
