//
//  AdaptivePlot.swift
//  EPFLearn
//

import SwiftUI

// MARK: - Largeur disponible, injectée par le conteneur

private struct PlotWidthKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0     // 0 = personne n'a injecté (previews isolées)
}

extension EnvironmentValues {
    /// Largeur du conteneur qui affiche la visualisation.
    /// Renseignée une seule fois, dans VisualizationView, à partir d'un GeometryReader
    /// dont la taille ne dépend QUE de l'écran - jamais du contenu.
    var plotWidth: CGFloat {
        get { self[PlotWidthKey.self] }
        set { self[PlotWidthKey.self] = newValue }
    }
}

// MARK: - Modifier

struct AdaptivePlotModifier: ViewModifier {
    @Environment(\.plotWidth) private var plotWidth

    @Binding var size: CGFloat
    var minSize: CGFloat
    var maxSize: CGFloat
    var inset: CGFloat

    func body(content: Content) -> some View {
        content
            .onChange(of: plotWidth, initial: true) { _, width in
                guard width > 0 else { return }   // pas d'injection : on garde la valeur par défaut
                let available = width - inset
                let clamped = Swift.min(Swift.max(available, minSize), maxSize)
                // Dernière borne : jamais plus large que le conteneur. C'est ce qui empêche
                // le ZStack de QuestionView de s'élargir et de rogner le texte de la question.
                size = Swift.min(clamped, available)
            }
    }
}

extension View {
    /// Fait suivre à `size` la largeur du conteneur. Aucune mesure du contenu : insensible à la rotation.
    /// `max` used to be 420, which on a phone made the plot alone taller than
    /// half the screen and pushed every control below the fold. 300 keeps the
    /// plot, its picker and its sliders on one screen.
    func adaptivePlot(_ size: Binding<CGFloat>,
                      min minSize: CGFloat = 200,
                      max maxSize: CGFloat = 300,
                      inset: CGFloat = 32) -> some View {
        modifier(AdaptivePlotModifier(size: size, minSize: minSize, maxSize: maxSize, inset: inset))
    }
}
