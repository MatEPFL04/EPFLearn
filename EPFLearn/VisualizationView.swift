//
//  VisualizationView.swift
//  EPFLearn
//
//  Created by Mat on 05.04.2026.
//

import SwiftUI

struct VisualizationView: View {
    let type: VisualizationType
    
    var body: some View {
        switch type {
        case .darboux:
            FunctionView(hint: "En jouant avec la taille de la subdivision, remarquez le critère de convergence")
        case .sequence:
            SequenceView()
        case .derivative:
            DerivateView()
        case .meanTheorem:
            MeanThmView()
        case .TFI:
            TFIView()
        case .fixedPoint:
            FixedPointView()
        case .TAF:
            TAFView()
        case .taylor:
            TaylorView()
        case .convergence:
            ConvergenceView()
        }
    }
    
}
#Preview {
    VisualizationView(type: .TFI)
}
