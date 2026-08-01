//
//  AnalysisQuestions.swift
//  LearnViz
//

extension Question {

    // MARK: - Complex plane

    static let complexPlaneQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "In • mode, what single geometric operation takes z₁ to z₁ • z₂, when z₂ is unitary?",
            hint: "Flip between '+' and '•' with the same z₂ and compare how the result moves: one slides, the other turns",
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
            hint: "In + mode, turn θ₂ until it matches θ₁ and watch the parallelogram flatten into a single segment.",
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
            text: "In × mode you replace θ₂ by θ₂ + π and leave r₂ alone. What happens to z₁ • z₂?",
            hint: "In '•' mode, push θ₂ half a turn and watch whether the product changes length or only direction.",
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
            hint: "In '•' mode, set both angles to the values stated in the question, read the value the app prints, then work out what it did to the raw sum.",
            options: ["9π/4", "π/4", "5π/4", "−3π/4"],
            correctIndex: 1,
            explanation: "3π/4 + 3π/2 = 9π/4, which sits past 2π. Subtracting 2π brings it back to π/4.",
            visualization: .complexNumbers
        ),
    ]



    static let trigoQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "For θ ∈ [0, 2π], how many values satisfy both sin θ = −cos θ and tan(θ/2) > 0?",
            hint: "Sweep θ and stop where the two bars have equal length but opposite signs. Then set θ to half of each and read the sign of tan.",
            options: ["1", "2", "3", "4"],
            correctIndex: 0,
            explanation: "sin θ = −cos θ gives tan θ = −1, so θ = 3π/4 or 7π/4. Halving them: 3π/8 sits in the first quadrant where tan > 0, but 7π/8 lands in the second where tan < 0. Only one survives.",
            visualization: .trigo
        ),
        Question(
            subject: .analysis,
            text: "For θ ∈ [0, 2π], how many values satisfy both sin θ = cos θ and tan(θ/4) > 0?",
            hint: "Sweep θ and stop where the two coordinate bars have equal length and equal sign, then check which quadrant a quarter of each angle lands in.",
            options: ["1", "2", "3", "4"],
            correctIndex: 1,
            explanation: "sin θ = cos θ at θ = π/4 and θ = 5π/4. Their quarters, π/16 and 5π/16, both sit in the first quadrant where tan is positive. Two solutions.",
            visualization: .trigo
        ),
        Question(
            subject: .analysis,
            text: "For θ ∈ [0, 2π], how many intervals satisfy |sin θ| > |cos θ|?",
            hint: "Sweep θ and mark where the vertical bar is taller than the horizontal one. The switch happens on the diagonals.",
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
            hint: "Find the two angles where the vertical bar is exactly three times the horizontal one, and look at where they sit relative to each other on the circle.",
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
            text: "For f(x) = cos(x) on a symmetric interval around 0, what happens to S⁻ and S⁺ as n → ∞?",
            hint: "Select 'f(x) = cos(x)' from the function picker, then push the subdivision slider up and watch how the area values move.",
            options: [
                "Both diverge to +∞",
                "Both converge to ∫I cos(x) dx",
                "S⁻ goes to 0 and S⁺ to something nonzero",
                "S⁺ − S⁻ stays constant"
            ],
            correctIndex: 1,
            explanation: "The two sums always trap the integral, and their gap shrinks with the width of the pieces because cos is Riemann-integrable.",
            visualization: .darboux
        ),
        Question(
            subject: .analysis,
            text: "f(x) = 1 on rationals, 0 elsewhere. What are S⁻ and S⁺ on [0, 2] for any subdivision?",
            hint: "Select 'f(x) = 1 if x ∈ ℚ, 0 otherwise' (the Dirichlet function), then refine the subdivision as far as the slider allows: every piece, however thin, still contains both rationals and irrationals.",
            options: [
                "S⁻ = 0 and S⁺ = 2",
                "S⁻ = S⁺ = 1/2",
                "S⁻ = S⁺ = 2",
                "It depends on how fine the subdivision is"
            ],
            correctIndex: 0,
            explanation: "Every piece has infimum 0 and supremum 1, so S⁻ = 0 and S⁺ = 1 × 2 = 2 whatever the subdivision. The gap never closes, so the function is not Riemann integrable.",
            visualization: .darboux
        ),
        Question(
            subject: .analysis,
            text: "You refine a subdivision P into P′ by splitting each rectangle in two. What happens to the sums?",
            hint: "Select 'f(x) = sin(x)', then add a single point with the slider and compare each staircase before and after.",
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
            hint: "Select 'f(x) = 5' (the constant function) and move the slider: the two staircases sit on top of each other from the very first step.",
            options: [
                "S⁻ = S⁺ = c(b − a), for every subdivision",
                "S⁻ = 0 and S⁺ = c(b − a)",
                "They depend on the subdivision",
                "S⁻ = S⁺ = c"
            ],
            correctIndex: 0,
            explanation: "Infimum and supremum are both c on every piece, so both sums equal c(b − a). The gap is zero from the start, the exact opposite of the Dirichlet case.",
            visualization: .darboux
        ),
    ]


    static let bijectivityQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "Why is f: ℝ → ℝ, f(x) = x² neither injective nor surjective?",
            hint: "Slide a horizontal line to height 4 and count the crossings, then drop it to height −1.",
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
            text: "Restricting f(x) = x² to g: ℝ⁺ → ℝ⁺ turns it into what?",
            hint: "Only look at what is in the zone where x > 0 and y > 0, are all values reached exactly once ?",
            options: [
                "Still neither injective nor surjective",
                "Bijective",
                "Injective but not surjective",
                "Surjective but not injective"
            ],
            correctIndex: 1,
            explanation: "On ℝ⁺ every height y ≥ 0 is hit exactly once. One preimage always, so g is a bijection with the square root as inverse.",
            visualization: .bijectivity
        ),
        Question(
            subject: .analysis,
            text: "f: A → B is injective if and only if:",
            hint: "Think about what the horizontal line in the graph translates to",
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
            text: "f: ℝ → ℝ is continuous and strictly increasing. What is certain?",
            hint: "Think graphically about injectivity with an horizontal line",
            options: [
                "Injective but not surjective",
                "Surjective only",
                "Bijective from ℝ onto its image f(ℝ)",
                "It cannot be modelled continuously"
            ],
            correctIndex: 2,
            explanation: "Strict monotonicity gives injectivity. Without the limits at infinity we cannot claim f(ℝ) is all of ℝ, but f is a bijection onto its image.",
            visualization: .bijectivity
        ),
    ]

    static let derivativeQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "For which functions is (f(x+h) − f(x))/h exactly f'(x) for every h ≠ 0?",
            hint: "Select 'x/2 + 3' (the affine function), then open h as wide as it goes and see how the secant stays glued to the tangent. Try the other presets too.",
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
            hint: "Select '6 sin(x/2)' (an odd function), put the secant at a point, then at its mirror image across the origin, and compare the two tilts.",
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
            hint: "Select '|x|' (absolute value), then bring the secant to 0 from the right, then from the left, and read the two slopes.",
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
            hint: "Select 'x⁴/500 − 3x²/10' (an even function), place the secant at x, then at −x, and compare the two slopes.",
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
                hint: "Select '1/n' from the sequence picker, slide n forward and check whether any selection of the dots could avoid the dashed line.",
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
                hint: "Select '(−1)ⁿ · n/(n+1)', then slide to any even n and read uₙ in the readout, then compare it with the dashed line above it.",
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
                hint: "Select 'cos(nπ/2)', then slide n forward and count how many dashed lines the colours settle onto.",
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
            hint: "Select '(−1)ⁿ · n/(n+1)', then read uₙ and uₙ₊₁ in the readout for a small n, then for the largest n the slider allows.",
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
            text: "The rectangles look badly matched to f. What is their total area?",
            hint: "Select 'x² / 4' and look inside one rectangle: compare the sliver sticking out above the curve with the gap left below it.",
            options: [
                "An approximation of ∫f",
                "Exactly ∫f, for any subdivision",
                "Exact only if the rectangles touch the curve",
                "Exact only as δ → 0"
            ],
            correctIndex: 1,
            explanation: "The theorem picks cₖ so that f(cₖ)δ equals the integral on that piece exactly. Overshoot and undershoot cancel out.",
            visualization: .meanTheorem
        ),
        Question(
                subject: .analysis,
                text: "You double the number of sections. What happens to the total area of the rectangles?",
                hint: "Select 'sin(x)', then drag the sections slider from 2 to 60 and watch the blue total, not its outline.",
                options: [
                    "It grows toward the area under the curve",
                    "It stays exactly the same",
                    "It shrinks toward the area under the curve",
                    "It oscillates as sections are added"
                ],
                correctIndex: 1,
                explanation: "Each rectangle already matches its own piece exactly, so cutting a piece in two just splits an exact area into two exact areas. There is nothing to converge to.",
                visualization: .meanTheorem
            ),
        Question(
                subject: .analysis,
                text: "f is odd and the interval is symmetric around 0. What is the total area of the rectangles?",
                hint: "Select 'sin(x)' (an odd function), set sections to 2: one rectangle hangs below the axis, the other rises above it.",
                options: [
                    "Twice the area of the right one",
                    "Zero",
                    "The area of the right one only",
                    "Undefined, since one rectangle is below the axis"
                ],
                correctIndex: 1,
                explanation: "Oddness makes the left rectangle drop below the axis by exactly what the right one rises above it. The areas carry a sign and cancel, matching an integral of 0.",
                visualization: .meanTheorem
            ),
        Question(
                subject: .analysis,
                text: "For which kind of f is c unique in every piece, whatever the subdivision?",
                hint: "Try 'x³/8 + x/2' (strictly increasing) at 20 sections and look for the curve that never comes back to a height it already left. Compare with the other functions.",
                options: [
                    "Any continuous f",
                    "Any strictly monotone f",
                    "Any positive f",
                    "Any differentiable f"
                ],
                correctIndex: 1,
                explanation: "The theorem alone only gives existence. Strict monotonicity makes f injective, so it reaches its average height exactly once per piece. A curve that turns back on itself can hit that height several times.",
                visualization: .meanTheorem
            ),
    ]
    
    
    static let TFIQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "Before the break point the two curves lie on top of each other. Why are F and G equal there?",
            hint: "Slide x to the left of the dashed line and compare the red shaded region with the blue one.",
            options: [
                "Because both areas are positive",
                "Because f and g agree on the whole stretch travelled so far",
                "Because F and G are both continuous",
                "Because the areas happen to cancel"
            ],
            correctIndex: 1,
            explanation: "F(x) and G(x) collect the area under f and under g from 0 up to x. As long as the two curves have not parted anywhere in that stretch, they are collecting the same thing.",
            visualization: .TFI
        ),
        Question(
            subject: .analysis,
            text: "Just past the break point f and g differ. What do F and G do at that instant?",
            hint: "Park x right on the dashed line, then nudge it a little to the right and watch the two numbers.",
            options: [
                "They jump apart by the gap between f and g",
                "They drift apart, slowly at first",
                "They stay equal, since only the curves changed",
                "F stops growing"
            ],
            correctIndex: 1,
            explanation: "The gap between F and G is the area collected between the two curves. Right at the break point that area is zero, and it only builds up as x moves on. Two functions can separate instantly while their integrals separate gradually.",
            visualization: .TFI
        ),
        Question(
            subject: .analysis,
            text: "What controls how fast the gap between F and G grows at a given x?",
            hint: "Slide x slowly through a stretch where the red curve is far above the blue one, then through a stretch where they nearly touch. Compare how quickly the two numbers run apart.",
            options: [
                "The gap already accumulated so far",
                "The vertical distance between f and g at that x",
                "The distance from x to the break point",
                "Nothing, the gap grows at a steady rate"
            ],
            correctIndex: 1,
            explanation: "F − G collects the area between the curves, so its rate of growth at x is exactly the height between them at x. Where they are far apart the numbers run away fast, where they nearly touch the gap barely moves even though it is already large.",
            visualization: .TFI
        ),
        Question(
            subject: .analysis,
            text: "For a given a > 0, F(a) = G(a), does it imply that f(x) = g(x) for all x in [0,a] ?",
            hint: "How is the condition of function equality transferred in terms of the areas ?",
            options: [
                "Yes it does, as both F(a)= G(a), all areas are equal up to a, hence the functions are equal.",
                "No, it doesn't, as F(a) = G(a) happens only if f(x) = g(x) for all real values.",
                "Yes it does, because the fundamental theorem of calculus guarantees pointwise equality from global area equality.",
                "No, it doesn't. The signed areas under f and g over [0, a] can balance out to be equal at x = a, even if the functions fluctuate and differ throughout the interval."
            ],
            correctIndex: 3,
            explanation: "The gap collects signed area, so a stretch where f sits under g subtracts from it and can wipe it out. That is why F(b) = G(b) at one single b proves nothing, while F = G at every x forces f = g.",
            visualization: .TFI
        )

    ]
    
    
    // MARK: - Mean value theorem for derivatives

    static let TAFQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "How many points c does the mean value theorem guarantee?",
            hint: "Select 'cos(πx)' and count how many tangents come out parallel to the chord.",
            options: ["Exactly one", "At least one", "At most one", "As many as f has zeros"],
            correctIndex: 1,
            explanation: "At least one. Uniqueness is never claimed, and sin(2πx) shows several at once.",
            visualization: .TAF
        ),
        
        Question(
                subject: .analysis,
                text: "f is differentiable on ℝ and has a constant derivative f'(x). According to the Mean Value Theorem , what happens on any interval ]a, b[?",
                hint: "Select '0.5x + 0.2 (Affine)': what does it mean for the slope of the tangent if the derivative never changes?",
                options: [
                    "Only the midpoint c = (a+b)/2 satisfies the Mean Value Theorem.",
                    "Every single point c in ]a, b[ satisfies the MVT equation.",
                    "No point c satisfies the theorem because the function has no curvature.",
                    "The Mean Value Theorem fails because the chord and the tangent are merged."
                ],
                correctIndex: 1,
                explanation: "Since f'(x) = k everywhere, the instantaneous slope is always k. The average slope (blue chord) is also k. Therefore, f'(c) = (f(b)-f(a))/(b-a) is true for every point c in the interval.",
                visualization: .TAF
            ),
        Question(
               subject: .analysis,
               text: "What happens to the Mean Value Theorem if the function has a sharp corner inside the interval [a, b]?",
               hint: "Select '|x|' and think about what differentiability means and how every steepness is explored between a and b.",
               options: [
                   "The theorem still holds as long as the function remains continuous.",
                   "The theorem can fail completely because f'(x) is not defined at the corner.",
                   "The theorem only holds if the sharp corner is exactly at the midpoint.",
                   "The chord slope doubles to compensate for the corner."
               ],
               correctIndex: 1,
               explanation: "The Mean Value Theorem strictly requires the function to be differentiable on the open interval ]a, b[. A sharp corner means the derivative does not exist at that point, which can prevent you from finding any parallel tangent.",
               visualization: .TAF
           ),
        
        Question(
            subject: .analysis,
            text: "If you select the cos(πx) preset and adjust the sliders to a = -1.00 and b = 1.00, what specific case of the Mean Value Theorem do you observe?",
            hint: "Select 'cos(πx)' and set a = -1.00 and b = 1.00. Look at the slope of the blue dashed chord when A and B are at the same height.",
            options: [
                "The Mean Value Theorem cannot be applied here.",
                "Rolle's Theorem, because f(a) = f(b), guaranteeing a point where c where f'(c) = 0",
                "The Fundamental Theorem of Calculus.",
                "A case where no point c can be found because the slope is zero."
            ],
            correctIndex: 1,
            explanation: "When f(a) = f(b), the slope of the chord is 0. The Mean Value Theorem then guarantees at least one point c where f'(c) = 0. This is exactly Rolle's Theorem.",
            visualization: .TAF
        ),
    ]

    
    // MARK: - Fixed points

    static let fixedPointQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "f is continuous with f(a) > a and f(b) < b. What follows?",
            hint: "Select 'f(x) = 1 − x²' and watch where the curve sits relative to the diagonal at a and at b. It has to get from one side to the other.",
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
               text: "If a continuous function f maps the closed interval from 0 to 1 into itself, what property is always guaranteed?",
               hint: "Select 'f(x) = 1 − x'. The curve is perfectly boxed inside the unit square, forcing it to interact with the diagonal.",
               options: [
                   "Exactly one fixed point.",
                   "At least one fixed point within the interval.",
                   "A fixed point exists if and only if f is strictly increasing.",
                   "Nothing can be guaranteed without knowing the explicit boundary values."
               ],
               correctIndex: 1,
               explanation: "A continuous curve trapped inside a square box from x = 0 to x = 1 cannot go from the left side to the right side without crossing the diagonal line.",
               visualization: .fixedPoint
           ),
        Question(
              subject: .analysis,
              text: "If a continuous function f is strictly decreasing on an interval, what can be concluded about the maximum number of fixed points it can possess on that interval?",
              hint: "Select 'f(x) = 1 − x' (strictly decreasing). Think about how many times a strictly falling curve can intersect a strictly rising diagonal line.",
              options: [
                  "It can have multiple fixed points if the slope is very steep.",
                  "It is guaranteed to have exactly one fixed point.",
                  "It can have at most one fixed point.",
                  "It cannot have any fixed points because the trends are opposite."
              ],
              correctIndex: 2,
              explanation: "A strictly decreasing curve can cross the strictly increasing diagonal line at most once. If it crosses, that fixed point is unique.",
              visualization: .fixedPoint
          ),
        Question(
            subject: .analysis,
            text: "How does adding large oscillations to a function affect the number of fixed points on an interval?",
            hint: "Select 'f(x) = 1 − x + sin osc' and notice how the wave shape forces the curve to meet the diagonal at several distinct places.",
            options: [
                "It always reduces the number of fixed points to zero.",
                "It can force the curve to cross the diagonal multiple times, creating several fixed points.",
                "It has absolutely no effect on the number of intersections.",
                "It guarantees that there will be an infinite number of fixed points."
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
            hint: "Select '1/n' and set ε = 0.100. Look for the vertical dashed line labeled 'N' on the graph.",
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
                    hint: "Select '1/n' and drag the ε slider from right to left, shrinking the band. Watch the vertical orange dashed line labelled 'N=…'.",
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
            hint: "Select '(−1)ⁿ' and set ε = 0.500. Look at whether dots are green/purple (inside) or red/orange (outside the band) as n increases.",
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
            hint: "Select 'sin(n)/n' and set ε ≈ 0.150, then tap or hover over different dots to read their distance |uₙ − L|. Compare early dots with later ones.",
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
            hint: "Select 'sin(x)/x' and drag the zoom slider all the way to the right. Watch how the red and blue curves behave as you zoom in on the origin.",
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
            hint: "Select 'sin(2x)/sin(3x)' and zoom all the way in. Do you see the ratio ?",
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
            hint: "Select 'x²sin(1/x) / sin(x)' and zoom all the way in. Watch the red curve (f) closely as you increase the zoom — does it ever flatten into a line?",
            options: [
                "Yes, it flattens like the others",
                "No, it keeps oscillating wildly no matter how much you zoom",
                "Yes, it becomes a horizontal line",
                "It disappears at x = 0"
            ],
            correctIndex: 1,
            explanation: "x²sin(1/x) oscillates infinitely often near 0. No zoom reveals a tangent line because f′(0) doesn't exist. L'Hôpital cannot be applied — the legend says 'no slope'.",
            visualization: .lhopital
        ),
        Question(
            subject: .analysis,
            text: "For the indeterminate form lim[x→0] sin(2x)/sin(3x), what value does L'Hôpital's rule predict?",
            hint: "Select 'sin(2x)/sin(3x)' and read the colored text that appears below the zoom slider. This is the answer L'Hôpital gives.",
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
            hint: "Select '(−1)ⁿ/n' and slide n from 1 to 40. Watch the yellow band (the 'jaw') closing as n increases. Compare the width at n = 4 versus n = 30.",
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
            hint: "Switch between the two presets and watch how quickly the yellow band collapses. Look at the width readout around n = 20.",
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
            hint: "Select '(−1)ⁿ/n' and slide n through all values from 1 to 40. Watch closely whether the blue dots touch the yellow bound curves.",
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
            hint: "Select 'sin(n²)/√n' and watch the blue dots oscillate wildly inside the yellow band. Focus on the band's width, not the oscillation pattern.",
            options: [
                "Because sin(n²) eventually becomes periodic",
                "Because the bounds ±1/√n trap it and force it toward 0, regardless of the oscillation",
                "Because sin(n²) approaches zero as n grows",
                "It doesn't converge; the oscillation prevents convergence"
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
                hint: "Select 'sin(x)' and set order to 3. Watch the orange shaded area (error) as you look further left or right from the center marker.",
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
                hint: "Select any function and tap the order buttons from 1 to 6. Watch how tightly the orange curve hugs the blue curve at the center marker.",
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
                hint: "Select 'cos(x)' and tap through the order buttons from 1 to 6. Read the polynomial displayed below the graph and note which exponents appear.",
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
                hint: "Select 'eˣ' and tap through orders 1, 2, 3, 4. Compare the decimal number in front of each power.",
                options: [
                    "Every coefficient stays equal to 1",
                    "They double at each step: 1, 2, 4, 8...",
                    "They shrink quickly: 1, 1, 0.500, 0.167, 0.042...",
                    "They alternate between positive and negative"
                ],
                correctIndex: 2,
                explanation: "Every derivative of eˣ is again eˣ, so each derivative at 0 equals 1 and the coefficient of xᵏ is exactly 1/k!. The decimals shown are those reciprocal factorials: 1/2 = 0.500, 1/6 = 0.167, 1/24 = 0.042. They shrink fast because k! grows fast, which is why the series converges for every x.",
                visualization: .taylor
            ),
    ]
}
