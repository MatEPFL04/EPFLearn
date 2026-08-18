//
//  AnalysisQuestions.swift
//  LearnViz
//

extension Question {

    // MARK: - Complex plane

    static let complexPlaneQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "z₂ has modulus 1 and argument θ₂. Geometrically, what does multiplying z₁ by z₂ do to z₁?",
            hint: "Select '•' in the operation picker, set r₂ = 1 and turn θ₂: watch whether the product changes length, direction, or both.",
            options: [
                "A translation by z₂",
                "A rotation by θ₂",
                "A reflection across the direction of z₂",
                "A projection onto z₂"
            ],
            correctIndex: 1,
            explanation: "Moduli multiply and arguments add: |z₁z₂| = r₁ • 1 = r₁ (same moduli)  and arg(z₁ • z₂) = θ₁ + θ₂. Addition is the parallelogram, multiplication is rotate then stretch.",
            visualization: .complexNumbers
        ),
        Question(
            subject: .analysis,
            text: "For nonzero z₁, z₂, when does |z₁ + z₂| = |z₁| + |z₂| hold exactly?",
            hint: "Select '+' in the operation picker and turn θ₂ until the parallelogram flattens: that is the only case where the lengths add.",
            options: [
                "Only when z₁ and z₂ are conjugates",
                "Only when θ₁ = θ₂, so z₂ is a positive multiple of z₁",
                "Only when θ₂ = θ₁ + π",
                "For any z₁ and z₂"
            ],
            correctIndex: 1,
            explanation: "This is the equality case of the triangle inequality. Any angle between the two vectors gives the parallelogram real width, and the sum comes out strictly shorter.",
            visualization: .complexNumbers
        ),
        Question(
            subject: .analysis,
            text: "z₂ is replaced by a number with the same modulus r₂ but argument θ₂ + π. What happens to the product z₁ • z₂?",
            hint: "Select '•' in the operation picker, push θ₂ half a turn and compare the length and the direction of the product before and after.",
            options: [
                "Its modulus doubles",
                "It flips to the opposite direction, same modulus",
                "It becomes purely imaginary",
                "Nothing changes, since the modulus only depends on r₁ and r₂"
            ],
            correctIndex: 1,
            explanation: "Adding π multiplies z₂ by eⁱᶿ = −1. The argument shifts by π while |z₁ • z₂| = r₁r₂ stays put.",
            visualization: .complexNumbers
        ),
        Question(
            subject: .analysis,
            text: "Let θ₁ = 3π/4, θ₂ = 3π/2 angles for the two numbers z₁, z₂ (both are unitary). What is arg(z₁ • z₂) ?",
            hint: "Add the two angles yourself, then bring the total back inside one turn. The view is there to confirm it.",
            options: ["9π/4", "π/4", "5π/4", "−3π/4"],
            correctIndex: 1,
            explanation: "3π/4 + 3π/2 = 9π/4, which sits past 2π. Subtracting 2π brings it back to π/4.",
            visualization: .complexNumbers
        ),
    ]



    static let trigoQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "For θ ∈ [0, 2π], how many values satisfy sin θ = −cos θ?",
            hint: "Sweep θ in the view and stop where the two coordinate bars have the same length but opposite signs.",
            options: ["1", "2", "3", "4"],
            correctIndex: 1,
            explanation: "sin θ = −cos θ means tan θ = −1, which happens once per half-turn: θ = 3π/4 and θ = 7π/4. On the circle these are the two points on the falling diagonal.",
            visualization: .trigo
        ),
        Question(
            subject: .analysis,
            text: "For θ ∈ [0, 2π], how many values satisfy sin θ = cos θ, and where are they?",
            hint: "Sweep θ and stop wherever the two bars match in length and sign: count how many times that happens.",
            options: [
                "1: only θ = π/4",
                "2: θ = π/4 and θ = 5π/4",
                "2: θ = π/4 and θ = 3π/4",
                "4, one per quadrant"
            ],
            correctIndex: 1,
            explanation: "sin θ = cos θ means tan θ = 1. A line through the centre cuts the circle twice, half a turn apart: θ = π/4 (both coordinates positive) and θ = 5π/4 (both negative).",
            visualization: .trigo
        ),
        Question(
            subject: .analysis,
            text: "For θ ∈ [0, 2π], how many intervals satisfy |sin θ| > |cos θ|?",
            hint: "Sweep θ through a full turn and mark the arcs where the vertical bar is the taller of the two.",
            options: [
                "1 interval, a quarter of the circle",
                "2 intervals, a quarter of the circle",
                "2 intervals, half the circle",
                "4 intervals, three quarters of the circle"
            ],
            correctIndex: 2,
            explanation: "The vertical coordinate wins between the 45° diagonals: the arc (π/4, 3π/4) at the top and (5π/4, 7π/4) at the bottom. Two arcs covering half the circle.",
            visualization: .trigo
        ),
        Question(
            subject: .analysis,
            text: "For θ ∈ [0, 2π], on what fraction of the circle is sin θ > 3 cos θ?",
            hint: "Sweep θ until the vertical bar is three times the horizontal one, then find the second angle where that repeats.",
            options: [
                "A quarter",
                "A third",
                "Half",
                "It depends on the factor 3"
            ],
            correctIndex: 2,
            explanation: "The two boundary angles are diametrically opposite, so the line joining them cuts the circle into two equal arcs and the inequality holds on one of them. The factor 3 tilts that line but never changes the split: any k gives half.",
            visualization: .trigo
        ),
    ]


    static let darbouxQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "For f(x) = 10 cos(x/5) on a symmetric interval around 0, what happens to S⁻ and S⁺ as the number of pieces grows?",
            hint: "Select 'f(x) = 10 cos(x/5)' in the function picker, then press + and watch the two sums S⁻ and S⁺ close on each other.",
            options: [
                "Both diverge to +∞",
                "Both converge to ∫I f",
                "S⁻ goes to 0 and S⁺ to something nonzero",
                "S⁺ − S⁻ stays constant"
            ],
            correctIndex: 1,
            explanation: "The two sums always trap the integral, and their gap shrinks with the width of the pieces because a continuous function is Riemann-integrable.",
            visualization: .darboux
        ),
        Question(
            subject: .analysis,
            text: "f(x) = 1 on rationals, 0 elsewhere. What are S⁻ and S⁺ on an interval [a, b], for any subdivision?",
            hint: "Pick 'f(x) = 1 on ℚ, 0 elsewhere' in the function picker, then press + as far as it goes: watch whether the two sums ever approach.",
            options: [
                "S⁻ = 0 and S⁺ = b − a",
                "S⁻ = S⁺ = (b − a)/2",
                "S⁻ = S⁺ = b − a",
                "It depends on how fine the subdivision is"
            ],
            correctIndex: 0,
            explanation: "Every rational is arbitrarily close to an irrational and vice versa, so every piece has infimum 0 and supremum 1 no matter how short it is. Summing gives S⁻ = 0 and S⁺ = 1 × (b − a) at every depth. The gap never closes, so the function is not Riemann integrable.",
            visualization: .darboux
        ),
        Question(
            subject: .analysis,
            text: "On a subdivision P, S⁻ adds up the smallest value f takes on each piece and S⁺ the largest. You now cut every piece in two, giving a finer subdivision P′. Which way do the two sums move?",
            hint: "With any function selected, press + on the refinement control once: it splits every piece in two. Watch the lower staircase and the upper one separately, and note which way each of them can move.",
            options: [
                "S⁻(P′) ≤ S⁻(P) and S⁺(P′) ≥ S⁺(P)",
                "S⁻(P′) ≥ S⁻(P) and S⁺(P′) ≤ S⁺(P)",
                "Both stay the same",
                "It depends on how smooth f is"
            ],
            correctIndex: 1,
            explanation: "Smaller pieces can only raise an infimum and lower a supremum. Refining pushes S⁻ up and S⁺ down.",
            visualization: .darboux
        ),
        Question(
            subject: .analysis,
            text: "For a constant f(x) = c on [a, b], what are S⁻ and S⁺?",
            hint: "Select 'f(x) = 5' in the function picker, then press + and −: watch how the two staircases sit relative to each other.",
            options: [
                "S⁻ = S⁺ = c(b − a), for every subdivision",
                "S⁻ = 0 and S⁺ = c(b − a)",
                "They depend on the subdivision",
                "S⁻ = S⁺ = c"
            ],
            correctIndex: 0,
            explanation: "Infimum and supremum are both c on every piece, so both sums equal c(b − a). The gap is zero from the very first subdivision, and refining cannot improve on it.",
            visualization: .darboux
        ),
    ]


    static let bijectivityQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "Why is f: ℝ → ℝ, f(x) = x² neither injective nor surjective?",
            hint: "Select 'x²  on ℝ' in the picker, slide the horizontal line to y = 4 and count crossings, then to y = −1 and count again.",
            options: [
                "f(−2) = f(2) = 4, and no negative number has a preimage",
                "It does not pass through the origin",
                "Its derivative vanishes at 0",
                "It is continuous on its domain"
            ],
            correctIndex: 0,
            explanation: "Two preimages for 4 kills injectivity. No square is negative, so −1 has no preimage at all.",
            visualization: .bijectivity
        ),
        Question(
            subject: .analysis,
            text: "f(x) = x² fails on ℝ → ℝ both ways, while g: ℝ⁺ → ℝ⁺, g(x) = x² is a bijection. Which cut repairs which failure?",
            hint: "Compare 'x²  on ℝ' with 'x²  on ℝ₊' while sweeping the line: count its crossings, then look at the red part of the ruler on the left edge.",
            options: [
                "Cutting the domain restores injectivity, cutting the codomain restores surjectivity",
                "Cutting the domain restores surjectivity, cutting the codomain restores injectivity",
                "Cutting the domain alone already gives both",
                "Cutting the codomain alone already gives both"
            ],
            correctIndex: 0,
            explanation: "Dropping the negative inputs removes the second preimage of every positive height, which is injectivity. Dropping the negative outputs removes the heights nothing reaches, which is surjectivity. One cut per failure, and only both together make g a bijection.",
            visualization: .bijectivity
        ),
        Question(
            subject: .analysis,
            text: "f: A → B is injective if and only if:",
            hint: "Select 'x²  on ℝ' and sweep the line: injectivity is a statement about how many crossings you are ever allowed.",
            options: [
                "For every y in B there is a unique x with f(x) = y",
                "For all x₁, x₂ in A, f(x₁) = f(x₂) implies x₁ = x₂",
                "For every y in B there is at least one x with f(x) = y",
                "For every x in A, f(x) is unique"
            ],
            correctIndex: 1,
            explanation: "∀(x₁, x₂) ∈ A², f(x₁) = f(x₂) ⇒ x₁ = x₂. By contraposition: distinct inputs give distinct outputs.",
            visualization: .bijectivity
        ),
        Question(
            subject: .analysis,
            text: "f: ℝ → ℝ is continuous and strictly increasing, and nothing is known about its limits at ±∞. Which of these holds for every such f?",
            hint: "Compare 'x³' with 'eˣ  onto ℝ₊' in the picker: both are continuous and strictly increasing, yet x³ reaches every height of ℝ while eˣ reaches only the positive ones. Sweep the line on each and look for the one thing both cases share.",
            options: [
                "Injective but not surjective",
                "Surjective only",
                "Bijective from ℝ onto its image f(ℝ)",
                "It cannot be modelled continuously"
            ],
            correctIndex: 2,
            explanation: "Strict monotonicity gives injectivity, so the only question left is what f reaches. x³ is onto all of ℝ, eˣ is onto ℝ₊ only: surjectivity onto ℝ can be neither claimed nor ruled out, which is why 'injective but not surjective' is wrong too. What survives in both cases is that f is a bijection onto its own image f(ℝ).",
            visualization: .bijectivity
        ),
    ]

    static let derivativeQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "For which functions is (f(x+h) − f(x))/h exactly f'(x) for every h ≠ 0?",
            hint: "Select 'piecewise-defined' in the function picker and put both points on its straight half: does moving them apart change either tile?",
            options: [
                "Constant functions only",
                "Polynomials of degree ≤ 2",
                "All differentiable functions",
                "Affine functions f(x) = ax + b"
            ],
            correctIndex: 3,
            explanation: "For ax + b the quotient is a whatever h is. Degree 2 or more leaves a term in h that only vanishes in the limit.",
            visualization: .derivative
        ),
        Question(
            subject: .analysis,
            text: "f is odd. You read the secant slope at x, then at −x. What do you find?",
            hint: "Select '6 sin(x/2)', which is odd, read the tangent tile at x, then read it again at −x.",
            options: [
                "Opposite slopes, since f is odd",
                "Equal slopes, so the two tangents are parallel",
                "Slopes that are opposite only when x > 0",
                "Nothing predictable without the formula"
            ],
            correctIndex: 1,
            explanation: "f(−x) = −f(x) differentiates to −f'(−x) = −f'(x), so f'(−x) = f'(x). The derivative of an odd function is even, and the two tangents come out parallel even though the curve looks flipped.",
            visualization: .derivative
        ),
        Question(
            subject: .analysis,
            text: "|x| has a corner at 0. What does that mean analytically?",
            hint: "Select '|x|' and bring the tangent point to 0 from the right, then from the left: compare the tiles.",
            options: [
                "|x| is not continuous at 0",
                "The quotient is 1 for h > 0 and −1 for h < 0",
                "|x| is differentiable at 0 with f'(0) = 0",
                "The quotient diverges to +∞"
            ],
            correctIndex: 1,
            explanation: "Both one sided limits exist and disagree, so the limit of the quotient does not. |x| is continuous at 0 but not differentiable there.",
            visualization: .derivative
        ),
        Question(
            subject: .analysis,
            text: "If f is even, what can we say about f'?",
            hint: "Select 'x⁴/500 − 3x²/10', which is even, and compare the tangent tile at x with the one at −x.",
            options: [
                "f' is even too",
                "f' is odd",
                "f' is even only for polynomials",
                "Nothing without computing"
            ],
            correctIndex: 1,
            explanation: "f(−x) = f(x) differentiates to −f'(−x) = f'(x), so f' is odd. One consequence: an even function always has a horizontal tangent at 0.",
            visualization: .derivative
        ),
    ]


    static let sequenceQuestions: [Question] = [
    
        Question(
                subject: .analysis,
                text: "On uₙ = 1/n you keep only the terms whose index is a perfect square. Where does that subsequence go?",
                hint: "Select '1/n' in the sequence picker and slide n out: check whether any choice of dots could avoid the dashed limit line.",
                options: [
                    "To 0",
                    "Away from 0, since perfect squares are sparse",
                    "It depends on the pattern of indices chosen",
                    "It does not converge"
                ],
                correctIndex: 0,
                explanation: "The whole sequence converges to 0, so every subsequence converges to 0 as well. Picking sparse indices only makes it arrive faster, never elsewhere. This is the contrast with cos(nπ/2), where the choice of indices decides the limit.",
                visualization: .sequence
            ),
        Question(
                subject: .analysis,
                text: "uₙ = (−1)ⁿ·n/(n+1) has +1 and −1 as subsequential limits. How many terms are actually equal to 1?",
                hint: "Select '(−1)ⁿ · n/(n+1)' in the sequence picker, slide to an even n and compare the readout with the dashed line above it.",
                options: [
                    "Exactly one",
                    "None",
                    "Infinitely many, every even one",
                    "All of them past a certain rank"
                ],
                correctIndex: 1,
                explanation: "n/(n+1) is strictly below 1 for every n, so the dots creep toward the dashed line without ever touching it. A limit of a subsequence need not be a value the sequence takes.",
                visualization: .sequence
            ),
        Question(
                subject: .analysis,
                text: "uₙ = cos(nπ/2). How many distinct limits can convergent subsequences reach?",
                hint: "Select 'cos(nπ/2)' in the sequence picker and slide n forward: count the distinct heights the dots keep returning to.",
                options: [
                    "None, since uₙ diverges",
                    "Exactly 1",
                    "Exactly 3",
                    "Infinitely many"
                ],
                correctIndex: 2,
                explanation: "The terms cycle through 1, 0, −1, 0. Three values recur infinitely often, giving three constant subsequences.",
                visualization: .sequence
            ),
        Question(
            subject: .analysis,
            text: "On (−1)ⁿ·n/(n+1), how far apart are two consecutive terms when n is large?",
            hint: "Select '(−1)ⁿ · n/(n+1)' in the sequence picker and slide n out: each term sits close to +1 or −1, and consecutive terms sit on opposite sides.",
            options: [
                "They get closer and closer",
                "The gap stays near 1",
                "The gap grows toward 2",
                "The gap keeps changing with no pattern"
            ],
            correctIndex: 2,
            explanation: "One term sits just under 1 and the next just above −1, so the gap approaches 2. Consecutive terms never settle near each other, which is exactly what stops the sequence from converging.",
            visualization: .sequence
        ),
    ]
    
    static let meanTheoremQuestions: [Question] = [

        Question(
            subject: .analysis,
            text: "The mean value theorem for integrals says: for f continuous on [a, b] there is a point c in [a, b] with f(c)·(b − a) = ∫ₐᵇ f. What is that height f(c)?",
            hint: "Set the view to 1 section: the single rectangle has the same area as the region under the curve. What must its height be?",
            options: [
                "The average height of f over [a, b]",
                "The largest value of f on [a, b]",
                "The value of f at the midpoint (a + b)/2",
                "The slope of f somewhere in [a, b]"
            ],
            correctIndex: 0,
            explanation: "Dividing by (b − a) gives f(c) = (1/(b−a))·∫ₐᵇ f, which is exactly the average value of f. The theorem says a continuous f actually attains that average somewhere.",
            visualization: .meanTheorem
        ),

        Question(
            subject: .analysis,
            text: "On any interval, the mean value theorem for integrals guarantees at least one c where f equals that interval's average height. For which f is that c always the only one?",
            hint: "Set 2 sections and count the orange dots inside a single rectangle. Compare 'x³/8 + x/2', which only climbs, with '0.5x + sin(2x)', which turns back on itself.",
            options: [
                "Any strictly monotone f",
                "Any continuous f",
                "Any positive f",
                "Any differentiable f"
            ],
            correctIndex: 0,
            explanation: "Existence is all the theorem gives. A strictly increasing or decreasing f passes each height only once, so its c is unique on every interval; a curve that turns back on itself can reach that height several times.",
            visualization: .meanTheorem
        ),
    ]
    

    static let TFIQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "F(x) = ∫₀ˣ 2t dt collects the area under the line y = 2t. F(0) = 0, since nothing has been collected yet. What is F(3)?",
            hint: "Set integrand 2t, a = 0, b = 3: the shaded region is a triangle. What are its base and its height?",
            options: ["9", "6", "3", "18"],
            correctIndex: 0,
            explanation: "The region is a triangle of base 3 and height 2·3 = 6, so its area is 3·6/2 = 9. The antiderivative agrees: F(x) = x² gives F(3) = 9.",
            visualization: .TFI
        ),
        Question(
            subject: .analysis,
            text: "An antiderivative of t² is F(t) = t³/3. What is ∫₁² t² dt?",
            hint: "Set integrand t², a = 1, b = 2: the box gives you F(t), the shaded region is what it measures.",
            options: ["7/3", "3", "8/3", "1/3"],
            correctIndex: 0,
            explanation: "∫₁² t² dt = F(2) − F(1) = 8/3 − 1/3 = 7/3 ≈ 2.33. Any other antiderivative differs by a constant, which cancels in the subtraction.",
            visualization: .TFI
        ),
        Question(
            subject: .analysis,
            text: "F(x) = ∫₀ˣ (t − 1) dt. The integrand t − 1 is negative before t = 1 and positive after it. What does F do?",
            hint: "Set integrand t − 1 and slide b past 1: watch the shaded region switch from below the axis to above it.",
            options: [
                "It falls until x = 1, then rises again",
                "It rises the whole way",
                "It falls the whole way",
                "It stays flat after x = 1"
            ],
            correctIndex: 0,
            explanation: "F grows where the integrand is positive and shrinks where it is negative, since F′ = f. So F slides down while t − 1 < 0, bottoms out at x = 1, and climbs once the integrand turns positive.",
            visualization: .TFI
        ),
        Question(
            subject: .analysis,
            text: "f and g agree on [0, 2] and nothing is known about them elsewhere. F(x) = ∫₀ˣ f and G(x) = ∫₀ˣ g. For which x is F(x) = G(x) certain?",
            hint: "Switch to 'F vs G' and slide x both ways: the two shaded regions coincide exactly while the whole stretch from 0 to x stays inside the zone where f and g agree.",
            options: [
                "For 0 ≤ x ≤ 2",
                "For every x ≤ 2, negative x included",
                "Only at x = 0",
                "For every x, since both start at 0"
            ],
            correctIndex: 0,
            explanation: "F(x) − G(x) is the integral of f − g from 0 to x, so it is zero exactly when the whole stretch travelled sits where f = g. That is [0, 2]. For x < 0 the integral runs over ground where f and g were never compared, so nothing is guaranteed there either.",
            visualization: .TFI
        )
    ]

    
    static let TAFQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "How many points c does the mean value theorem guarantee?",
            hint: "Select 'cos(πx)' in the function picker and widen a and b: count the tangents that come out parallel to the straight line joining the two endpoints.",
            options: ["Exactly one", "At least one", "At most one", "As many as f has zeros"],
            correctIndex: 1,
            explanation: "At least one. Uniqueness is never claimed, and sin(2πx) shows several at once.",
            visualization: .TAF
        ),
        
        Question(
                subject: .analysis,
                text: "f is differentiable on ℝ and has a constant derivative f'(x). According to the Mean Value Theorem , what happens on any interval ]a, b[?",
                hint: "Select '0.5x + 0.2 (Affine)' in the function picker and move a and b anywhere: compare the slope between a and b with the slope of the tangent.",
                options: [
                    "Only the midpoint c = (a + b)/2 works",
                    "Every c in ]a, b[ works",
                    "No c works, since the curve has no curvature",
                    "The theorem fails: the tangent and the line coincide"
                ],
                correctIndex: 1,
                explanation: "Since f'(x) = k everywhere, the tangent slope is always k. The slope between a and b, (f(b) − f(a))/(b − a), is k as well, so f'(c) = that slope holds at every point c of the interval.",
                visualization: .TAF
            ),
        Question(
               subject: .analysis,
               text: "What happens to the Mean Value Theorem if the function has a sharp corner inside the interval [a, b]?",
               hint: "Select '|x|' in the function picker and place a and b on either side of 0: try to find a tangent parallel to the line joining the endpoints.",
               options: [
                   "It still holds, since f is still continuous",
                   "It can fail: f′ does not exist at the corner",
                   "It holds only if the corner sits at the midpoint",
                   "The slope between a and b doubles to compensate"
               ],
               correctIndex: 1,
               explanation: "The Mean Value Theorem strictly requires the function to be differentiable on the open interval ]a, b[. A sharp corner means the derivative does not exist at that point, which can prevent you from finding any parallel tangent.",
               visualization: .TAF
           ),
        
        Question(
            subject: .analysis,
            text: "Take f(x) = cos(πx) on the interval [a, b] = [−1, 1]. Which special case of the Mean Value Theorem applies?",
            hint: "Select 'cos(πx)' in the function picker and set a = −1, b = 1: the line joining the endpoints goes flat, so watch what the tangent at c has to do.",
            options: [
                "Rolle's theorem: f(a) = f(b), so f′(c) = 0 somewhere",
                "The theorem does not apply here",
                "The fundamental theorem of calculus",
                "No c exists, since the slope is zero"
            ],
            correctIndex: 0,
            explanation: "When f(a) = f(b), the slope between a and b is 0. The Mean Value Theorem then guarantees at least one point c where f'(c) = 0, which is exactly Rolle's Theorem.",
            visualization: .TAF
        ),
    ]


    static let fixedPointQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "f is continuous with f(a) > a and f(b) < b. What follows?",
            hint: "Select 'f(x) = cos(πx/2)' in the function picker, slide the x cursor across the interval and watch the sign of the gap f(x) − x change from + to −.",
            options: [
                "Exactly one fixed point between a and b",
                "At least one fixed point between a and b",
                "No fixed point, since f is decreasing",
                "Nothing without knowing f'"
            ],
            correctIndex: 1,
            explanation: "Since the curve starts above the diagonal at a and ends below it at b, it must cross the diagonal at least once.",
            visualization: .fixedPoint
        ),
        Question(
               subject: .analysis,
               text: "f : [0, 1] → [0, 1] is continuous. What is always guaranteed?",
               hint: "Select 'f(x) = cos(πx/2)', which maps [0, 1] into [0, 1], and slide the cursor: the gap f(x) − x runs from +1 down to −1, so it has to pass through 0 on the way.",
               options: [
                   "Exactly one fixed point",
                   "At least one fixed point",
                   "A fixed point only if f is strictly increasing",
                   "Nothing, without the boundary values"
               ],
               correctIndex: 1,
               explanation: "The gap g(x) = f(x) − x is continuous, and f lands in [0, 1], so g(0) ≥ 0 and g(1) ≤ 0. A continuous g running from ≥ 0 to ≤ 0 has to hit 0, and that point is a fixed point.",
               visualization: .fixedPoint
           ),
        Question(
              subject: .analysis,
              text: "f is continuous and strictly decreasing on a closed interval [a, b], and its values are not required to stay inside [a, b]. How many fixed points can it have in [a, b]?",
              hint: "Select 'f(x) = cos(πx/2)' and sweep the cursor: the gap f(x) − x only ever decreases, so count how often it can change sign. Then select 'f(x) = −x − 0.5', just as continuous and just as decreasing, and see where its one crossing actually sits.",
              options: [
                  "At most one, and possibly none",
                  "Exactly one, continuity guarantees it",
                  "Several, if the slope is steep enough",
                  "None, since f falls while the diagonal rises"
              ],
              correctIndex: 0,
              explanation: "The gap g(x) = f(x) − x is strictly decreasing, so it changes sign at most once and two fixed points are impossible. Whether there is one at all depends on the interval. On all of ℝ there always is exactly one, since g runs from +∞ down to −∞. On a bounded [a, b] the curve can sit entirely off the diagonal: f(x) = −x − 0.5 on [0, 1] has g(x) = −2x − 0.5 running from −0.5 to −2.5, never reaching 0. Its solution of f(x) = x is x = −0.25, just outside the interval.",
              visualization: .fixedPoint
          ),
        Question(
            subject: .analysis,
            text: "How does adding large oscillations to a function affect the number of fixed points on an interval?",
            hint: "Select 'f(x) = 1 − x + 0.7 sin(3πx)' in the function picker and sweep the cursor: count how many times the gap flips sign.",
            options: [
                "It always drops the count to zero",
                "It can make the curve cross the diagonal several times",
                "It changes nothing",
                "It forces infinitely many fixed points"
            ],
            correctIndex: 1,
            explanation: "When a function oscillates strongly up and down, it can snake across the diagonal line multiple times, creating more than one fixed point.",
            visualization: .fixedPoint
        )

        
    ]

    // MARK: - Convergence

    static let convergenceQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "For the sequence uₙ = 1/n with limit L = 0 and tolerance ε = 0.100, what is the smallest N such that |uₙ − L| < ε for all n ≥ N?",
            hint: "Select '1/n' in the sequence picker, set ε to 0.1, and check your own answer against where the dots first stay inside the band.",
            options: [
                "N = 1",
                "N = 11",
                "N = 100",
                "No such N exists"
            ],
            correctIndex: 1,
            explanation: "For uₙ = 1/n to stay within ε = 0.1 of L = 0, we need 1/n < 0.1, so n > 10. The N line marks where all remaining terms stay inside the band.",
            visualization: .convergence
        ),
        Question(
                    subject: .analysis,
                    text: "For the sequence uₙ = 1/n with limit L = 0, how does the critical rank N behave when the tolerance ε is made smaller?",
                    hint: "Select '1/n' in the sequence picker, then drag the ε slider from wide to narrow and watch which way the N marker moves.",
                    options: [
                        "N gets smaller: a tighter band is satisfied sooner",
                        "N is unchanged, since it depends only on the sequence",
                        "N no longer exists once ε drops below 1",
                        "N gets larger: a tighter band takes more terms to satisfy"
                    ],
                    correctIndex: 3,
                    explanation: "N is not a property of the sequence alone; it answers a demand made by ε. Tighten the band and the early terms no longer fit, so the rank from which everything stays inside is pushed further out. Convergence means that however small ε gets, such an N still exists.",
                    visualization: .convergence
                ),
        Question(
            subject: .analysis,
            text: "For the sequence uₙ = (−1)ⁿ with candidate limit L = 0, can you find an ε > 0 such that an N exists where all terms beyond N stay within ε of L?",
            hint: "Select '(−1)ⁿ' in the sequence picker and widen ε as far as it goes: check whether the dots ever all sit inside the band.",
            options: [
                "Yes, all terms eventually stay within ε of 0",
                "No, terms keep jumping outside the band no matter how large n gets",
                "Yes, but only for ε ≥ 2",
                "The sequence converges to 1, not 0"
            ],
            correctIndex: 1,
            explanation: "(−1)ⁿ oscillates between +1 and −1 forever. No matter the ε, half the dots lie outside the band around L = 0. The verdict says 'no N exists'.",
            visualization: .convergence
        ),
        Question(
            subject: .analysis,
            text: "For the sequence uₙ = sin(n)/n with tolerance ε ≈ 0.150, how do the early terms (n < 10) compare to the later terms (n > 25) in terms of their distance from L = 0?",
            hint: "Select 'sin(n)/n' in the sequence picker and compare a few early dots with later ones against the same band.",
            options: [
                "All dots have the same distance from L",
                "Early dots can be outside the band, later dots stay inside",
                "The dots oscillate wildly with no pattern",
                "The sequence does not converge"
            ],
            correctIndex: 1,
            explanation: "sin(n) oscillates between ±1, but dividing by n forces the terms toward 0. Early terms can be large, but past N they all fit inside the ε band.",
            visualization: .convergence
        ),
    ]

    // MARK: - L'Hôpital

    static let lhopitalQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "For lim[x→0] sin(x)/x, what happens to the ratio f(x)/g(x) as both curves approach their tangent lines at x = 0?",
            hint: "Select 'sin(x)/x' in the function-pair picker and push the zoom right: watch each curve straighten onto its tangent near 0.",
            options: [
                "The curves stay curved and separate",
                "They both flatten into straight lines with the same slope",
                "Only sin(x) becomes a line",
                "They spiral around each other"
            ],
            correctIndex: 1,
            explanation: "Near 0, sin(x) ≈ x (both have slope 1). Zoomed in, each curve becomes its tangent line. The ratio of the slopes is 1/1 = 1, which is the limit.",
            visualization: .lhopital
        ),
        Question(
            subject: .analysis,
            text: "For lim[x→0] sin(2x)/sin(3x), what is the ratio f′(0)/g′(0)?",
            hint: "Select 'sin(2x)/sin(3x)' in the function-pair picker, work the ratio of derivatives out yourself, then zoom in to see the curves settle on it.",
            options: [
                "Both slopes are 1, so the ratio is 1",
                "f′(0) = 2 and g′(0) = 3, so the ratio is 2/3",
                "f′(0) = 3 and g′(0) = 2, so the ratio is 3/2",
                "The derivatives don't exist"
            ],
            correctIndex: 1,
            explanation: "sin(2x) has derivative 2cos(2x) → 2 at 0. sin(3x) has derivative 3cos(3x) → 3 at 0. The limit is f′(0)/g′(0) = 2/3 ≈ 0.667.",
            visualization: .lhopital
        ),
        Question(
            subject: .analysis,
            text: "For lim[x→0] x²sin(1/x)/sin(x), does the numerator f(x) = x²sin(1/x) have a well-defined derivative at x = 0?",
            hint: "Select 'x²sin(1/x) / sin(x)' in the function-pair picker and zoom all the way in: watch whether the red curve ever straightens.",
            options: [
                "Yes, it flattens like the others",
                "No, it keeps oscillating wildly no matter how much you zoom",
                "Yes, it becomes a horizontal line",
                "It disappears at x = 0"
            ],
            correctIndex: 1,
            explanation: "x²sin(1/x) oscillates infinitely often near 0. No zoom reveals a tangent line because f′(0) doesn't exist. L'Hôpital cannot be applied; the legend says 'no slope'.",
            visualization: .lhopital
        ),
        Question(
            subject: .analysis,
            text: "For the indeterminate form lim[x→0] sin(2x)/sin(3x), what value does L'Hôpital's rule predict?",
            hint: "Select 'sin(x)/x' in the function-pair picker, compute f′(0)/g′(0) by hand, then zoom in on the origin to check the two curves agree with it.",
            options: [
                "The limit is 1",
                "The limit is 2/3 ≈ 0.667",
                "The limit is 3/2 = 1.5",
                "L'Hôpital gives no answer"
            ],
            correctIndex: 1,
            explanation: "The green readout shows f′(0)/g′(0) = 2/3 = 0.667. The graph confirms this visually: the red curve climbs twice as fast as the blue one climbs three times as fast.",
            visualization: .lhopital
        ),
    ]

    // MARK: - Squeeze theorem

    static let sandwichQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "For the sequence uₙ = (−1)ⁿ/n with bounds ±1/n, what happens to the gap between the two bounds as n → ∞?",
            hint: "Select (−1)ⁿ/n in the sequence picker, then slide n out and watch the width of the band, not the dots inside it.",
            options: [
                "It stays constant at 2",
                "It shrinks, approaching zero",
                "It grows wider as n increases",
                "It oscillates without pattern"
            ],
            correctIndex: 1,
            explanation: "The bounds are ±1/n, so the gap is 2/n. As n grows, this shrinks to 0, trapping the oscillating middle sequence.",
            visualization: .sandwich
        ),
        Question(
            subject: .analysis,
            text: "Which sequence gets squeezed to zero faster: uₙ = sin(n²)/√n (with bounds ±1/√n) or vₙ = cos(n)/n² (with bounds ±1/n²)?",
            hint: "Switch the sequence picker between 'sin(n²)/√n' and 'cos(n)/n²' and compare how fast each band closes at the same n.",
            options: [
                "sin(n²)/√n, because the bound is ±1/√n",
                "cos(n)/n², because the bound is ±1/n²",
                "They converge at the same rate",
                "Neither converges to zero"
            ],
            correctIndex: 1,
            explanation: "1/n² shrinks much faster than 1/√n. At n = 20, the ±1/n² envelope is nearly 40 times tighter than ±1/√n.",
            visualization: .sandwich
        ),
        Question(
            subject: .analysis,
            text: "For the sequence uₙ = (−1)ⁿ/n with bounds ±1/n, does the sequence ever touch the upper or lower bound?",
            hint: "Select (−1)ⁿ/n in the sequence picker, then slide n through the whole range: do the dots sit strictly inside the band, or on its edge?",
            options: [
                "Yes, at every n",
                "Yes, but only at odd n",
                "No, it stays strictly inside except at n = 1",
                "Yes, it touches at n = 1 only"
            ],
            correctIndex: 0,
            explanation: "At every n, the sequence equals exactly one of the bounds: (−1)ⁿ/n alternates between −1/n (lower bound) and +1/n (upper bound). The middle sequence IS the boundary.",
            visualization: .sandwich
        ),
        Question(
            subject: .analysis,
            text: "Why can uₙ = sin(n²)/√n converge to zero even though sin(n²) never settles down?",
            hint: "Select 'sin(n²)/√n' in the sequence picker and ignore the dots for a moment: watch only what the band does as n grows.",
            options: [
                "sin(n²) eventually becomes periodic",
                "The bounds ±1/√n trap it and force it to 0",
                "sin(n²) itself approaches 0",
                "It does not converge"
            ],
            correctIndex: 1,
            explanation: "The squeeze theorem doesn't care about the chaos in the middle. As long as −1/√n ≤ sin(n²)/√n ≤ 1/√n and both bounds go to 0, the middle is forced to 0 too.",
            visualization: .sandwich
        ),
    ]

    static let taylorQuestions: [Question] = [
            Question(
                subject: .analysis,
                text: "For f(x) = sin(x) with Taylor polynomial T₃(x) centered at 0, what happens to the error |f(x) − T₃(x)| as you move away from the center?",
                hint: "Select 'sin(x)' with order 3 and look at the shaded error: compare it near the centre with far from it.",
                options: [
                    "It shrinks to zero everywhere",
                    "It stays constant width",
                    "It grows rapidly as you move away from the center",
                    "It disappears entirely beyond x = ±1"
                ],
                correctIndex: 2,
                explanation: "The error (shaded orange area) shows |f(x) − T₃(x)|. Near x = 0, the polynomial matches sin(x) closely, but as you move away, the missing higher-order terms cause the curves to diverge, widening the error ribbon.",
                visualization: .taylor
            ),
            Question(
                subject: .analysis,
                text: "As the order n of a Taylor polynomial Tₙ increases from 1 to 6, what happens to the approximation quality at the center point?",
                hint: "With 'sin(x)' selected, raise the order and watch the error at the centre marker itself, not out at the edges.",
                options: [
                    "The curves separate more at the center",
                    "The contact gets tighter and tighter at the center point",
                    "The curves cross more times far from the center",
                    "Nothing changes at the center, only far away"
                ],
                correctIndex: 1,
                explanation: "Higher order means matching more derivatives at the center point. The orange Taylor polynomial hugs the blue function curve tighter near the orange center marker, though they may still separate far away.",
                visualization: .taylor
            ),
            Question(
                subject: .analysis,
                text: "For the even function f(x) = cos(x) centered at a = 0, which powers appear in its Taylor expansion?",
                hint: "Select 'cos(x)' and step the order up one at a time: watch which orders actually change the polynomial.",
                options: [
                    "Even powers only (x⁰, x², x⁴, x⁶)",
                    "Odd powers only (x, x³, x⁵)",
                    "All powers with alternating signs",
                    "Only constant and linear terms"
                ],
                correctIndex: 0,
                explanation: "cos(x) is an even function, so all odd derivatives vanish at x = 0. Those terms have coefficient 0 and are dropped from the display, leaving only even powers: T₆(x) = 1.00 − 0.500x² + 0.042x⁴ − 0.0014x⁶. The exponents jump 0, 2, 4, 6 with no odd power in between.",
                visualization: .taylor
            ),
            Question(
                subject: .analysis,
                text: "For f(x) = eˣ at center a = 0, how do the coefficients behave as the order increases?",
                hint: "Select 'eˣ', then work out the k-th derivative at 0 and divide by k! as Taylor's formula asks.",
                options: [
                    "Every coefficient stays equal to 1",
                    "They double at each step: 1, 2, 4, 8...",
                    "They shrink quickly: 1, 1, 0.500, 0.167, 0.042...",
                    "They alternate between positive and negative"
                ],
                correctIndex: 2,
                explanation: "Every derivative of eˣ is eˣ again, so each one at 0 equals 1 and the coefficient of xᵏ is 1/k!: 1/2, 1/6, 1/24, … They shrink fast because k! grows fast.",
                visualization: .taylor
            ),
    ]
}
