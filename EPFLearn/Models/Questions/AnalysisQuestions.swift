

extension Question {
 
    static let complexPlaneQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "You set r₁ = 0 (so z₁ = 0), θ₂ = π/3, r₂ = 3, and switch to × mode. What does the app show for arg(z₁ × z₂)?",
            hint: "What actually is z₁ × z₂ here?",
            options: [
                "θ₁ + θ₂, same as any other product",
                "θ₂, since z₁ contributes nothing",
                "Undefined — z₁ × z₂ = 0, and the argument of 0 has no meaning",
                "0, by convention"
            ],
            correctIndex: 2,
            explanation: "z₁ × z₂ = 0 · z₂ = 0 regardless of θ₂. The argument (direction) of a complex number is only defined when its modulus is nonzero.",
            visualization: .complexNumbers
        ),
        Question(
            subject: .analysis,
            text: "For which z₁, z₂ (both nonzero) does |z₁ + z₂| = |z₁| + |z₂| hold exactly?",
            hint: "Try setting θ₁ = θ₂ in + mode and watch what the parallelogram construction degenerates into",
            options: [
                "Only when z₁ and z₂ are complex conjugates",
                "Only when θ₁ = θ₂ (z₂ is a positive real multiple of z₁)",
                "Only when θ₂ = θ₁ + π",
                "This holds for any z₁, z₂"
            ],
            correctIndex: 1,
            explanation: "This is the equality case of the triangle inequality. It holds only when z₁ and z₂ point in exactly the same direction — otherwise |z₁+z₂| < |z₁|+|z₂| strictly, because the parallelogram construction only flattens into a straight segment when there's no angle between the two vectors.",
            visualization: .complexNumbers
        ),
        Question(
            subject: .analysis,
            text: "Starting from any z₁ and z₂ in × mode, you replace θ₂ by θ₂ + π and leave r₂ unchanged. What happens to z₁ × z₂?",
            hint: "Try it in the visualisation, if in doubt",
            options: [
                "Its modulus doubles",
                "It rotates by π (points the opposite way), same modulus",
                "It becomes purely imaginary",
                "Nothing changes, since only the modulus of the product depends on r₁ and r₂"
            ],
            correctIndex: 1,
            explanation: "Adding π to θ₂ multiplies z₂ by e^{iπ} = −1, so z₁ × z₂ simply flips to the opposite direction (its argument shifts by π) while |z₁ × z₂| = r₁r₂ stays exactly the same. A common mistake is assuming shifting the angle also changes the modulus.",
            visualization: .complexNumbers
        ),
        Question(
            subject: .analysis,
            text: "θ₁ = 3π/4 and θ₂ = 3π/2 in × mode. The app normalizes displayed angles to [0, 2π). What argument will it actually display for z₁ × z₂?",
            hint: "First, find the expression of z₁ × z₂, then use the fact that a simple complex exponential is 2π-periodic. ",
            options: [
                "9π/4",
                "π/4",
                "5π/4",
                "−3π/4"
            ],
            correctIndex: 1,
            explanation: "3π/4 + 3π/2 = 9π/4. Since 9π/4 exceeds 2π, subtract 2π (= 8π/4) to bring it back into range: 9π/4 − 2π = π/4.",
            visualization: .complexNumbers
        ),
    ]
    
    static let trigoQuestions: [Question] = [
        
                Question(
                    subject: .analysis,
                    text: "As θ increases through π/2 (from slightly below to slightly above), what happens to tan θ, and what does that reveal about cos θ and sin θ individually?",
                    hint: "Check whether cos θ and sin θ themselves jump at π/2, or only their ratio does",
                    options: [
                        "tan θ jumps from a huge positive value to a huge negative value, even though cos θ and sin θ are both perfectly continuous there",
                        "tan θ passes smoothly through 0",
                        "tan θ is continuous at π/2 because sin θ = 1 there",
                        "cos θ and sin θ both jump discontinuously at π/2"
                    ],
                    correctIndex: 0,
                    explanation: "cos θ and sin θ are continuous everywhere,nothing jumps in the numerator or denominator individually. But cos θ crosses zero at π/2, so the ratio sin θ / cos θ blows up: +∞ approaching from below, −∞ from above. ",
                    visualization: .trigo
                ),
                Question(
                    subject: .analysis,
                    text: "tan θ = tan(θ + π) for any θ where both are defined, even though the point on the circle is completely different. What does this tell you about the period of tan, compared to sin and cos?",
                    hint: "Check what happens to cos θ and sin θ individually when you add π — do they change sign?",
                    options: [
                        "tan has period π, exactly half the period of sin and cos",
                        "tan has the same period 2π as sin and cos",
                        "tan has period π/2",
                        "tan isn't periodic at all"
                    ],
                    correctIndex: 0,
                    explanation: "Adding π flips the sign of both cos θ and sin θ: cos(θ+π) = −cos θ, sin(θ+π) = −sin θ. Their ratio is unchanged, so tan(θ+π) = tan θ. The point on the circle is the antipodal one (completely different position), yet tan reads the same — its true period is π, not 2π like sin and cos.",
                    visualization: .trigo
                ),
                Question(
                    subject: .analysis,
                    text: "For θ ∈ [0, 2π], how many values satisfy both sin(θ) = cos(θ) and tan(θ/4) > 0?",
                    hint: "Find where sin(θ) = cos(θ) first, then check the sign of tan(θ/4) for those angles.",
                    options: ["1", "2", "3", "4"],
                    correctIndex: 1,
                    explanation: "The equation sin(θ) = cos(θ) yields two solutions in [0, 2π]: θ = π/4 and θ = 5π/4. Next, we test tan(θ/4) for both: 1) For θ = π/4, tan(π/16) > 0 because π/16 is in Quadrant I. 2) For θ = 5π/4, tan(5π/16) > 0 because 5π/16 is also in Quadrant I. Since both values satisfy the second condition, there are exactly 2 valid solutions.",
                    visualization: .trigo
                ),
                Question(
                    subject: .analysis,
                    text: "For θ ∈ [0, 2π], how many separate intervals of solutions satisfy the inequality |sin θ| > |cos θ|?",
                    hint: "On the unit circle, look for the regions where the vertical coordinate is strictly longer than the horizontal coordinate.",
                    options: [
                        "1 interval, covering a quarter of the circle.",
                        "2 intervals, covering a quarter of the circle.",
                        "2 intervals, covering half of the circle.",
                        "4 intervals, covering three quarter of the circle."
                    ],
                    correctIndex: 2,
                    explanation: "The condition |sin θ| > |cos θ| means the y-coordinate has a greater absolute value than the x-coordinate. This happens in the regions steeper than the 45-degree diagonal lines. Visually, this creates two large continuous arcs centered around the vertical axis: the top arc (π/4, 3π/4) and the bottom arc (5π/4, 7π/4). Within the domain [0, 2π], these form exactly 2 separate intervals that combined cover half of the circle.",
                    visualization: .trigo
                )
    ]
    
    
    static let darbouxQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "On a symmetric interval around 0, as n → ∞, what happens to the Darboux sums S⁻ and S⁺ for f(x) = cos(x)?",
            hint: "Play with the slider and watch what happens as the subdivision gets finer",
            options: [
                "S⁻ and S⁺ both diverge to +∞",
                "S⁻ and S⁺ both converge to ∫I cos(x) dx, where I is a symmetric interval around 0",
                "S⁻ converges to 0 and S⁺ converges to a nonzero value",
                "S⁺ − S⁻ stays constant no matter the subdivision"
            ],
            correctIndex: 1,
            explanation: "As n → ∞, each sub-interval's width shrinks to 0. S⁻ and S⁺ always sandwich the integral, and their gap shrinks to 0 too: both converge to the value of the integral. This is the Riemann integrability criterion.",
            visualization: .darboux
        ),
        Question(
            subject: .analysis,
            text: "f(x) = 1 if x is rational, 0 otherwise (Dirichlet function). What are S⁻ and S⁺ on [0,2], no matter how we subdivide?",
            hint: "Every interval, no matter how small, contains both rationals and irrationals",
            options: [
                "S⁻ = 0 and S⁺ = 2",
                "S⁻ = S⁺ = 1/2",
                "S⁻ = S⁺ = 2",
                "It depends on how fine the subdivision is"
            ],
            correctIndex: 0,
            explanation: "Every sub-interval contains both irrationals (where f=0) and rationals (where f=1). So inf = 0 and sup = 1 on every piece, no matter the subdivision. S⁻ = 0 and S⁺ = 1 always. The Dirichlet function is not Riemann integrable.",
            visualization: .darboux
        ),
        Question(
            subject: .analysis,
            text: "We refine a subdivision P by adding a point to get P'. What happens?",
            hint: "Adding a point shrinks the sub-intervals: the infimums go up, the supremums go down (check the visualization)",
            options: [
                "S⁻(P') ≤ S⁻(P) and S⁺(P') ≥ S⁺(P)",
                "S⁻(P') ≥ S⁻(P) and S⁺(P') ≤ S⁺(P)",
                "S⁻ and S⁺ stay the same",
                "It depends on how smooth f is"
            ],
            correctIndex: 1,
            explanation: "Refining a subdivision can only help: S⁻ goes up (infimum over smaller intervals) and S⁺ goes down.",
            visualization: .darboux
        ),
        Question(
            subject: .analysis,
            text: "For a constant function f(x) = c on [a,b], what are the Darboux sums S⁻ and S⁺ for any subdivision?",
            hint: "On every sub-interval the min and the max of f are the same.",
            options: [
                "S⁻ = S⁺ = c(b − a), for every subdivision",
                "S⁻ = 0 and S⁺ = c(b − a)",
                "They depend on how fine the subdivision is",
                "S⁻ = S⁺ = c"
            ],
            correctIndex: 0,
            explanation: "On each sub-interval the infimum and supremum of f are both c, so every lower and upper rectangle has height c. Both sums equal c times the total width: S⁻ = S⁺ = c(b − a), whatever the subdivision. The gap is 0 from the start — the exact opposite of the Dirichlet function, where the gap never closes.",
            visualization: .darboux
        ),
    ]

    // MARK: - Derivative
    static let derivativeQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "For which family of functions is the difference quotient (f(x+h)-f(x))/h exactly equal to f'(x) for every h ≠ 0?",
            hint: "Think of functions whose secant line always matches the tangent line — try eliminating options using the graph.",
            options: [
                "Constant functions only",
                "Polynomials of degree ≤ 2",
                "All differentiable functions",
                "Affine functions f(x) = ax + b",
            ],
            correctIndex: 3
            ,
            explanation: "For f(x) = ax+b, (f(x+h)-f(x))/h = a = f'(x) exactly. For any polynomial of degree ≥ 2, there's a leftover term in h that only vanishes in the limit.",
            visualization: .derivative
        ),
        Question(
            subject: .analysis,
            text: "On the graph, the tangent line at x₀ and the curve look almost identical near x₀. What property exactly captures this?",
            hint: "The derivative is more than just a slope — it's a local approximation",
            options: [
                "f(x₀+h) = f(x₀) + f'(x₀)·h for every h",
                "f(x₀+h) = f(x₀) + f'(x₀)·h + o(h) as h → 0",
                "f(x₀+h) - f(x₀) = f'(x₀) for every small h",
                "f and its tangent line have the same maximum"
            ],
            correctIndex: 1,
            explanation: "f being differentiable at x₀ means exactly that f(x₀+h) = f(x₀) + f'(x₀)·h + o(h): the gap between the curve and the tangent is negligible compared to h. That's why they look indistinguishable when you zoom in — but they never actually coincide unless f is affine.",
            visualization: .derivative
        ),
        Question(
            subject: .analysis,
            text: "On the graph, |x| has a sharp corner at x=0. What does this mean analytically?",
            hint: "Compute the difference quotient of |x| at 0 from the right and from the left",
            options: [
                "|x| is not continuous at 0",
                "The limit of the difference quotient depends on the sign of h: it's 1 for h>0 and -1 for h<0",
                "|x| is differentiable at 0 with f'(0) = 0",
                "The difference quotient diverges to +∞"
            ],
            correctIndex: 1,
            explanation: "For h > 0: (|h|-0)/h = 1. For h < 0: (-h)/h = -1. The left and right limits both exist but disagree — so the limit of the difference quotient doesn't exist. |x| is continuous but not differentiable at 0: the corner in the graph is exactly the signature of this.",
            visualization: .derivative
        ),
        Question(
            subject: .analysis,
            text: "On the graph, you drag the secant line and watch its slope. If f is even, what can we say about f'?",
            hint: "Think about the curve's symmetry — how does the secant at -x relate to the one at x?",
            options: [
                "f' is also even",
                "f' is odd",
                "f' is even only if f is a polynomial",
                "We can't say anything without computing"
            ],
            correctIndex: 1,
            explanation: "If f is even, f(-x) = f(x). Differentiating: -f'(-x) = f'(x), so f'(-x) = -f'(x) — f' is odd. On the graph: the secant at -x is the mirror image of the secant at x, with opposite slope. So the tangent at 0 of an even function is always horizontal.",
            visualization: .derivative
        ),
    ]

    // MARK: - Sequences
    static let sequenceQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "Let uₙ = cos(nπ/2). How many distinct limits can we get from convergent subsequences?",
            hint: "List the values uₙ actually takes",
            options: [
                "None — since uₙ diverges, no subsequence converges",
                "Exactly 1",
                "Exactly 3",
                "Infinitely many"
            ],
            correctIndex: 2,
            explanation: "uₙ cycles through 1, 0, −1, 0, ... Three values show up infinitely often → three constant subsequences → three distinct limits.",
            visualization: .sequence
        ),
        Question(
            subject: .analysis,
            text: "Bolzano-Weierstrass applies to uₙ = (-1)ⁿ. What does it guarantee?",
            hint: "Is the sequence bounded?",
            options: [
                "It diverges, so the theorem doesn't apply",
                "There exists at least one convergent subsequence",
                "It converges to 0",
                "There is a unique convergent subsequence"
            ],
            correctIndex: 1,
            explanation: "uₙ = (-1)ⁿ is bounded, so B-W applies. There are two convergent subsequences: even indices → 1, odd indices → -1. B-W guarantees at least one, not uniqueness.",
            visualization: .sequence
        ),
        Question(
            subject: .analysis,
            text: "uₙ is decreasing and bounded below by m. The subsequence u_{3n} converges to L. What is lim uₙ?",
            hint: "A monotone bounded sequence converges — does the subsequence tell us the limit?",
            options: [
                "We can't conclude without knowing u_{3n+1} and u_{3n+2}",
                "uₙ converges to L",
                "uₙ converges to m",
                "uₙ converges to L only if L = m"
            ],
            correctIndex: 1,
            explanation: "uₙ decreasing and bounded below converges to some limit ℓ. Every subsequence of a convergent sequence converges to the same limit, so u_{3n} → ℓ. We're told u_{3n} → L, so ℓ = L. No need to check u_{3n+1} or u_{3n+2} — monotonicity does all the work.",
            visualization: .sequence
        ),
        Question(
            subject: .analysis,
            text: "uₙ is increasing and u_{2n} ≤ M for every n. Can we bound u_{2n+1}?",
            hint: "uₙ increasing: where does u_{2n+1} sit compared to u_{2n} and u_{2n+2}?",
            options: [
                "No, odd terms are independent from even ones",
                "Yes: u_{2n+1} ≤ u_{2n+2} ≤ M",
                "Yes, but only if uₙ is also bounded below",
                "No, we'd need the explicit formula for uₙ"
            ],
            correctIndex: 1,
            explanation: "uₙ increasing ⟹ u_{2n+1} ≤ u_{2n+2}. And u_{2n+2} is an even-indexed term, so u_{2n+2} ≤ M. So u_{2n+1} ≤ M without any extra assumption. Both odd and even terms of uₙ are bounded by M, so uₙ converges.",
            visualization: .sequence
        ),
    ]

    static let meanTheoremQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "On the graph, the rectangles (with height given by the Mean Value Theorem point) look poorly matched to f. What can we say about their total area?",
            hint: "How is cₖ chosen?",
            options: [
                "The area is an approximation of ∫f",
                "The area is exactly ∫f, no matter the subdivision",
                "The area is exact only if the rectangles touch the curve",
                "The area is exact only when δ → 0"
            ],
            correctIndex: 1,
            explanation: "The Mean Value Theorem guarantees f(cₖ)·δ = ∫[xₖ,xₖ₊₁] f exactly. The rectangle's height exactly compensates for where it overshoots and undershoots the curve.",
            visualization: .meanTheorem
        ),
        Question(
            subject: .analysis,
            text: "The Mean Value Theorem for integrals says: if f is continuous on [a,b], there exists c ∈ ]a,b[ such that...",
            hint: "It's the height of the rectangle whose area equals ∫f",
            options: [
                "f(c) = (f(a) + f(b)) / 2",
                "f(c) · (b-a) = ∫[a,b] f",
                "f'(c) = (f(b)-f(a)) / (b-a)",
                "∫[a,c] f = ∫[c,b] f"
            ],
            correctIndex: 1,
            explanation: "f(c) is the average value of f on [a,b]. Option C is the Mean Value Theorem for derivatives, not the integral version.",
            visualization: .meanTheorem
        ),
        Question(
            subject: .analysis,
            text: "f is continuous and positive on [a,b], and ∫[a,b] f = M·(b-a). What does M represent?",
            hint: "What does the theorem say?",
            options: [
                "The maximum of f on [a,b]",
                "The average value of f on [a,b]",
                "The value of f at the midpoint of [a,b]",
                "The derivative of f at some point in ]a,b["
            ],
            correctIndex: 1,
            explanation: "M = (1/(b-a)) ∫[a,b] f is by definition the average value of f. The theorem says there's a point c where f(c) = M.",
            visualization: .meanTheorem
        ),
        Question(
            subject: .analysis,
            text: "f is continuous on [a,b] and strictly increasing. Does the theorem guarantee a unique c?",
            hint: "Can a strictly increasing function hit the same value twice?",
            options: [
                "No, the theorem never says anything about uniqueness",
                "Yes, because f injective never takes the same value twice",
                "No, there can always be several",
                "Yes, but only if f is differentiable"
            ],
            correctIndex: 1,
            explanation: "The theorem guarantees at least one c such that f(c) = μ. If f is strictly increasing, it's injective, so this c is unique. Without strict monotonicity, several c's are possible — for example sin(2x) on [0, π] has average 0, reached at both π/4 and 3π/4.",
            visualization: .meanTheorem
        ),
    ]

    static let TFIQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "Let f, g be continuous on [a,b]. Which condition guarantees f = g on [a,b]?",
            hint: "Think about the Fundamental Theorem of Calculus... What do you get by differentiating ∫[a,x] f?",
            options: [
                "∫[a,b] f = ∫[a,b] g",
                "∫[a,x] f = ∫[a,x] g for every x ∈ [a,b]",
                "∫[a,b] f² = ∫[a,b] g²",
                "∫[a,b] |f| = ∫[a,b] |g|"
            ],
            correctIndex: 1,
            explanation: "Option A is false: f(x)=x and g(x)=-x on [-1,1] give ∫f = ∫g = 0 but f ≠ g. Option B is true: if F(x) = ∫[a,x] f = ∫[a,x] g = G(x) for every x, then differentiating gives F'(x) = f(x) = G'(x) = g(x) by the Fundamental Theorem. Options C and D are false: f and -f have the same integrals of f² and |f|.",
            visualization: .TFI
        ),
        Question(
            subject: .analysis,
            text: "Let F(x) = ∫[0,x] f with f continuous. What is F'(x)?",
            hint: "This is the direct statement of the Fundamental Theorem",
            options: [
                "F'(x) = f(x) - f(0)",
                "F'(x) = f(x)",
                "F'(x) = ∫[0,x] f'",
                "F'(x) = f(x²) · 2x"
            ],
            correctIndex: 1,
            explanation: "The Fundamental Theorem: F(x) = ∫[a,x] f is differentiable and F'(x) = f(x). Integrating then differentiating just gives back f.",
            visualization: .TFI
        ),
        Question(
            subject: .analysis,
            text: "f is continuous on [a,b], f ≥ 0, and ∫[a,x] f = 0 for every x ∈ [a,b]. What can we conclude?",
            hint: "Differentiate both sides — what does the theorem tell you?",
            options: [
                "f = 0 only at a",
                "∫[a,b] f = 0 but f could be nonzero elsewhere",
                "f = 0 on all of [a,b]",
                "We can only conclude this if f is differentiable"
            ],
            correctIndex: 2,
            explanation: "Let F(x) = ∫[a,x] f. By assumption F ≡ 0, so F' ≡ 0. But the theorem gives F'(x) = f(x) for every x. So f = 0 on [a,b]. The condition f ≥ 0 isn't even needed here — differentiating F does all the work.",
            visualization: .TFI
        ),
        Question(
            subject: .analysis,
            text: "f is continuous on ℝ and F(x) = ∫[x, 2x] f. What is F'(x)?",
            hint: "Split into two integrals with a fixed lower bound, then differentiate each",
            options: [
                "F'(x) = f(2x) − f(x)",
                "F'(x) = 2f(2x) − f(x)",
                "F'(x) = f(2x)",
                "F'(x) = 2f(2x)"
            ],
            correctIndex: 1,
            explanation: "F(x) = ∫[0,2x] f − ∫[0,x] f. Using the theorem plus the chain rule: (∫[0,2x] f)' = f(2x)·2, and (∫[0,x] f)' = f(x)·1. So F'(x) = 2f(2x) − f(x). The trap is forgetting the factor 2 from the upper bound.",
            visualization: .TFI
        ),
    ]

    // MARK: - Mean Value Theorem (derivative)
    static let TAFQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "How many points C does the Mean Value Theorem guarantee?",
            hint: "Re-read the exact statement of the theorem",
            options: [
                "Exactly one",
                "At least one",
                "At most one",
                "As many as the zeros of f"
            ],
            correctIndex: 1,
            explanation: "The Mean Value Theorem guarantees at least one C — not uniqueness. For sin(2πx), several such points can exist at once.",
            visualization: .TAF
        ),
        Question(
            subject: .analysis,
            text: "What are the hypotheses of the Mean Value Theorem?",
            hint: "What do the functions shown have in common?",
            options: [
                "f continuous on [a,b] and differentiable on ]a,b[",
                "f twice differentiable on [a,b]",
                "f(a) = f(b)",
                "f monotone on [a,b]"
            ],
            correctIndex: 0,
            explanation: "The Mean Value Theorem only requires f continuous on [a,b] and differentiable on ]a,b[.",
            visualization: .TAF
        ),
        Question(
            subject: .analysis,
            text: "f is differentiable on ℝ and f'(x) = 0 everywhere. What can we conclude?",
            hint: "Apply the theorem on any [a,b]",
            options: [
                "f is periodic",
                "f is constant",
                "f is zero",
                "f is affine"
            ],
            correctIndex: 1,
            explanation: "For any a < b, the theorem gives f(b)-f(a) = f'(c)·(b-a) = 0. So f(b) = f(a) for all a,b: f is constant.",
            visualization: .TAF
        ),
        Question(
            subject: .analysis,
            text: "f is differentiable on ]a,b[ with |f'(x)| ≤ M everywhere. What can we bound?",
            hint: "Apply the theorem and take absolute values",
            options: [
                "|f(b) - f(a)| ≤ M",
                "|f(b) - f(a)| ≤ M · (b-a)",
                "|f(b) - f(a)| ≤ M · (b-a)²",
                "|f(b)| ≤ M · |f(a)|"
            ],
            correctIndex: 1,
            explanation: "The theorem gives f(b)-f(a) = f'(c)·(b-a), so |f(b)-f(a)| = |f'(c)|·(b-a) ≤ M·(b-a). This is the mean value inequality, very useful for controlling regularity.",
            visualization: .TAF
        ),
    ]

    static let fixedPointQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "On the graph, f(A) > A and f(B) < B, with f continuous. What can we conclude?",
            hint: "Set g(x) = f(x) - x and apply the Intermediate Value Theorem",
            options: [
                "f has exactly one fixed point between A and B",
                "f has at least one fixed point between A and B",
                "f has no fixed point since it's decreasing",
                "We can't conclude anything without knowing f'(x)"
            ],
            correctIndex: 1,
            explanation: "g(x) = f(x)−x satisfies g(A) > 0 and g(B) < 0. By the Intermediate Value Theorem there's a c with g(c) = 0, i.e. f(c) = c. Not necessarily unique — try the 4th function.",
            visualization: .fixedPoint
        ),
        Question(
            subject: .analysis,
            text: "f is continuous and maps [0,1] into [0,1]. What is guaranteed?",
            hint: "Sketch f — can it avoid the diagonal y=x?",
            options: [
                "f has exactly one fixed point",
                "f has at least one fixed point in [0,1]",
                "f has a fixed point only if f is increasing",
                "Nothing, without extra assumptions"
            ],
            correctIndex: 1,
            explanation: "g(x) = f(x)-x satisfies g(0) = f(0) ≥ 0 and g(1) = f(1)-1 ≤ 0. The Intermediate Value Theorem gives a c with f(c) = c.",
            visualization: .fixedPoint
        ),
        Question(
            subject: .analysis,
            text: "f is continuous and strictly decreasing on [a,b] → [a,b]. How many fixed points?",
            hint: "Is g(x) = f(x) − x strictly monotone?",
            options: [
                "At least one, maybe several",
                "Exactly one",
                "None — a decreasing f can't cross y = x",
                "Depends on the value of f(a)"
            ],
            correctIndex: 1,
            explanation: "g(x) = f(x) − x is strictly decreasing (f decreasing) minus strictly increasing (−x): so g is strictly decreasing. It can only cross zero once. The Intermediate Value Theorem gives existence, strict monotonicity gives uniqueness.",
            visualization: .fixedPoint
        ),
        Question(
            subject: .analysis,
            text: "Does f(x) = x² have a fixed point on [0,1]?",
            hint: "Look for solutions of x² = x on [0,1]",
            options: [
                "No, x² < x on ]0,1[ so no intersection with y = x",
                "Yes, exactly one: x = 1",
                "Yes, two: x = 0 and x = 1",
                "Yes, but only if we extend past 1"
            ],
            correctIndex: 2,
            explanation: "x² = x ⟺ x(x−1) = 0 ⟺ x = 0 or x = 1. Both are in [0,1]. The Intermediate Value Theorem only guaranteed at least one — here we get two, at the endpoints. On the open interval ]0,1[, x² < x so no other fixed point.",
            visualization: .fixedPoint
        ),
    ]

    // MARK: - Convergence
    static let convergenceQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "For uₙ = sin(n²)/√n, a student claims: 'sin(n²) oscillates, so uₙ diverges.' Is this right?",
            hint: "Try to sandwich uₙ between two simple sequences",
            options: [
                "Yes, if sin(n²) doesn't converge, uₙ can't converge",
                "No — we can sandwich uₙ and show uₙ → 0",
                "We can't conclude without the exact values of sin(n²)",
                "Yes, because uₙ isn't monotone"
            ],
            correctIndex: 1,
            explanation: "|sin(n²)| ≤ 1 so -1/√n ≤ uₙ ≤ 1/√n. Since ±1/√n → 0, the Sandwich Theorem gives uₙ → 0.",
            visualization: .convergence
        ),
        Question(
            subject: .analysis,
            text: "For uₙ = sin(n)/n with ε = 0.1, a student finds N = 30 and concludes convergence. Is this enough?",
            hint: "The definition of convergence quantifies over every ε > 0",
            options: [
                "Yes — N = 30 works even if smaller N's exist",
                "No — we need the smallest possible N",
                "No — checking a single ε is not enough",
                "Yes — sin(n)/n is bounded so it converges"
            ],
            correctIndex: 2,
            explanation: "For that fixed ε, N = 30 is valid. But convergence requires that for every ε > 0 such an N exists. Checking ε = 0.1 is just one case.",
            visualization: .convergence
        ),
        Question(
            subject: .analysis,
            text: "uₙ = n·sin(1/n). What does this sequence converge to?",
            hint: "Substitute x = 1/n and think of a well-known limit as x → 0",
            options: [
                "0",
                "1",
                "+∞",
                "It diverges"
            ],
            correctIndex: 1,
            explanation: "n·sin(1/n) = sin(1/n)/(1/n) → 1 as n → ∞, since this is just the classic limit sin(x)/x → 1 as x → 0.",
            visualization: .convergence
        ),
        Question(
            subject: .analysis,
            text: "uₙ converges to L. What can we say about any subsequence uφ(n)?",
            hint: "Convergence of a sequence carries over to its subsequences",
            options: [
                "uφ(n) converges to some limit that depends on φ",
                "uφ(n) converges to L",
                "uφ(n) is bounded but not necessarily convergent",
                "uφ(n) converges to L only if φ is strictly increasing"
            ],
            correctIndex: 1,
            explanation: "If uₙ → L, then every subsequence also converges to L. This is immediate: for every ε > 0 there's N such that n ≥ N ⟹ |uₙ - L| < ε, and φ(n) ≥ n ≥ N when φ is strictly increasing.",
            visualization: .convergence
        ),
    ]

    static let lhopitalQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "Why can we write lim(x→0) sin(x)/x = cos(0)/1 = 1?",
            hint: "Zoom in on the graph — what do the two curves become near 0?",
            options: [
                "Because sin(0) = 0 and we simplify",
                "Near 0, sin(x) ≈ sin'(0)·x and x ≈ 1·x, so the x cancels and we're left with sin'(0)/1",
                "Because sin(x) = x for all x",
                "Because the limit of a ratio equals the ratio of the limits"
            ],
            correctIndex: 1,
            explanation: "L'Hôpital's rule: if f(0)=g(0)=0, then lim f/g = f'(0)/g'(0). Zooming in, each curve looks like its tangent line, the x cancels, leaving f'(0)/g'(0) = cos(0)/1 = 1.",
            visualization: .lhopital
        ),
        Question(
            subject: .analysis,
            text: "lim(x→a) f'/g' doesn't exist. Can we conclude that lim f/g doesn't exist either?",
            hint: "L'Hôpital says: if f'/g' converges, then f/g does too. What does it say in the other direction?",
            options: [
                "Yes, if f'/g' diverges then f/g diverges too",
                "No — L'Hôpital only works in one direction, f/g can still converge",
                "Yes, both limits always exist or fail to exist together",
                "No, but only if g'(a) = 0"
            ],
            correctIndex: 1,
            explanation: "L'Hôpital is a one-way implication: lim f'/g' = L ⟹ lim f/g = L. The converse is false. f/g can converge without f'/g' converging — in that case L'Hôpital simply doesn't apply, it says nothing.",
            visualization: .lhopital
        ),
        Question(
            subject: .analysis,
            text: "lim(x→0) (1 - cos(x))/x². Applying L'Hôpital once gives sin(x)/2x, still 0/0. What do we do?",
            hint: "The rule can be applied more than once",
            options: [
                "We conclude the limit is 0",
                "We apply L'Hôpital a second time: cos(x)/2 → 1/2",
                "We can't apply L'Hôpital anymore",
                "We go back to the definition"
            ],
            correctIndex: 1,
            explanation: "We apply L'Hôpital a second time: (sin x)' / (2x)' = cos(x)/2 → 1/2. The rule can be applied as many times as needed while the form stays indeterminate.",
            visualization: .lhopital
        ),
        Question(
            subject: .analysis,
            text: "lim(x→+∞) x·e^(-x). How do we rewrite this to apply L'Hôpital?",
            hint: "We need a 0/0 or ∞/∞ form",
            options: [
                "We can't, this isn't an indeterminate form",
                "Write it as x/eˣ (form ∞/∞), then L'Hôpital gives 1/eˣ → 0",
                "Write it as eˣ/x (form ∞/∞), then L'Hôpital gives eˣ → +∞",
                "Expand eˣ as a series"
            ],
            correctIndex: 1,
            explanation: "x·e^(-x) = x/eˣ is a ∞/∞ form. L'Hôpital: (x)'/(eˣ)' = 1/eˣ → 0. The exponential beats the polynomial.",
            visualization: .lhopital
        ),
    ]

    static let sandwichQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "uₙ = sin(n²)/√n. A student says sin(n²) oscillates, so uₙ diverges. Is this correct?",
            hint: "Sandwich sin(n²) between constants",
            options: [
                "Yes, since sin(n²) doesn't converge, uₙ doesn't either",
                "No — -1/√n ≤ uₙ ≤ 1/√n and both bounds → 0",
                "We can't conclude",
                "Yes, uₙ isn't monotone so it diverges"
            ],
            correctIndex: 1,
            explanation: "|sin(n²)| ≤ 1 so -1/√n ≤ uₙ ≤ 1/√n. Both bounds ±1/√n → 0, so the Sandwich Theorem gives uₙ → 0.",
            visualization: .sandwich
        ),
        Question(
            subject: .analysis,
            text: "uₙ → L and vₙ → L. We know uₙ ≤ wₙ ≤ vₙ only for even n, nothing for odd n. Can we conclude wₙ → L?",
            hint: "The Sandwich Theorem needs the sandwich to hold from some point onward — not just on a subsequence",
            options: [
                "Yes — sandwiching half the terms is enough asymptotically",
                "No — the sandwich must hold for all n past some point, not just on even indices",
                "Yes, if in addition w_{2n+1} is bounded",
                "No, but at least w_{2n} → L"
            ],
            correctIndex: 1,
            explanation: "The Sandwich Theorem requires the sandwich for all n ≥ N₀, not just on a subsequence. We can conclude w_{2n} → L, but wₙ itself entirely escapes the theorem — the odd terms are uncontrolled.",
            visualization: .sandwich
        ),
        Question(
            subject: .analysis,
            text: "Can we apply the Sandwich Theorem if uₙ → 0 and vₙ → 1 with uₙ ≤ wₙ ≤ vₙ?",
            hint: "What's the condition on the bounds' limits?",
            options: [
                "Yes, wₙ → 1/2",
                "Yes, wₙ converges to some limit between 0 and 1",
                "No — the Squeeze Theorem requires both bounds to converge to the same limit",
                "No — the Squeeze Theorem only applies to positive sequences"
            ],
            correctIndex: 2,
            explanation: "The Sandwich Theorem requires uₙ → L and vₙ → L with the same L. If the bounds have different limits, we can't conclude anything about wₙ.",
            visualization: .sandwich
        ),
        Question(
            subject: .analysis,
            text: "wₙ = (2 + sin(n)) / n. Find a sandwich and conclude.",
            hint: "Sandwich sin(n) and divide by n",
            options: [
                "wₙ diverges because sin(n) oscillates",
                "wₙ → 0 by the Squeeze Theorem: 1/n ≤ wₙ ≤ 3/n",
                "wₙ → 1 because sin(n)/n → 0",
                "wₙ → 2 because sin(n) is negligible"
            ],
            correctIndex: 1,
            explanation: "-1 ≤ sin(n) ≤ 1 so 1 ≤ 2+sin(n) ≤ 3, giving 1/n ≤ wₙ ≤ 3/n. Since 1/n → 0 and 3/n → 0, wₙ → 0 by the Sandwich Theorem.",
            visualization: .sandwich
        ),
    ]

    static let taylorQuestions: [Question] = [
        Question(
            subject: .analysis,
            text: "On what interval does the order-3 Taylor approximation of sin(x) stay within 0.1 of the real value?",
            hint: "T₃(x) = x − x³/6 — look at where the error curve crosses the threshold",
            options: ["[-π/4, π/4]", "[-π/2, π/2]", "[-π, π]", "[-2, 2]"],
            correctIndex: 1,
            explanation: "The error |sin(x) − (x − x³/6)| exceeds 0.1 around ±π/2. Beyond that, the missing order-5 term becomes too large.",
            visualization: .taylor
        ),
        Question(
            subject: .analysis,
            text: "What is the order-n Taylor expansion of f at 0?",
            hint: "It's a polynomial — what's its key property at 0?",
            options: [
                "The degree-n polynomial minimizing the error on [-1,1]",
                "The degree-n polynomial matching f at 0 up to the n-th derivative",
                "The best affine approximation of f",
                "The interpolating polynomial through n+1 points of f"
            ],
            correctIndex: 1,
            explanation: "Tₙ is the unique polynomial of degree ≤ n such that Tₙ⁽ᵏ⁾(0) = f⁽ᵏ⁾(0) for k = 0,...,n. It matches f at 0, at every order up to n.",
            visualization: .taylor
        ),
        Question(
            subject: .analysis,
            text: "f is even and infinitely differentiable at 0. What can we say about its Taylor series?",
            hint: "Compute f'(0) using f(-x) = f(x)",
            options: [
                "Its Taylor series only has even powers",
                "Its Taylor series only has odd powers",
                "Its Taylor series alternates even and odd signs",
                "We can't say anything without computing the derivatives"
            ],
            correctIndex: 0,
            explanation: "f even ⟹ f'(0) = 0. Indeed f'(x) = lim (f(x+h)−f(x))/h, and parity forces f'(0) = −f'(0), so f'(0) = 0. Similarly every odd-order derivative of f is odd, so it vanishes at 0. All odd Taylor coefficients are zero — only even powers remain.",
            visualization: .taylor
        ),
        Question(
            subject: .analysis,
            text: "What is the order-2 Taylor expansion of cos(x) at 0?",
            hint: "cos(0)=1, cos'(0)=0, cos''(0)=-1",
            options: [
                "1 + x²/2",
                "1 - x²/2",
                "1 - x + x²/2",
                "x - x³/6"
            ],
            correctIndex: 1,
            explanation: "T₂(x) = cos(0) + cos'(0)·x + cos''(0)·x²/2! = 1 + 0 - x²/2 = 1 - x²/2. The x term disappears since cos is even.",
            visualization: .taylor
        ),
    ]
}
 
