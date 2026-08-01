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

    @ViewBuilder
    private var vizContent: some View {
        switch type {
            
        case .darboux:
            DarbouxView(initial: .sine)
            
        case .sequence:
            SequenceView(.inverseN)
            
        case .derivative:
            DerivateView(initial: .sine)
            
        case .meanTheorem:
            MeanThmView(.cos3x)
            
        case .TFI:
            TFIView()
            
        case .TAF:
            TAFView(2)
            
        case .fixedPoint:
            FixedPointView(1)
            
     
        case .lhopital:     LHopitalView()
        case .sandwich:     SandwichView()
        case .taylor:       TaylorView()
        case .convergence:  ConvergenceView()
        case .trigo:
            TrigoView()
        case .complexNumbers:
            ComplexPlaneView()
        case .bijectivity:
            InjectionSurjectionView()
            

        case .matrixOperations: MatrixOperationsView()
        case .determinant: VectorSpaceView(is3D: false)
        case .vectorSpaces: VectorSpaceView(is3D: true)
        case .linearTransformations: Matrix3DView()
        case .gaussianElimination: GaussView()
        case .ker: ImageSpaceView()
        case .image: ImageSpaceView()
            
   
        case .combinatorics:        CombinatoricsView()
        case .permutations:         CombinatoricsView()
        case .binomialCoefficients: BinomialCoefficientsView()
        case .pigeonholePrinciple:  PigeonholePrincipleView()
        case .inclusionExclusion:   VennDiagramView()
        case .setOperations:        VennDiagramView()
        case .recurrenceRelations:  RecurrenceRelationsView()
        case .generatingFunctions:  RecurrenceRelationsView()
        case .probability:          ProbabilityView()
        case .expectation:          ExpectationView()
        case .propositionalLogic:   CNFView()
            
            
        case .whileLoop: WhileLoopView()
        case .forLoop: ForLoopView()
        case .ifStatement: IfElseView()
        case .bitwiseOperations: BitwiseView()
        case .recursion: RecurrenceRelationsView()
        case .variablesMemory: VariablesView()
        case .functions: FunctionView()
            
             
        case .sorting: 
            SortingView(algo: .insertion, shape: .random)
        case .quickSort:
            QuickSortView()
        case .search:
            BinarySearchView()
        case .kadane:
            KadaneView()
        case .dynamicProgramming:
            FibTreeView()
            

        case .DFS: DFSView(n: 6, connected: false)
        case .BFS: BFSView(n: 3, connected: true)
        case .prim: PrimView()
        case .kruskal: KruskalView()
        case .djikistra: DijkstraView()
        case .bellmanford: BellmanFordView()
        case .topologicalorder: TopoDFSView()
        
       
        }
    }

    var body: some View {
            GeometryReader { proxy in
                ScrollView {
                    vizContent
                        .frame(maxWidth: .infinity)
                }
                .clipped()
                .environment(\.plotWidth, proxy.size.width)
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
}

#Preview {
    VisualizationView(type: .variablesMemory, hint: "Observ the difference between F and G")
}
