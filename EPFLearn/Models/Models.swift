//
//  Probabilities.swift
//  EPFLearn
//
//  Created by Mat on 04.04.2026.
//

import SwiftUI


enum Subject {
    case algebra, analysis
}
struct Question: Identifiable {
    let id = UUID()
    let subject: Subject
    let text: String
    let hint: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
    let visualization: VisualizationType
}

enum VisualizationType {
    case derivative
    case darboux
    case sequence
    case meanTheorem
    case TFI
    case fixedPoint
    case TAF
    case taylor
    case convergence
}

extension Question {
    static let sampleQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "Sur [0, 3], quand le nombre de subdivisions n augmente indéfiniment, que peut-on dire des sommes de Darboux S⁻ et S⁺ pour f(x) = x² ?",
            hint: "Joue avec le slider et observe la convergence",
            options: [
                "S⁻ et S⁺ divergent vers +∞",
                "S⁻ et S⁺ convergent toutes les deux vers ∫₀³ x² dx = 9",
                "S⁻ converge vers 0 et S⁺ diverge",
                "S⁺ − S⁻ reste constante quelle que soit la subdivision"
            ],
            correctIndex: 1,
            explanation: "Quand n → ∞, la largeur de chaque sous-intervalle tend vers 0. S⁻ et S⁺ encadrent l'intégrale et leur écart tend vers 0 : toutes deux convergent vers ∫₀³ x² dx = [x³/3]₀³ = 9. C'est le critère de Riemann pour l'intégrabilité de f.",
            visualization: .darboux
        ),
        Question(
            subject: .analysis,
            text: "Soit uₙ = cos(nπ/2). Vers combien de limites distinctes peut-on extraire des sous-suites convergentes ?",
            hint: "Liste les valeurs que prend uₙ — si une valeur apparaît infiniment souvent, on peut en extraire une sous-suite qui converge vers elle",
            options: [
                "Aucune, la suite diverge donc aucune sous-suite ne converge",
                "Exactement 1, Bolzano-Weierstrass garantit une unique sous-suite convergente",
                "Exactement 3",
                "Une infinité"
            ],
            correctIndex: 2,
            explanation: "uₙ cycle entre 1, 0, −1, 0, 1, ... Les indices n ≡ 0 mod 4 donnent toujours 1, les indices n ≡ 2 mod 4 donnent toujours −1, et les indices impairs donnent toujours 0. On a donc trois sous-suites constantes convergeant chacune vers une limite distincte. Bolzano-Weierstrass garantit l'existence d'au moins une, pas l'unicité.",
            visualization: .sequence
        ),
        Question(
            subject: .analysis,
            text: "Sur le graphique, fδ est construite via le TVM : les rectangles semblent mal ajustés à f. Que peut-on dire de leur aire totale ?",
            hint: "Regarde comment cₖ est choisi — c'est pas un point arbitraire comme dans Riemann",
            options: [
                "L'aire des rectangles est une approximation de ∫f, comme Riemann",
                "L'aire des rectangles est exactement ∫f, quelle que soit la subdivision",
                "L'aire est exacte seulement si les rectangles touchent la courbe",
                "L'aire est exacte seulement quand δ → 0"
            ],
            correctIndex: 1,
            explanation: "Visuellement ça choque — les rectangles semblent 'faux'. Mais cₖ n'est pas choisi au hasard : le TVM garantit que f(cₖ)·δ = ∫[xₖ,xₖ₊₁] f exactement. La hauteur du rectangle compense exactement les parties où il dépasse et où il manque la courbe.",
            visualization: .meanTheorem
        ),
        Question(
            subject: .analysis,
            text: "Pour quelle famille de fonctions le taux d'accroissement (f(x+h)-f(x))/h est-il exactement égal à f'(x) pour tout h ≠ 0 ?",
            hint: "Pense à la forme des fonctions dont la sécante coïncide toujours avec la tangente",
            options: [
                "Les fonctions constantes uniquement",
                "Les fonctions affines f(x) = ax + b",
                "Les polynômes de degré ≤ 2",
                "Toutes les fonctions dérivables"
            ],
            correctIndex: 1,
            explanation: "Pour f(x) = ax+b, (f(x+h)-f(x))/h = a = f'(x) exactement. Pour tout polynôme de degré ≥ 2 il reste un terme en h qui ne disparaît qu'à la limite.",
            visualization: .derivative
        ),
        Question(
            subject: .analysis,
            text: "Soit f, g continues sur [a,b]. Laquelle de ces conditions garantit f = g sur [a,b] ?",
            hint: "Pense au théorème fondamental du calcul — que se passe-t-il si tu dérivés ∫[a,x] f ?",
            options: [
                "∫[a,b] f = ∫[a,b] g",
                "∫[a,x] f = ∫[a,x] g pour tout x ∈ [a,b]",
                "∫[a,b] f² = ∫[a,b] g²",
                "∫[a,b] |f| = ∫[a,b] |g|"
            ],
            correctIndex: 1,
            explanation: "L'option A est fausse : f(x)=x et g(x)=-x sur [-1,1] donnent ∫f = ∫g = 0 mais f ≠ g. L'option B est vraie : si F(x) = ∫[a,x] f = ∫[a,x] g = G(x) pour tout x, alors en dérivant F'(x) = f(x) = G'(x) = g(x) par le théorème fondamental. Les options C et D sont fausses : f et -f ont mêmes intégrales de f² et |f|.",
            visualization: .TFI
        ),
        Question(
            subject: .analysis,
            text: "Combien de points C le TAF garantit-il ?",
            hint: "Relis l'énoncé exact du théorème",
            options: [
                "Exactement un",
                "Au moins un",
                "Au plus un",
                "Autant que de zéros de f"
            ],
            correctIndex: 1,
            explanation: "Le TAF garantit l'existence d'au moins un C — pas son unicité. Sur sin(2πx), il peut en exister plusieurs simultanément.",
            visualization: .TAF
        ),
        Question(
            subject: .analysis,
            text: "Sur quel intervalle l'erreur du développement de Taylor d'ordre 3 de sin(x) reste-t-elle inférieure à 0.1 ?",
            hint: "T₃(x) = x − x³/6 — regarde où la courbe rouge dépasse le seuil",
            options: ["[-π/4, π/4]", "[-π/2, π/2]", "[-π, π]", "[-2, 2]"],
            correctIndex: 1,
            explanation: "L'erreur |sin(x) − T₃(x)| dépasse 0.1 aux alentours de ±π/2. Au delà, le terme d'ordre 5 manquant devient trop grand pour être négligé.",
            visualization: .taylor
        ),
        Question(
            subject: .analysis,
            text: "Pour uₙ = sin(n)/n avec ε = 0.1, un étudiant trouve N = 30 et conclut à la convergence. Quelle affirmation est correcte ?",
            hint: "Cherche à partir de quel rang tous les points restent dans la bande ε = 0.1",
            options: [
                "La démarche est complète — N = 30 convient même s'il en existe de plus petits",
                "La démarche est incomplète — N = 30 est trop grand, il faut le plus petit N possible",
                "La démarche est incomplète — un seul ε ne suffit pas",
                "La démarche est complète — sin(n)/n est bornée donc converge forcément"
            ],
            correctIndex: 2,
            explanation: "Pour un ε fixé, N = 30 est parfaitement valide — la définition n'exige pas le plus petit N. Mais ça ne suffit pas à conclure à la convergence : il faut que pour tout ε > 0, un tel N existe. Vérifier ε = 0.1 n'est qu'un cas particulier. Sur le graphique, réduis ε progressivement : N augmente, mais existe toujours — c'est ça qui prouve la convergence.",
            visualization: .convergence
        )
        
    ]
}
