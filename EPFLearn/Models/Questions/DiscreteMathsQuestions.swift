//
//  DiscreteMathsQuestions.swift
//  EPFLearn
//
//  Created on 20.07.2026.
//

import Foundation

// MARK: - Combinatorics Questions

let combinatoricsQuestions = [
    Question(
        subject: .discreteMaths,
        text: "How many ways can you arrange 5 different books on a shelf?",
        hint: "Use the factorial formula: n!",
        options: ["20", "60", "120", "240"],
        correctIndex: 2,
        explanation: "5! = 5 × 4 × 3 × 2 × 1 = 120. This is the number of permutations of 5 distinct objects.",
        visualization: .combinatorics
    ),
    Question(
        subject: .discreteMaths,
        text: "How many subsets does a set with 4 elements have?",
        hint: "Each element can either be included or not included in a subset.",
        options: ["8", "12", "16", "24"],
        correctIndex: 2,
        explanation: "A set with n elements has 2ⁿ subsets. For n=4: 2⁴ = 16 (including the empty set and the set itself).",
        visualization: .combinatorics
    ),
    Question(
        subject: .discreteMaths,
        text: "In how many ways can you choose 3 people from a group of 7?",
        hint: "This is a combination problem: C(n,k) = n! / (k!(n-k)!)",
        options: ["21", "35", "42", "210"],
        correctIndex: 1,
        explanation: "C(7,3) = 7!/(3!×4!) = (7×6×5)/(3×2×1) = 35. Order doesn't matter when choosing.",
        visualization: .combinatorics
    ),
    Question(
        subject: .discreteMaths,
        text: "How many 4-digit PIN codes can you create using digits 0-9 if repetition is allowed?",
        hint: "For each position, you have 10 choices.",
        options: ["5040", "10000", "40", "1024"],
        correctIndex: 1,
        explanation: "10 × 10 × 10 × 10 = 10⁴ = 10000. Each of the 4 positions can be any digit from 0 to 9.",
        visualization: .combinatorics
    )
]

// MARK: - Permutations Questions

let permutationsQuestions = [
    Question(
        subject: .discreteMaths,
        text: "How many distinct arrangements can be made from the letters in 'MISSISSIPPI'?",
        hint: "Use the formula for permutations with repetition: n! / (n₁! × n₂! × ... × nₖ!)",
        options: ["34650", "39916800", "11!", "6930"],
        correctIndex: 0,
        explanation: "11 letters total: M(1), I(4), S(4), P(2). Result = 11!/(1!×4!×4!×2!) = 34650.",
        visualization: .permutations
    ),
    Question(
        subject: .discreteMaths,
        text: "In how many ways can 5 people sit in a circle?",
        hint: "Circular permutations: (n-1)!",
        options: ["24", "60", "120", "5"],
        correctIndex: 0,
        explanation: "Circular permutations of n objects = (n-1)!. Here: (5-1)! = 4! = 24.",
        visualization: .permutations
    ),
    Question(
        subject: .discreteMaths,
        text: "How many ways can you arrange 3 red balls and 2 blue balls in a row?",
        hint: "This is a permutation with repetition.",
        options: ["6", "10", "12", "20"],
        correctIndex: 1,
        explanation: "5!/(3!×2!) = (5×4)/(2×1) = 10. We divide by repetitions of identical objects.",
        visualization: .permutations
    )
]

// MARK: - Binomial Coefficients Questions

let binomialQuestions = [
    Question(
        subject: .discreteMaths,
        text: "What is C(6,2) + C(6,4)?",
        hint: "Remember Pascal's identity and symmetry: C(n,k) = C(n,n-k)",
        options: ["15", "30", "45", "60"],
        correctIndex: 1,
        explanation: "C(6,2) = 15 and C(6,4) = C(6,2) = 15 by symmetry. Total = 15 + 15 = 30.",
        visualization: .binomialCoefficients
    ),
    Question(
        subject: .discreteMaths,
        text: "What is the coefficient of x⁴ in the expansion of (1 + x)⁸?",
        hint: "Use the binomial theorem: (1+x)ⁿ = Σ C(n,k)xᵏ",
        options: ["56", "70", "84", "120"],
        correctIndex: 1,
        explanation: "The coefficient is C(8,4) = 8!/(4!×4!) = 70.",
        visualization: .binomialCoefficients
    ),
    Question(
        subject: .discreteMaths,
        text: "What is C(10,3) equal to?",
        hint: "C(n,k) = n!/(k!(n-k)!)",
        options: ["30", "120", "720", "1000"],
        correctIndex: 1,
        explanation: "C(10,3) = 10!/(3!×7!) = (10×9×8)/(3×2×1) = 720/6 = 120.",
        visualization: .binomialCoefficients
    ),
    Question(
        subject: .discreteMaths,
        text: "According to Pascal's triangle, C(n,k) + C(n,k+1) = ?",
        hint: "This is Pascal's identity.",
        options: ["C(n+1,k)", "C(n,k+2)", "C(n+1,k+1)", "C(n+2,k)"],
        correctIndex: 2,
        explanation: "Pascal's identity: C(n,k) + C(n,k+1) = C(n+1,k+1). Each entry is the sum of the two above it.",
        visualization: .binomialCoefficients
    )
]

// MARK: - Pigeonhole Principle Questions

let pigeonholeQuestions = [
    Question(
        subject: .discreteMaths,
        text: "If 13 people are in a room, at least how many were born in the same month?",
        hint: "There are 12 months in a year. Apply the pigeonhole principle.",
        options: ["1", "2", "3", "12"],
        correctIndex: 1,
        explanation: "By the pigeonhole principle: ⌈13/12⌉ = 2. At least 2 people must share a birth month.",
        visualization: .pigeonholePrinciple
    ),
    Question(
        subject: .discreteMaths,
        text: "You have 10 pairs of socks (20 socks total) in a dark drawer. How many must you pull out to guarantee a matching pair?",
        hint: "Worst case: you pick one from each pair first.",
        options: ["2", "10", "11", "20"],
        correctIndex: 2,
        explanation: "Worst case: you pick 10 different socks (one from each pair). The 11th must match one of them.",
        visualization: .pigeonholePrinciple
    ),
    Question(
        subject: .discreteMaths,
        text: "In a group of 367 people, at least how many must have the same birthday (ignoring leap years)?",
        hint: "There are 365 days in a year.",
        options: ["1", "2", "3", "367"],
        correctIndex: 1,
        explanation: "⌈367/365⌉ = 2. By the pigeonhole principle, at least 2 people share the same birthday.",
        visualization: .pigeonholePrinciple
    )
]

// MARK: - Inclusion-Exclusion Questions

let inclusionExclusionQuestions = [
    Question(
        subject: .discreteMaths,
        text: "In a class of 30 students, 18 study French, 15 study Spanish, and 8 study both. How many study neither?",
        hint: "Use |A ∪ B| = |A| + |B| - |A ∩ B|",
        options: ["3", "5", "7", "10"],
        correctIndex: 1,
        explanation: "|A ∪ B| = 18 + 15 - 8 = 25 study at least one. So 30 - 25 = 5 study neither.",
        visualization: .inclusionExclusion
    ),
    Question(
        subject: .discreteMaths,
        text: "How many integers from 1 to 100 are divisible by 2 or 3?",
        hint: "Count multiples of 2, add multiples of 3, subtract multiples of 6.",
        options: ["50", "60", "67", "83"],
        correctIndex: 2,
        explanation: "Multiples of 2: 50, of 3: 33, of 6: 16. By inclusion-exclusion: 50 + 33 - 16 = 67.",
        visualization: .inclusionExclusion
    ),
    Question(
        subject: .discreteMaths,
        text: "Given |A| = 20, |B| = 15, |A ∩ B| = 8, what is |A ∪ B|?",
        hint: "Apply the inclusion-exclusion principle directly.",
        options: ["27", "35", "43", "12"],
        correctIndex: 0,
        explanation: "|A ∪ B| = |A| + |B| - |A ∩ B| = 20 + 15 - 8 = 27.",
        visualization: .inclusionExclusion
    )
]

// MARK: - Recurrence Relations Questions

let recurrenceQuestions = [
    Question(
        subject: .discreteMaths,
        text: "A sequence satisfies aₙ = 2aₙ₋₁ + 3 with a₀ = 1. What is a₃?",
        hint: "Calculate iteratively: a₁, then a₂, then a₃.",
        options: ["11", "17", "21", "29"],
        correctIndex: 3,
        explanation: "a₁ = 2(1) + 3 = 5, a₂ = 2(5) + 3 = 13, a₃ = 2(13) + 3 = 29.",
        visualization: .recurrenceRelations
    ),
    Question(
        subject: .discreteMaths,
        text: "Tower of Hanoi: Moving n disks requires T(n) = 2T(n-1) + 1 moves with T(1)=1. What is T(4)?",
        hint: "Build up: T(2), T(3), then T(4).",
        options: ["7", "11", "15", "31"],
        correctIndex: 2,
        explanation: "T(1)=1, T(2)=2×1+1=3, T(3)=2×3+1=7, T(4)=2×7+1=15.",
        visualization: .recurrenceRelations
    ),
    Question(
        subject: .discreteMaths,
        text: "A geometric sequence has first term 2 and ratio 3. What is the 5th term?",
        hint: "Geometric sequence: aₙ = a₁ × rⁿ⁻¹",
        options: ["54", "162", "243", "486"],
        correctIndex: 1,
        explanation: "a₅ = 2 × 3⁴ = 2 × 81 = 162.",
        visualization: .recurrenceRelations
    )
]

// MARK: - Probability Questions

let probabilityQuestions = [
    Question(
        subject: .discreteMaths,
        text: "What is the probability of rolling a sum of 7 with two fair dice?",
        hint: "Count favorable outcomes: (1,6), (2,5), (3,4), (4,3), (5,2), (6,1).",
        options: ["1/6", "1/9", "5/36", "1/12"],
        correctIndex: 0,
        explanation: "6 favorable outcomes out of 36 possible: 6/36 = 1/6.",
        visualization: .probability
    ),
    Question(
        subject: .discreteMaths,
        text: "A bag has 5 red balls and 3 blue balls. What's the probability of drawing a blue ball?",
        hint: "P(blue) = (number of blue) / (total balls)",
        options: ["3/8", "3/5", "5/8", "1/2"],
        correctIndex: 0,
        explanation: "3 blue out of 8 total: P(blue) = 3/8.",
        visualization: .probability
    ),
    Question(
        subject: .discreteMaths,
        text: "If P(A) = 0.4 and P(B) = 0.5, and A and B are independent, what is P(A ∩ B)?",
        hint: "For independent events: P(A ∩ B) = P(A) × P(B)",
        options: ["0.1", "0.2", "0.3", "0.9"],
        correctIndex: 1,
        explanation: "P(A ∩ B) = P(A) × P(B) = 0.4 × 0.5 = 0.2.",
        visualization: .probability
    ),
    Question(
        subject: .discreteMaths,
        text: "What is the probability of getting at least one head in 3 coin flips?",
        hint: "Use complement: P(at least 1 head) = 1 - P(all tails)",
        options: ["3/4", "7/8", "1/2", "5/8"],
        correctIndex: 1,
        explanation: "P(all tails) = (1/2)³ = 1/8. So P(at least 1 head) = 1 - 1/8 = 7/8.",
        visualization: .probability
    )
]

// MARK: - Expectation Questions

let expectationQuestions = [
    Question(
        subject: .discreteMaths,
        text: "A fair six-sided die is rolled. What is the expected value?",
        hint: "E[X] = Σ x·P(x) = (1+2+3+4+5+6)/6",
        options: ["3", "3.5", "4", "4.5"],
        correctIndex: 1,
        explanation: "E[X] = (1+2+3+4+5+6)/6 = 21/6 = 3.5.",
        visualization: .expectation
    ),
    Question(
        subject: .discreteMaths,
        text: "You win $10 with probability 0.3 and $0 with probability 0.7. What's your expected winnings?",
        hint: "E[X] = 10×0.3 + 0×0.7",
        options: ["$3", "$5", "$7", "$10"],
        correctIndex: 0,
        explanation: "E[X] = 10×0.3 + 0×0.7 = 3 + 0 = $3.",
        visualization: .expectation
    ),
    Question(
        subject: .discreteMaths,
        text: "A random variable X has P(X=1)=0.5, P(X=2)=0.3, P(X=3)=0.2. Find E[X].",
        hint: "E[X] = 1×0.5 + 2×0.3 + 3×0.2",
        options: ["1.5", "1.7", "2.0", "2.2"],
        correctIndex: 1,
        explanation: "E[X] = 1×0.5 + 2×0.3 + 3×0.2 = 0.5 + 0.6 + 0.6 = 1.7.",
        visualization: .expectation
    ),
    Question(
        subject: .discreteMaths,
        text: "If E[X] = 5 and E[Y] = 3, what is E[X + Y]?",
        hint: "Expectation is linear: E[X + Y] = E[X] + E[Y]",
        options: ["5", "8", "15", "Cannot determine"],
        correctIndex: 1,
        explanation: "By linearity of expectation: E[X + Y] = E[X] + E[Y] = 5 + 3 = 8.",
        visualization: .expectation
    )
]
