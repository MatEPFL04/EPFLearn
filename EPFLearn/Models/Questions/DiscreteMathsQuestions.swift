
import Foundation


let combinatoricsQuestions = [
    
    Question(
        subject: .discreteMaths,
        text: "How many ways can you arrange 5 different books on a shelf?",
        hint: "Order matters.. so it's a permutation",
        options: ["20", "60", "120", "240"],
        correctIndex: 2,
        explanation: "Each slot removes one book from the pool: 5 × 4 × 3 × 2 × 1 = 5! = 120.",
        visualization: .combinatorics
    ),
    Question(
        subject: .discreteMaths,
        text: "In how many ways can you choose 3 people from a group of 7?",
        hint: "The committee has no roles, so order does not matter.",
        options: ["21", "35", "42", "210"],
        correctIndex: 1,
        explanation: "C(7,3) = (7 × 6 × 5) / 3! = 210 / 6 = 35. Dividing by 3! removes the orderings of the same trio.",
        visualization: .combinatorics
    ),
    Question(
        subject: .discreteMaths,
        text: "From 7 distinct balls, how many distinct pair of two balls can we form ?",
        hint: "It is not a permutation, order doesn't matter.",
        options: ["10", "21", "32", "120"],
        correctIndex: 1,
        explanation: "Order doesn't matter, so this is C(7,2) = 7 * 6 / 2 = 21",
        visualization: .combinatorics
    ),
]

// MARK: - Permutations  →  CombinatoricsView

let permutationsQuestions = [
    
    Question(
        subject: .discreteMaths,
        text: "From 5 runners, how many different gold–silver podiums are possible?",
        hint: "Two slots, and swapping the two medals gives a different podium. Use the view and choose the right type",
        options: ["10", "20", "25", "120"],
        correctIndex: 1,
        explanation: "Order matters, so this is P(5,2) = 5 × 4 = 20.",
        visualization: .permutations
    ),
    Question(
        subject: .discreteMaths,
        text: "In how many ways can 5 people be seated around a round table?",
        hint: "Fix one person, the problem now becomes a permutation problem",
        options: ["24", "60", "120", "5"],
        correctIndex: 0,
        explanation: "Fix one person to kill the rotations: the other 4 can be arranged in (5−1)! = 4! = 24 ways.",
        visualization: .permutations
    ),
    Question(
        subject: .discreteMaths,
        text: "How many distinguishable ways can you line up 3 identical red balls and 2 identical blue balls?",
        hint: "Think about choosing the spots for the red balls",
        options: ["6", "10", "12", "20"],
        correctIndex: 1,
        explanation: "5! / (3!·2!) = 10, which is also C(5,3): pick the 3 positions taken by the red balls.",
        visualization: .permutations
    ),
    Question(
        subject: .discreteMaths,
        text: "How many 3-letter codes with no repeated letter can be built from A, B, C, D?",
        hint: "Three ordered slots, and each letter can be used at most once.",
        options: ["12", "24", "64", "4"],
        correctIndex: 1,
        explanation: "P(4,3) = 4 × 3 × 2 = 24.",
        visualization: .permutations
    )
]

// MARK: - Binomial coefficients  →  BinomialCoefficientsView

let binomialQuestions = [
    Question(
        subject: .discreteMaths,
        text: "What is C(6,2) + C(6,4)?",
        hint: "Look at where those two entries sit in row 6 of Pascal's triangle.",
        options: ["15", "30", "45", "60"],
        correctIndex: 1,
        explanation: "By symmetry C(6,4) = C(6,2) = 15, so the sum is 30.",
        visualization: .binomialCoefficients
    ),
    Question(
        subject: .discreteMaths,
        text: "What is the coefficient of x⁴ in the expansion of (1 + x)⁸?",
        hint: "Expanding means choosing, from 8 factors, which ones contribute an x.",
        options: ["56", "70", "84", "120"],
        correctIndex: 1,
        explanation: "The binomial theorem gives C(8,4) = 8! / (4!·4!) = 70.",
        visualization: .binomialCoefficients
    ),
    
    Question(
        subject: .discreteMaths,
        text: "According to Pascal's identity, C(n,k) + C(n,k+1) equals:",
        hint: "Each entry of the triangle is built from the two directly above it.",
        options: ["C(n+1,k)", "C(n,k+2)", "C(n+1,k+1)", "C(n+2,k)"],
        correctIndex: 2,
        explanation: "C(n,k) + C(n,k+1) = C(n+1,k+1): the two parents add up to the child below them.",
        visualization: .binomialCoefficients
    ),
]

// MARK: - Pigeonhole principle  →  PigeonholePrincipleView

let pigeonholeQuestions = [
    Question(
        subject: .discreteMaths,
        text: "If 13 people are in a room, at least how many were born in the same month?",
        hint: "13 pigeons, 12 \"boxes\"",
        options: ["1", "2", "3", "12"],
        correctIndex: 1,
        explanation: "If every month held at most 1 person the room would hold at most 12 people. So ⌈13/12⌉ = 2 share a month.",
        visualization: .pigeonholePrinciple
    ),
    Question(
        subject: .discreteMaths,
        text: "Your friend holds 10 pairs of socks (20 socks). How many must you pull out to guarantee a matching pair?",
        hint: "Imagine the unluckiest possible draw, then take one more sock.",
        options: ["2", "10", "11", "20"],
        correctIndex: 2,
        explanation: "Worst case you draw one sock of each of the 10 colours. The 11th sock must repeat a colour.",
        visualization: .pigeonholePrinciple
    ),
    Question(
        subject: .discreteMaths,
        text: "Among 367 people, at least how many must share a birthday (ignoring leap years)?",
        hint: "365 possible days.",
        options: ["1", "2", "3", "367"],
        correctIndex: 1,
        explanation: "⌈367/365⌉ = 2. Note this is a guarantee, not a probability — no 'birthday paradox' needed.",
        visualization: .pigeonholePrinciple
    ),
    Question(
        subject: .discreteMaths,
        text: "In a class of 25 students, at least how many were born on the same day of the week?",
        hint: "25 pigeons, 7 \"boxes\", spread the students as evenly as you can.",
        options: ["3", "4", "5", "7"],
        correctIndex: 1,
        explanation: "The fairest spread is 4+4+4+4+3+3+3 = 25, so ⌈25/7⌉ = 4 is forced.",
        visualization: .pigeonholePrinciple
    ),
]


// MARK: - Set operations  →  VennDiagramView

let setOperationsQuestions = [
    
    Question(
        subject: .discreteMaths,
        text: "By De Morgan's law, (A ∪ B)ᶜ equals:",
        hint: "Being outside the union means escaping both sets at once.",
        options: ["Aᶜ ∪ Bᶜ", "Aᶜ ∩ Bᶜ", "A ∩ B", "(A ∩ B)ᶜ"],
        correctIndex: 1,
        explanation: "Not in (A or B) means not in A and not in B: (A ∪ B)ᶜ = Aᶜ ∩ Bᶜ.",
        visualization: .setOperations
    ),
    Question(
        subject: .discreteMaths,
        text: "The set A \\ B can be rewritten as:",
        hint: "Removing B is the same as intersecting with everything outside B.",
        options: ["A ∩ Bᶜ", "Aᶜ ∩ B", "A ∪ Bᶜ", "(A ∩ B)ᶜ"],
        correctIndex: 0,
        explanation: "A \\ B = A ∩ Bᶜ — keep what is in A while staying outside B.",
        visualization: .setOperations
    ),
    Question(
        subject: .discreteMaths,
        text: "If A ⊆ B, what is A ∩ B?",
        hint: "Drag the disc for A entirely inside the disc for B.",
        options: ["A", "B", "∅", "A ∪ B"],
        correctIndex: 0,
        explanation: "When A sits inside B, the overlap is all of A: A ∩ B = A (and A ∪ B = B).",
        visualization: .setOperations
    ),
    Question(
        subject: .discreteMaths,
        text: "A universe Ω has 50 elements and |A| = 30. What is |Aᶜ|?",
        hint: "The complement is everything in the rectangle outside the disc.",
        options: ["15", "20", "30", "50"],
        correctIndex: 1,
        explanation: "|Aᶜ| = |Ω| − |A| = 50 − 30 = 20.",
        visualization: .setOperations
    ),
    
]

// MARK: - Recurrence relations  →  RecurrenceRelationsView

let recurrenceQuestions = [
    Question(
        subject: .discreteMaths,
        text: "A sequence satisfies aₙ = 2aₙ₋₁ + 3 with a₀ = 1. What is a₃?",
        hint: "Unfold one step at a time: a₁, then a₂, then a₃.",
        options: ["11", "17", "21", "29"],
        correctIndex: 3,
        explanation: "a₁ = 2·1 + 3 = 5, a₂ = 2·5 + 3 = 13, a₃ = 2·13 + 3 = 29.",
        visualization: .recurrenceRelations
    ),
    Question(
        subject: .discreteMaths,
        text: "Tower of Hanoi: T(n) = 2T(n−1) + 1 with T(1) = 1. What is T(4)?",
        hint: "Each extra disk doubles the previous work and adds one move.",
        options: ["7", "11", "15", "31"],
        correctIndex: 2,
        explanation: "T(2) = 3, T(3) = 7, T(4) = 2·7 + 1 = 15 — which is 2⁴ − 1.",
        visualization: .recurrenceRelations
    ),
    Question(
        subject: .discreteMaths,
        text: "A geometric sequence has first term 2 and common ratio 3. What is its 5th term?",
        hint: "Going from the 1st to the 5th term means multiplying 4 times.",
        options: ["54", "162", "243", "486"],
        correctIndex: 1,
        explanation: "a₅ = 2 · 3⁴ = 2 · 81 = 162.",
        visualization: .recurrenceRelations
    ),
    Question(
        subject: .discreteMaths,
        text: "With F₀ = 0 and F₁ = 1, what is F₇?",
        hint: "Build upwards — each term is the sum of the two before it.",
        options: ["8", "13", "21", "34"],
        correctIndex: 1,
        explanation: "0, 1, 1, 2, 3, 5, 8, 13 — so F₇ = 13.",
        visualization: .recurrenceRelations
    ),
    Question(
        subject: .discreteMaths,
        text: "A sequence satisfies aₙ = aₙ₋₁ + 3 with a₀ = 1. What is a₆?",
        hint: "Adding the same step every time makes the growth linear.",
        options: ["16", "18", "19", "21"],
        correctIndex: 2,
        explanation: "aₙ = 1 + 3n, so a₆ = 1 + 18 = 19.",
        visualization: .recurrenceRelations
    )
]


let closedFormQuestions = [
    Question(
        subject: .discreteMaths,
        text: "What is the closed form of T(n) = 2T(n−1) + 1 with T(1) = 1?",
        hint: "Unfold it: T(n) = 2T(n−1) + 1 = 4T(n−2) + 3 = 8T(n−3) + 7…",
        options: ["2ⁿ", "2ⁿ − 1", "n² − 1", "2n − 1"],
        correctIndex: 1,
        explanation: "The constants 1, 3, 7, 15 are 2ᵏ − 1, and substituting the base case gives T(n) = 2ⁿ − 1.",
        visualization: .generatingFunctions
    ),
    Question(
        subject: .discreteMaths,
        text: "What is the closed form of aₙ = 2aₙ₋₁ with a₀ = 1?",
        hint: "Multiplying by 2 exactly n times.",
        options: ["2ⁿ", "n²", "2n", "n!"],
        correctIndex: 0,
        explanation: "Unfolding gives aₙ = 2·2·…·2·a₀ = 2ⁿ.",
        visualization: .generatingFunctions
    ),
    Question(
        subject: .discreteMaths,
        text: "Which of these recurrences grows the fastest?",
        hint: "Compare the shapes on a logarithmic scale.",
        options: ["aₙ = aₙ₋₁ + 3", "aₙ = aₙ₋₁ + n", "Fₙ = Fₙ₋₁ + Fₙ₋₂", "aₙ = 2aₙ₋₁"],
        correctIndex: 3,
        explanation: "Doubling gives 2ⁿ, which beats Fibonacci's φⁿ ≈ 1.618ⁿ, the quadratic aₙ = aₙ₋₁ + n, and the linear one.",
        visualization: .generatingFunctions
    ),
    Question(
        subject: .discreteMaths,
        text: "A sequence satisfies aₙ = 3aₙ₋₁ with a₀ = 2. What is a₄?",
        hint: "Closed form first, then substitute.",
        options: ["54", "162", "243", "486"],
        correctIndex: 1,
        explanation: "aₙ = 2 · 3ⁿ, so a₄ = 2 · 81 = 162.",
        visualization: .generatingFunctions
    ),
    Question(
        subject: .discreteMaths,
        text: "Computing Fₙ with the naive recursive definition (two recursive calls, no memoisation) costs roughly:",
        hint: "The call tree branches twice at almost every node.",
        options: ["O(n)", "O(n log n)", "O(n²)", "exponential time"],
        correctIndex: 3,
        explanation: "The number of calls grows like φⁿ. Working bottom-up instead computes Fₙ in O(n) additions.",
        visualization: .generatingFunctions
    )
]


let probabilityQuestions = [
    Question(
        subject: .discreteMaths,
        text: "What is the probability of rolling a sum of 7 with two fair dice?",
        hint: "List the favourable pairs: (1,6), (2,5), (3,4), (4,3), (5,2), (6,1).",
        options: ["1/6", "1/9", "5/36", "1/12"],
        correctIndex: 0,
        explanation: "6 favourable outcomes out of 36 equally likely pairs: 6/36 = 1/6.",
        visualization: .probability
    ),
    Question(
        subject: .discreteMaths,
        text: "If P(A) = 0.4, P(B) = 0.5 and A and B are independent, what is P(A ∩ B)?",
        hint: "Independence turns 'and' into a product of probabilities.",
        options: ["0.1", "0.2", "0.3", "0.9"],
        correctIndex: 1,
        explanation: "P(A ∩ B) = P(A) · P(B) = 0.4 × 0.5 = 0.2.",
        visualization: .probability
    ),
    Question(
        subject: .discreteMaths,
        text: "What is the probability of getting at least one head in 3 coin flips?",
        hint: "The opposite event is much easier to count.",
        options: ["3/4", "7/8", "1/2", "5/8"],
        correctIndex: 1,
        explanation: "P(all tails) = (1/2)³ = 1/8, so P(at least one head) = 1 − 1/8 = 7/8.",
        visualization: .probability
    ),
    Question(
        subject: .discreteMaths,
        text: "What is the probability of drawing a heart from a standard 52-card deck?",
        hint: "Each of the four suits is equally represented.",
        options: ["1/13", "1/4", "1/2", "4/13"],
        correctIndex: 1,
        explanation: "13 hearts out of 52 cards: 13/52 = 1/4.",
        visualization: .probability
    ),
]

// MARK: - Expectation  →  ExpectationView

let expectationQuestions = [
    Question(
        subject: .discreteMaths,
        text: "A fair six-sided die is rolled. What is the expected value?",
        hint: "E[X] is the balance point of the distribution.",
        options: ["3", "3.5", "4", "4.5"],
        correctIndex: 1,
        explanation: "E[X] = (1+2+3+4+5+6)/6 = 3.5, a value the die can never actually show.",
        visualization: .expectation
    ),
    Question(
        subject: .discreteMaths,
        text: "You win 10 CHF with probability 0.3 and nothing otherwise. What are your expected winnings?",
        hint: "Weight each payoff by how often it happens.",
        options: ["3 CHF", "5 CHF", "7 CHF", "10 CHF"],
        correctIndex: 0,
        explanation: "E[X] = 10 × 0.3 + 0 × 0.7 = 3 CHF.",
        visualization: .expectation
    ),
    Question(
        subject: .discreteMaths,
        text: "X has P(X=1) = 0.5, P(X=2) = 0.3 and P(X=3) = 0.2. What is E[X]?",
        hint: "E[X] = Σ x · P(X = x)",
        options: ["1.5", "1.7", "2.0", "2.2"],
        correctIndex: 1,
        explanation: "0.5 + 0.6 + 0.6 = 1.7. The mass leans towards 1, so the balance point sits below the middle.",
        visualization: .expectation
    ),
    Question(
        subject: .discreteMaths,
        text: "A fair coin pays 1 point for heads and 0 for tails. What is the expected total over 10 flips?",
        hint: "Add up the expectation of each individual flip.",
        options: ["1", "5", "10", "0.5"],
        correctIndex: 1,
        explanation: "Each flip has expectation 0.5, and by linearity 10 × 0.5 = 5.",
        visualization: .expectation
    )
]

// MARK: - Propositional logic  →  CNFView

let propositionalLogicQuestions = [
    Question(
        subject: .discreteMaths,
        text: "The implication p → q is false in exactly one case. Which one?",
        hint: "A promise is only broken when the condition holds but the result does not.",
        options: ["p false, q true", "p true, q false", "p and q both true", "p and q both false"],
        correctIndex: 1,
        explanation: "p → q fails only when p is true and q is false. All three other rows make it true.",
        visualization: .propositionalLogic
    ),
    Question(
        subject: .discreteMaths,
        text: "How many rows does the truth table of a formula with 3 variables have?",
        hint: "Each variable independently takes one of two values.",
        options: ["3", "6", "8", "9"],
        correctIndex: 2,
        explanation: "2³ = 8 rows, one per assignment of true/false to p, q and r.",
        visualization: .propositionalLogic
    ),
    Question(
        subject: .discreteMaths,
        text: "The formula p ∨ ¬p is:",
        hint: "Check both rows of its truth table.",
        options: ["a contradiction", "a tautology", "a contingency", "not well-formed"],
        correctIndex: 1,
        explanation: "It is true in every row, so it is a tautology.",
        visualization: .propositionalLogic
    ),
    Question(
        subject: .discreteMaths,
        text: "¬(p ∧ q) is logically equivalent to:",
        hint: "Intuitively, not-(both) means at least one fails",
        options: ["¬p ∧ ¬q", "¬p ∨ ¬q", "p ∨ q", "p → q"],
        correctIndex: 1,
        explanation: "De Morgan's law:  ¬(p ∧ q) ≡ ¬p ∨ ¬q.",
        visualization: .propositionalLogic
    ),
    
]


