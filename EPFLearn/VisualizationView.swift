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
            FixedPointView(0)
            
     
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
        case .variablesMemory: VariablesView()
        case .functions: FunctionView()
        case .classes: ClassView()
        case .abstraction: AbstractionView()
            
             
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
        case .BFS: BFSView(n: 6, connected: true)
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
                        // On a tall screen (iPad) the content is often shorter
                        // than the viewport; centering it instead of pinning
                        // it to the top avoids a dead gap under the plot.
                        .frame(minHeight: proxy.size.height, alignment: .center)
                }
                .clipped()
                // One ground for every subject: the views used to differ on
                // whether they painted a background at all.
                .background(Color(.systemGroupedBackground))
                .environment(\.plotWidth, proxy.size.width)
                .safeAreaInset(edge: .bottom) {
                    if !hint.isEmpty {
                        HintCallout(text: hint)
                    }
                }
            }
        }
}

/// The hint used to be grey footnote text on a material bar and read as a
/// caption nobody was meant to act on. It is now a badged, orange-tinted
/// callout, collapsible so a long hint never swallows the view it points at.
struct HintCallout: View {
    let text: String
    @State private var expanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    expanded.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 22, height: 22)
                        .background(Circle().fill(.orange))

                    Text("HINT")
                        .font(.system(size: 11, weight: .heavy))
                        .kerning(1.2)
                        .foregroundStyle(.orange)

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.orange.opacity(0.7))
                        .rotationEffect(.degrees(expanded ? 0 : -90))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if expanded {
                Text(text)
                    .font(.callout)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 6)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.12))
        .background(.regularMaterial)
        .overlay(alignment: .top) {
            Rectangle().fill(.orange.opacity(0.5)).frame(height: 1)
        }
    }
}

#Preview {
    VisualizationView(type: .variablesMemory, hint: "Observ the difference between F and G")
}
