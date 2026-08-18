//
//  Challenge.swift
//  EPFLearn
//
//  Inverted quiz: the visualization *is* the question. Instead of picking
//  an option, the student drags the figure until it satisfies a stated
//  condition, and the manipulation itself is graded.
//
//  Grading is deliberately *not* live. An earlier version showed a
//  warmer/colder meter, which turned every challenge into a homing game:
//  wiggle the figure, watch the bar, stop when it goes green. Nothing was
//  understood. The answer is committed with an explicit Check instead, and
//  nothing about the current state is echoed under the prompt: every figure
//  already prints its own values, so repeating them was duplication.
//
//  Four rules the banks follow, all learned by getting them wrong:
//
//  * Six challenges per subject, spread across as many figures as the subject
//    has instrumented, so a run never hammers the same picture six times.
//  * A target must not be reachable by opening a preset menu and picking the
//    obviously named entry. "Build an injective map" was solved by choosing
//    Identity, which teaches nothing.
//  * A target must stay inside the figure's comfortable range. A product of
//    5i is arithmetically fine and visually useless, because the plot has to
//    zoom out until both operands are specks.
//  * A challenge must be about a property, not about operating a slider.
//    "Refine until the gap is small" is just dragging a control to its end.
//

import Foundation

// MARK: - What a visualization reports while being manipulated

struct ComplexReading: Equatable {
    var z1re: Double, z1im: Double
    var z2re: Double, z2im: Double
    var resultRe: Double, resultIm: Double
    var isProduct: Bool

    var z1Modulus: Double { (z1re * z1re + z1im * z1im).squareRoot() }
    var z2Modulus: Double { (z2re * z2re + z2im * z2im).squareRoot() }
}

/// The mean value theorem picture: an interval [a, b] the student drags, and
/// how many interior points match the chord's slope.
struct MeanValueReading: Equatable {
    var a: Double, b: Double
    var fa: Double, fb: Double
    /// Interior points where f'(c) equals the slope of the chord.
    var matchingPoints: Int

    var width: Double { b - a }
    /// Rolle's hypothesis: the chord is horizontal.
    var endpointsLevel: Bool { abs(fa - fb) < 0.02 }
}

struct VectorReading: Equatable {
    var v1x: Double, v1y: Double
    var v2x: Double, v2y: Double
    var det: Double
    var is3D: Bool

    /// The two products that split |v₁||v₂|: dot takes the cosine, det the sine.
    var dot: Double { v1x * v2x + v1y * v2y }
    var v1Length: Double { (v1x * v1x + v1y * v1y).squareRoot() }
    var v2Length: Double { (v2x * v2x + v2y * v2y).squareRoot() }
}

/// A map in space together with the one vector the figure tracks through it,
/// drawn as v and Av.
struct SpaceMapReading: Equatable {
    var vx: Double, vy: Double, vz: Double
    var avx: Double, avy: Double, avz: Double
    var det: Double
    var morph: Double

    var vNorm: Double { (vx * vx + vy * vy + vz * vz).squareRoot() }

    /// Distance from Av to k·v, which is what "v is an eigenvector with
    /// eigenvalue k" means.
    func distanceToMultiple(_ k: Double) -> Double {
        let dx = avx - k * vx, dy = avy - k * vy, dz = avz - k * vz
        return (dx * dx + dy * dy + dz * dz).squareRoot()
    }
}

/// Just the shapes: whether a product is even defined is a question about
/// dimensions alone, before any entry is looked at.
struct MatrixShapeReading: Equatable {
    var aRows: Int, aCols: Int
    var bRows: Int, bCols: Int
    var operation: String

    var abDefined: Bool { aCols == bRows }
    var baDefined: Bool { bCols == aRows }
}

struct LinearMapReading: Equatable {
    var rank: Int
    /// The nine entries, column by column.
    var entries: [Double]
    var morph: Double

    var hasZeroEntry: Bool { entries.contains { abs($0) < 0.05 } }
}

struct BitwiseReading: Equatable {
    var a: Int, b: Int, result: Int
    var op: String
    var shift: Int
}

struct LoopReading: Equatable {
    var nested: Bool
    var from: Int, to: Int, by: Int
    var outer: Int, inner: Int
    /// How many times the body runs, worked out by the view from its own header.
    var iterations: Int
}

struct PigeonholeReading: Equatable {
    var items: Int
    var holes: Int
    /// ⌈items / holes⌉: the size the principle forces on some hole.
    var guaranteed: Int
}

/// Two discs on the board, reported by how they sit relative to each other
/// rather than in raw pixels, plus which region is currently shaded: a claim
/// about sets is only made once the student points at the region proving it.
struct SetsReading: Equatable {
    var centreDistance: Double
    var radiusA: Double
    var radiusB: Double
    var threeSets: Bool
    var region: String

    var disjoint: Bool { centreDistance >= radiusA + radiusB - 1 }
    var aInsideB: Bool { centreDistance + radiusA <= radiusB + 1 }
    var identical: Bool { centreDistance < 4 && abs(radiusA - radiusB) < 4 }
}

/// A law shaped by dragging bar heights: the values it can take, how likely
/// each is, and where the mean lands.
struct ExpectationReading: Equatable {
    var values: [Int]
    var probabilities: [Double]
    var mean: Double

    /// The indices carrying real weight. A bar dragged to nothing is still a
    /// value on the axis, but it is not one the variable ever takes.
    private var liveIndices: [Int] {
        values.indices.filter { probabilities[$0] > 0.05 }
    }

    var inPlay: [Int] { liveIndices.map { values[$0] } }
    var inPlayProbabilities: [Double] { liveIndices.map { probabilities[$0] } }
}

struct PascalPick: Equatable, Hashable, Comparable {
    var n: Int
    var k: Int
    static func < (a: Self, b: Self) -> Bool { (a.n, a.k) < (b.n, b.k) }
}

struct PascalReading: Equatable {
    /// Sorted, so two selections of the same cells compare equal.
    var picks: [PascalPick]
    var total: Int
}

enum ChallengeReading: Equatable {
    case complexPlane(ComplexReading)
    case unitCircle(theta: Double)
    case meanValue(MeanValueReading)
    case vectorSpace(VectorReading)
    case spaceMap(SpaceMapReading)
    case matrixShape(MatrixShapeReading)
    case linearMap(LinearMapReading)
    case bitwise(BitwiseReading)
    case loop(LoopReading)
    case pigeonhole(PigeonholeReading)
    case sets(SetsReading)
    case pascal(PascalReading)
    case expectation(ExpectationReading)
    /// The visualization is on screen but hasn't reported anything usable yet.
    case idle
}

// MARK: - What the student sees while building

struct ChallengeFeedback {
    /// Whether the figure as it stands satisfies the target. Consulted only
    /// when the student commits: never surfaced as a live proximity hint.
    var satisfied: Bool
    /// A precondition outside the reasoning, e.g. the wrong operator selected.
    /// Worth saying out loud, because it isn't the answer. Everything else is
    /// already printed on the figure, so nothing is echoed under the prompt.
    var blocker: String?

    init(satisfied: Bool, blocker: String? = nil) {
        self.satisfied = satisfied
        self.blocker = blocker
    }

    static let waiting = ChallengeFeedback(satisfied: false)
}

// MARK: - Challenge

struct Challenge: Identifiable {
    let id = UUID()
    let subject: Subject
    let visualization: VisualizationType
    /// The instruction, phrased as something to *do*, not to pick.
    let prompt: String
    /// Why the solved state is the answer, as a worked numeric example.
    let explanation: String
    let evaluate: (ChallengeReading) -> ChallengeFeedback
}

extension Challenge {

    // MARK: - Analysis 1/3: the complex plane

    static let complexChallenges: [Challenge] = [
        Challenge(subject: .analysis, visualization: .complexNumbers,
                  prompt: "Put z₁ and z₂ both on the unit circle so that their product is i, without giving them the same angle.",
                  explanation: """
                  Multiplying adds the arguments. The target i sits at π/2, so the two angles have to add up to π/2, and the moduli are already 1 each so their product is 1 as well.

                  Worked example: θ₁ = π/6 and θ₂ = π/3. Together they make π/6 + π/3 = π/2, so z₁·z₂ = i. Both are marked angles on the circle, so the two points snap into place.

                  The obvious split π/4 and π/4 also lands on i, which is why the prompt rules it out: it works without ever using the fact that the arguments add, since one point is simply the other.
                  """) { reading in
            guard case .complexPlane(let r) = reading else { return .waiting }
            guard r.isProduct else {
                return ChallengeFeedback(satisfied: false,
                                         blocker: "Switch the operator to • so the product is on screen.")
            }
            guard abs(r.z1Modulus - 1) < 0.08 && abs(r.z2Modulus - 1) < 0.08 else {
                return ChallengeFeedback(satisfied: false,
                                         blocker: "Put both points on the unit circle first: the modulus snaps to 1 when you get close.")
            }
            let apart = ((r.z1re - r.z2re) * (r.z1re - r.z2re)
                       + (r.z1im - r.z2im) * (r.z1im - r.z2im)).squareRoot()
            guard apart > 0.15 else {
                return ChallengeFeedback(satisfied: false,
                                         blocker: "The two angles have to differ: π/4 twice is the split the prompt excludes.")
            }
            let d = (r.resultRe * r.resultRe + (r.resultIm - 1) * (r.resultIm - 1)).squareRoot()
            return ChallengeFeedback(satisfied: d < 0.15)
        },

        Challenge(subject: .analysis, visualization: .complexNumbers,
                  prompt: "Let z₁ ∈ ℂ with |z₁| ≠ 1. Place z₂ so that it is the inverse of z₁, that is z₁ · z₂ = 1.",
                  explanation: """
                  Multiplying multiplies moduli and adds arguments. To land on 1, whose modulus is 1 and argument 0, the inverse must have modulus 1/|z₁| and the opposite argument.

                  Worked example: z₁ = 2 at angle π/4. Then z₂ has modulus 1/2 and angle −π/4. Note the two arrows point on opposite sides of the real axis and one is short where the other is long.

                  The condition |z₁| ≠ 1 rules out the easy case: on the unit circle the inverse is just the mirror image across the real axis, with no rescaling to work out.
                  """) { reading in
            guard case .complexPlane(let r) = reading else { return .waiting }
            guard r.isProduct else {
                return ChallengeFeedback(satisfied: false,
                                         blocker: "Switch the operator to • so the product is on screen.")
            }
            guard abs(r.z1Modulus - 1) > 0.12 else {
                return ChallengeFeedback(satisfied: false,
                                         blocker: "Move z₁ off the unit circle first: |z₁| must not be 1.")
            }
            let d = ((r.resultRe - 1) * (r.resultRe - 1) + r.resultIm * r.resultIm).squareRoot()
            return ChallengeFeedback(satisfied: d < 0.15)
        }
    ]

    // MARK: - Analysis 2/3: the unit circle

    private static func angleTarget(_ prompt: String,
                                    explanation: String,
                                    accepting targets: [Double]) -> Challenge {
        Challenge(subject: .analysis, visualization: .trigo,
                  prompt: prompt, explanation: explanation) { reading in
            guard case .unitCircle(let theta) = reading else { return .waiting }
            let d = targets.map { abs(TrigAngles.distance(theta, $0)) }.min() ?? .pi
            return ChallengeFeedback(satisfied: d < 0.05)
        }
    }

    static let trigoChallenges: [Challenge] = [
        angleTarget("Set θ so that cos θ = cos(π/3) and sin θ = −sin(π/3).",
                    explanation: """
                    Cosine is even and sine is odd: cos(−θ) = cos θ while sin(−θ) = −sin θ. Keeping the cosine and flipping the sine is therefore asking for −θ, and −π/3 measured the positive way round is 5π/3.

                    Worked example: at π/3 the point is (1/2, √3/2), so cos = 0.50 and sin ≈ 0.87. At 5π/3 the point is (1/2, −√3/2): same 0.50 across, the height simply changed sign. The two points are mirror images across the horizontal axis.

                    The trap is 2π/3, which flips the cosine and keeps the sine. That is the mirror across the vertical axis, the other reflection.
                    """,
                    accepting: [5 * .pi / 3]),

        angleTarget("Let θ be the angle on the unit circle. Set it so that tan θ = −1 while sin θ stays positive.",
                    explanation: """
                    tan θ = −1 needs sine and cosine equal in size and opposite in sign, which puts the point on the line y = −x. That line meets the circle twice, and the sign of the sine chooses between them.

                    Worked example: θ = 3π/4 gives cos θ ≈ −0.71 and sin θ ≈ 0.71, so the ratio is −1 and the point sits above the axis.

                    The other crossing, 7π/4, has the same tangent but a negative sine.
                    """,
                    accepting: [3 * .pi / 4])
    ]

    // MARK: - Analysis 3/3: the mean value theorem and Rolle

    private static func meanValueChallenge(_ prompt: String,
                                           explanation: String,
                                           satisfied: @escaping (MeanValueReading) -> Bool) -> Challenge {
        Challenge(subject: .analysis, visualization: .TAF,
                  prompt: prompt, explanation: explanation) { reading in
            guard case .meanValue(let m) = reading else { return .waiting }
            guard m.width > 0.3 else {
                return ChallengeFeedback(satisfied: false,
                                         blocker: "Pull a and b apart: the theorem needs a genuine interval.")
            }
            return ChallengeFeedback(satisfied: satisfied(m))
        }
    }

    static let meanValueChallenges: [Challenge] = [
        meanValueChallenge(
            "Let f be continuous on [a, b]. Choose a function and an interval where f(a) = f(b) and at least two interior tangents come out horizontal.",
            explanation: """
            When f(a) = f(b) the chord is flat, so Rolle hands you a point inside with f'(c) = 0. It promises one; it never says how many.

            Worked example: cos(πx) from a = −0.5 to b = 1.5. Both ends sit at 0, and the curve turns over twice in between, so two tangents come out level.

            x⁴ − x² on [−1.2, 1.2] gives three, at 0 and at ±1/√2.
            """,
            satisfied: { $0.endpointsLevel && $0.matchingPoints >= 2 }),

        meanValueChallenge(
            "Let f be continuous on [a, b]. Choose a function and an interval where f(a) = f(b), yet no interior tangent is horizontal at all.",
            explanation: """
            Rolle also needs f to be differentiable inside the interval. Drop that and the conclusion goes with it.

            Worked example: |x| from a = −1 to b = 1. Both ends are 1, so the chord is flat, but the slope is −1 on the left and +1 on the right, never 0, and at x = 0 there is no derivative at all.

            Keep a and b on the same side of the corner and the function is a plain line there, so the theorem applies again.
            """,
            satisfied: { $0.endpointsLevel && $0.matchingPoints == 0 })
    ]

    // MARK: - Linear algebra 1/4: determinant against dot product

    private static func planarGuard(_ reading: ChallengeReading,
                                    _ body: (VectorReading) -> ChallengeFeedback) -> ChallengeFeedback {
        guard case .vectorSpace(let v) = reading else { return .waiting }
        guard !v.is3D else {
            return ChallengeFeedback(satisfied: false,
                                     blocker: "This one is about the plane: switch the space back to ℝ².")
        }
        return body(v)
    }

    /// The first draws its target fresh each run so the answer cannot be
    /// carried over from the last attempt.
    static func vectorChallenges() -> [Challenge] {
        let target = [2.0, 3.0, -2.0, -3.0].randomElement() ?? 2.0
        let label = target < 0 ? "−\(Int(abs(target)))" : "\(Int(target))"

        return [
            Challenge(subject: .linearAlgebra, visualization: .determinant,
                      prompt: "Let v₁, v₂ ∈ ℝ². Draw a shape of zero area whose dot product is \(label).",
                      explanation: """
                      One pair of arrows, two products. The determinant is |v₁||v₂|·sin θ, the area they enclose. The dot product is |v₁||v₂|·cos θ. Kill one and everything goes into the other.

                      Zero area means sin θ = 0, so the arrows lie on the same line and the parallelogram flattens to a segment. Then cos θ = ±1 and the dot product is just ±|v₁||v₂|.

                      Worked example for 2: v₁ = (2, 0) and v₂ = (1, 0). Flat, so det = 0, and 2×1 = 2. Point v₂ backwards for −2.
                      """) { reading in
                planarGuard(reading) { v in
                    ChallengeFeedback(satisfied: abs(v.dot - target) < 0.12 && abs(v.det) < 0.06
                                        && v.v1Length > 0.3 && v.v2Length > 0.3)
                }
            },

            Challenge(subject: .linearAlgebra, visualization: .determinant,
                      prompt: "Let v₁, v₂ ∈ ℝ². Keep the area at exactly 1 while stretching v₁ to a length of at least 1.5.",
                      explanation: """
                      Area is base times height. Lengthen the base and the height has to come down to pay for it, so v₂ must lose exactly as much of its perpendicular part as v₁ gained in length.

                      Worked example: start from the unit square, v₁ = (1, 0) and v₂ = (0, 1), area 1. Stretch v₁ to (2, 0) and the area doubles to 2, so bring v₂ down to (0, 0.5): det = 2 × 0.5 − 0 × 0 = 1 again.

                      What v₂ does sideways is free. (1, 0.5) and (−3, 0.5) both give area 1 against v₁ = (2, 0), because sliding v₂ along the direction of v₁ shears the shape without changing its height. One area, an entire family of very different-looking parallelograms.
                      """) { reading in
                planarGuard(reading) { v in
                    ChallengeFeedback(satisfied: abs(abs(v.det) - 1) < 0.07
                                        && v.v1Length >= 1.5)
                }
            }
        ]
    }

    // MARK: - Linear algebra 2/4: shapes

    private static func shapeChallenge(_ prompt: String,
                                       explanation: String,
                                       satisfied: @escaping (MatrixShapeReading) -> Bool) -> Challenge {
        Challenge(subject: .linearAlgebra, visualization: .matrixOperations,
                  prompt: prompt, explanation: explanation) { reading in
            guard case .matrixShape(let m) = reading else { return .waiting }
            guard m.operation.hasPrefix("Multiply") else {
                return ChallengeFeedback(satisfied: false,
                                         blocker: "Pick the multiplication operation: this is about when a product exists at all.")
            }
            return ChallengeFeedback(satisfied: satisfied(m))
        }
    }

    static let shapeChallenges: [Challenge] = [
        shapeChallenge(
            "Let A be m×n and B be p×q. Set the four numbers so that AB exists but BA does not.",
            explanation: """
            AB exists only when the inner dimensions agree: A's columns must match B's rows. Turning the product around asks for the other pair to match instead, which is a different condition.

            Worked example: A is 2×3 and B is 3×3. AB works and comes out 2×3, because A's 3 columns meet B's 3 rows. BA would need B's 3 columns to meet A's 2 rows, and 3 ≠ 2, so it does not exist.

            This is the bluntest way matrix multiplication fails to commute: often only one order is even legal.
            """,
            satisfied: { $0.abDefined && !$0.baDefined }),

        shapeChallenge(
            "Let A be m×n and B be p×q. Set the four numbers so that AB and BA both exist and come out the same size.",
            explanation: """
            AB is m×q and BA is p×n. Both existing means n = p and q = m. Asking them to be the same size adds m = p and q = n, and the four conditions together force all four numbers equal: A and B must both be square, of the same order.

            Worked example: A and B both 3×3. Then AB and BA are both 3×3.

            Even then the two products are usually different matrices. Same shape is the most you get for free; equality almost never follows.
            """,
            satisfied: { m in
                m.abDefined && m.baDefined
                    && m.aRows == m.aCols && m.bRows == m.bCols && m.aRows == m.bRows
            })
    ]

    // MARK: - Linear algebra 3/4: kernel and image

    static let linearMapChallenges: [Challenge] = [
        Challenge(subject: .linearAlgebra, visualization: .image,
                  prompt: "Let A be a map of ℝ³. Make its image a plane, with none of the nine entries equal to zero.",
                  explanation: """
                  A column is redundant when it is a combination of the others, and that has nothing to do with zeros. Rank–nullity does the rest: an image of dimension 2 forces a kernel of dimension 1.

                  Worked example: columns (1,2,3), (2,1,1) and (3,3,4). The third is the sum of the first two, entry by entry. No zero anywhere, yet the rank is 2 and the kernel is the line through (1,1,−1).

                  Every preset carries zeros, so none of them is an answer. Set the third column to the sum of the first two by hand.
                  """) { reading in
            // The rank is read off the matrix itself, not off the animation,
            // so where the transformation slider happens to sit is irrelevant.
            guard case .linearMap(let m) = reading else { return .waiting }
            return ChallengeFeedback(satisfied: m.rank == 2 && !m.hasZeroEntry)
        }
    ]

    // MARK: - Linear algebra 4/4: a map acting on one vector

    static let spaceMapChallenges: [Challenge] = [
        Challenge(subject: .linearAlgebra, visualization: .linearTransformations,
                  prompt: "Let A be a map of ℝ³ and v the tracked vector, with v ≠ 0. Set A so that det A = 2 while Av stays exactly equal to v.",
                  explanation: """
                  det A = 2 says the unit cube leaves with twice its volume. Av = v says the map does not move v at all. So all the stretching has to happen in the two directions v does not use.

                  Worked example: point v along x, then take A diagonal with entries 1, 2, 1. The x-axis is untouched, so Av = v, and 1 × 2 × 1 = 2.

                  A quick route on screen: start from the Scaling preset, then pull its x and z entries back to 1 and leave y at 2. Diagonal entries 1, 4, 0.5 work just as well, since 1 × 4 × 0.5 is also 2.
                  """) { reading in
            // Av is computed from the matrix itself, so the slider position
            // does not enter into it.
            guard case .spaceMap(let m) = reading else { return .waiting }
            // A(0) = 0 for every linear map, so the zero vector is fixed by
            // anything at all and proves nothing about A.
            guard m.vNorm > 0.3 else {
                return ChallengeFeedback(satisfied: false,
                                         blocker: "v = 0 is fixed by every map there is, so it settles nothing. Give v some length.")
            }
            return ChallengeFeedback(satisfied: m.distanceToMultiple(1) < 0.2
                                        && abs(m.det - 2) < 0.12)
        }
    ]

    // MARK: - Programming 1/2: bitwise operators

    private static func bitwiseChallenge(_ prompt: String,
                                         explanation: String,
                                         satisfied: @escaping (BitwiseReading) -> Bool) -> Challenge {
        Challenge(subject: .programmingBasics, visualization: .bitwiseOperations,
                  prompt: prompt, explanation: explanation) { reading in
            guard case .bitwise(let r) = reading else { return .waiting }
            return ChallengeFeedback(satisfied: satisfied(r))
        }
    }

    static let bitwiseChallenges: [Challenge] = [
        bitwiseChallenge(
            "Let a be the byte on screen. Pick the operator and second operand that switch bit 5 on and leave every other bit alone.",
            explanation: """
            OR writes a 1 where either side has one and leaves a bit untouched where the mask has a 0. So a | (1 << 5) sets bit 5 and nothing else.

            Worked example: 0000_0011 with the mask 0010_0000 gives 0010_0011. Bits 0 and 1 survive because the mask is 0 there.

            AND would clear everything except bit 5, and XOR would toggle it rather than set it.
            """,
            satisfied: { $0.op == "|" && $0.b == 1 << 5 }),

        bitwiseChallenge(
            "Let a be the byte on screen, with bit 3 currently on. Switch that bit off and leave every other bit exactly as it was.",
            explanation: """
            Setting a bit is OR with a mask holding a single 1. Clearing one is the mirror image: AND with a mask holding a single 0, which is ~(1 << 3) = 1111_0111.

            Worked example: 1101_1010 & 1111_0111 = 1101_0010. Bit 3 is gone and every other column survives, because the mask is 1 there.

            In this view there is no ~ to combine with a mask, so switch the "b = 1 << k" toggle off and tap b's bits directly: all 1s except a 0 at position 3. Bit 3 is the fourth column counting from the right, where the indices are printed above the row.
            """,
            satisfied: { r in
                let bit3 = 1 << 3
                return r.op == "&" && (r.a & bit3) != 0 && r.result == (r.a & ~bit3)
            }),

        bitwiseChallenge(
            "Let a be the byte on screen. Flip exactly its low four bits and leave the high four alone.",
            explanation: """
            XOR flips a bit where the mask has a 1 and leaves it where the mask has a 0, which makes it the toggle operator. The low four bits are 0000_1111.

            Worked example: 1010_0110 XOR 0000_1111 = 1010_1001. The high nibble is unchanged, the low one became its complement.

            Doing it twice returns the original, which is why XOR is the operator for reversible masking.
            """,
            satisfied: { $0.op == "^" && $0.b == 0x0F })
    ]

    // MARK: - Programming 2/2: loop bounds

    private static func loopChallenge(_ prompt: String,
                                      explanation: String,
                                      satisfied: @escaping (LoopReading) -> Bool) -> Challenge {
        Challenge(subject: .programmingBasics, visualization: .forLoop,
                  prompt: prompt, explanation: explanation) { reading in
            guard case .loop(let l) = reading else { return .waiting }
            return ChallengeFeedback(satisfied: satisfied(l))
        }
    }

    static let loopChallenges: [Challenge] = [
        loopChallenge(
            "Set the three numbers of the single loop so that the body executes exactly 3 times, and i moves by more than 1 each pass.",
            explanation: """
            With `for (i = from; i < to; i += by)` the body runs ⌈(to − from) / by⌉ times.

            Worked example: from 0, to 6, step 2 visits i = 0, 2, 4 and stops, because 6 is not < 6. Three passes. From 1, to 10, step 3 visits 1, 4, 7: also three.

            The usual slip is to read to − from as the count and forget to divide by the step.
            """,
            satisfied: { !$0.nested && $0.iterations == 3 && $0.by > 1 }),

        loopChallenge(
            "Set the single loop so that its body never executes, not even once.",
            explanation: """
            A `for` loop tests its condition before the first pass, so it can run zero times. A do-while cannot.

            Worked example: from 5, to 5. The test 5 < 5 is false straight away and the body is skipped.

            Any starting value at or past the bound does it. This is why a variable first assigned inside a loop is not safe to read after it.
            """,
            satisfied: { !$0.nested && $0.iterations == 0 }),

        loopChallenge(
            "Switch to the nested loops and set the two bounds so that the inner body executes exactly 12 times.",
            explanation: """
            Nesting multiplies: the inner loop runs in full on each outer pass, so the body executes outer × inner times.

            Worked example: outer 3 and inner 4 give 12, and so do outer 4 and inner 3.

            The two are the same count but not the same order of visits, which matters as soon as the body depends on it. This product is where an O(n²) cost comes from.
            """,
            satisfied: { $0.nested && $0.iterations == 12 })
    ]

    // MARK: - Discrete maths 1/3: the pigeonhole principle

    private static func pigeonholeChallenge(_ prompt: String,
                                            explanation: String,
                                            satisfied: @escaping (PigeonholeReading) -> Bool) -> Challenge {
        Challenge(subject: .discreteMaths, visualization: .pigeonholePrinciple,
                  prompt: prompt, explanation: explanation) { reading in
            guard case .pigeonhole(let p) = reading else { return .waiting }
            return ChallengeFeedback(satisfied: satisfied(p))
        }
    }

    static let pigeonholeChallenges: [Challenge] = [
        pigeonholeChallenge(
            "Model this: five people meet, and each shakes hands with at least one and at most four of the others. Set the figure to show that two of them must have shaken the same number of hands.",
            explanation: """
            The trap is deciding what the holes are. They are not the people: they are the possible answers to "how many hands did you shake", which run from 1 to 4. That is four holes for five people.

            Worked example: ⌈5/4⌉ = 2, so two people share a count. Note the bound 4 is doing real work. Without it a person could shake 0 hands, giving five possible counts for five people and forcing nothing.

            Almost every pigeonhole exercise is this step: the items are usually obvious and the holes almost never are.
            """,
            satisfied: { $0.items == 5 && $0.holes == 4 }),

        pigeonholeChallenge(
            "Model this: you want a group large enough that three of its members are guaranteed to share a birth month. Set the smallest such group.",
            explanation: """
            Twelve months are the holes. Forcing three means going past what two per month would cover, so past 2 × 12 = 24.

            Worked example: with 24 people the spread of two per month exists, so nothing is guaranteed. With 25 it cannot, and some month holds three. ⌈25/12⌉ = 3.

            The pattern is 2m + 1 for three, 3m + 1 for four, and (k−1)m + 1 in general. Recognising which k the question is asking for is the actual work.
            """,
            satisfied: { $0.holes == 12 && $0.items == 25 })
    ]

    // MARK: - Discrete maths 2/3: sets as regions

    /// `region` is the shading the claim is made with. Drawing the right discs
    /// while pointing at the wrong region is not the answer: knowing which
    /// region settles the question is the exercise.
    /// `check` returns a whole verdict rather than a Bool, so a condition
    /// with two halves pulling opposite ways can say which half is missing.
    private static func setsChallenge(_ prompt: String,
                                      explanation: String,
                                      region: String,
                                      check: @escaping (SetsReading) -> ChallengeFeedback) -> Challenge {
        Challenge(subject: .discreteMaths, visualization: .setOperations,
                  prompt: prompt, explanation: explanation) { reading in
            guard case .sets(let s) = reading else { return .waiting }
            // Both claims here are about two sets; a third disc on the board
            // only muddies which region is being pointed at.
            guard !s.threeSets else {
                return ChallengeFeedback(satisfied: false,
                                         blocker: "Turn the third circle off: this is a claim about two sets.")
            }
            guard s.region == region else {
                return ChallengeFeedback(satisfied: false,
                                         blocker: "Select \(region) from the region menu: that is the region the claim is about.")
            }
            return check(s)
        }
    }

    static let setsChallenges: [Challenge] = [
        setsChallenge(
            "Let A, B ⊆ Ω. Select the region A ∩ Bᶜ, then arrange A and B so that A ∩ Bᶜ = A.",
            explanation: """
            A ∩ Bᶜ is everything in A that lies outside B. For it to be all of A, removing B must have taken nothing away, and that means A and B never met.

            Worked example: two discs of radius 60 whose centres are 130 apart. Since 130 > 120, nothing is in both, and the shading fills A completely.

            The point is the form of the statement: A ∩ Bᶜ = A says "disjoint" without ever mentioning the intersection, which is how the same idea gets written in probability as P(A ∩ Bᶜ) = P(A).
            """,
            region: "A ∩ Bᶜ",
            check: { s in
                s.disjoint && !s.identical
                    ? .init(satisfied: true)
                    : .init(satisfied: false)
            }),

        setsChallenge(
            "Let A, B ⊆ Ω. Select the region (A ∪ B)ᶜ, then arrange A and B so that (A ∪ B)ᶜ = Bᶜ, with A strictly smaller than B.",
            explanation: """
            (A ∪ B)ᶜ is everything outside both sets. For it to coincide with Bᶜ, every point outside B has to be outside A as well, which says the same thing as every point of A lying inside B. So the condition is A ⊆ B.

            Worked example: B of radius 80 centred at (130, 122), A of radius 30 centred at (140, 122). The centres are 10 apart and 10 + 30 ≤ 80, so A sits inside B. Then A ∪ B = B, and taking complements of both sides gives (A ∪ B)ᶜ = Bᶜ.

            Note the move: a statement about containment became a statement about complements, and the shading made the swap visible instead of symbolic. It is the same step De Morgan's laws formalise.
            """,
            region: "(A ∪ B)ᶜ",
            check: { s in
                // Two equal discs really do satisfy the identity, so refusing
                // them without a word looks like a broken checker.
                if s.identical {
                    return .init(satisfied: false,
                                 blocker: "A = B does make (A ∪ B)ᶜ equal Bᶜ, but the prompt asks for a strict subset. Shrink A inside B.")
                }
                return .init(satisfied: s.aInsideB)
            })
    ]

    // MARK: - Discrete maths 3/3: Pascal's triangle

    private static func pascalChallenge(_ prompt: String,
                                        explanation: String,
                                        satisfied: @escaping (PascalReading) -> Bool) -> Challenge {
        Challenge(subject: .discreteMaths, visualization: .binomialCoefficients,
                  prompt: prompt, explanation: explanation) { reading in
            guard case .pascal(let p) = reading else { return .waiting }
            guard !p.picks.isEmpty else {
                return ChallengeFeedback(satisfied: false,
                                         blocker: "Tap entries in the triangle to select them.")
            }
            return ChallengeFeedback(satisfied: satisfied(p))
        }
    }

    static let pascalChallenges: [Challenge] = [
        pascalChallenge(
            "A set S has 6 elements, and x is one of them. Since x has to be in, the only real choice is over the other 5. Select the entries that count the subsets of S containing x, one per possible size.",
            explanation: """
            The trap is to reach for row 6. Row 6 counts every subset of S, and only half of those contain x.

            Build such a subset instead: x is compulsory, and the rest is any subset of the other 5 elements. So the subsets of S containing x correspond exactly to the subsets of a 5-element set, and the counts you want are C(5,0), C(5,1), … C(5,5) — the whole of row 5.

            Worked example: the subsets of S containing x that have 3 elements are x plus 2 of the remaining 5, and there are C(5,2) = 10 of them. Read straight off row 6, size 3 would have said C(6,3) = 20, which counts the ones without x as well.

            The total is 1 + 5 + 10 + 10 + 5 + 1 = 32 = 2⁵, exactly half of the 64 subsets of S. That is the shortest proof that any fixed element belongs to half of all subsets: pairing each subset with the one you get by adding or removing x matches them up two by two.
            """,
            satisfied: { p in
                p.picks == (0...5).map { PascalPick(n: 5, k: $0) } && p.total == 32
            })
    ]

    // MARK: - Discrete maths 4/4: expectation

    static let expectationChallenges: [Challenge] = [
        Challenge(subject: .discreteMaths, visualization: .expectation,
                  prompt: "Give X five possible values. Then drag the bars so that three of them become impossible and the two lowest are left equally likely.",
                  explanation: """
                  Worked example: values 1 to 5, with 1/2 on the value 1 and 1/2 on the value 2, and nothing anywhere else. Then E[X] = 1(0.5) + 2(0.5) = 1.5, exactly halfway between the two.

                  Equal weights are what put it halfway. Tilt them to 0.7 and 0.3 and the mean slides to 1.3, closer to the heavier side: the mean is a balance point, and it sits nearer whichever value pulls harder.

                  Look at what that number is not. It is not a value X can take, and it is nowhere near 3, the middle of the range. The three top values sit on the axis and contribute 0 each to the sum, because a term xᵢ·P(X = xᵢ) with probability 0 is worth nothing however large xᵢ is.

                  So the range of a variable tells you nothing about its mean. Stretch the axis out to 1…100 and keep the weight on 1 and 2: the mean stays at 1.5. Only where the weight sits matters, which is why E[X] is called the balance point of the law and not its centre.
                  """) { reading in
            guard case .expectation(let e) = reading else { return .waiting }
            guard e.values.count == 5 else {
                return ChallengeFeedback(satisfied: false,
                                         blocker: "X needs exactly five possible values: set the count to 5 first.")
            }
            let live = e.inPlay
            guard live.count == 2 else {
                return ChallengeFeedback(satisfied: false,
                                         blocker: live.count > 2
                                            ? "\(live.count) values still carry weight. Three of the five have to be impossible."
                                            : "Two values have to stay up: with one, the mean is simply that value.")
            }
            guard live == Array(e.values.prefix(2)) else {
                return ChallengeFeedback(satisfied: false,
                                         blocker: "The two that stay standing have to be the two lowest values.")
            }
            // Equal weights put the mean exactly halfway, which is the point:
            // a balance point between two values, on neither of them.
            let w = e.inPlayProbabilities
            guard w.count == 2, abs(w[0] - w[1]) < 0.10 else {
                return ChallengeFeedback(satisfied: false,
                                         blocker: "The two remaining bars have to be the same height, so both values are equally likely.")
            }
            let lo = Double(live[0]), hi = Double(live[1])
            return ChallengeFeedback(satisfied: e.mean > lo + 0.15 && e.mean < hi - 0.15)
        }
    ]

    /// Whether a subject appears at all in Build mode. Cheap enough to call
    /// from a view body, unlike `challenges(for:)`, which shuffles and draws
    /// a fresh random target every time it runs.
    static func hasChallenges(for subject: Subject) -> Bool {
        switch subject {
        case .analysis, .linearAlgebra, .programmingBasics, .discreteMaths: return true
        case .arrays, .graphs: return false
        }
    }

    /// Six per subject, spread across as many different figures as the subject
    /// has instrumented, so a run never repeats one view six times.
    static func challenges(for subject: Subject) -> [Challenge] {
        switch subject {
        case .analysis:
            return (complexChallenges + trigoChallenges + meanValueChallenges).shuffled()
        case .linearAlgebra:
            return (vectorChallenges() + shapeChallenges
                    + linearMapChallenges + spaceMapChallenges).shuffled()
        case .programmingBasics:
            return (bitwiseChallenges + loopChallenges).shuffled()
        case .discreteMaths:
            return (pigeonholeChallenges + setsChallenges
                    + pascalChallenges + expectationChallenges).shuffled()
        case .arrays, .graphs:
            return []
        }
    }
}
