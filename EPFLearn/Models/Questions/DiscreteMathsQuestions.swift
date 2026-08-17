
import Foundation


let combinatoricsQuestions = [
    
    Question(
        subject: .discreteMaths,
        text: "How many ways can you arrange 5 different books on a shelf?",
        hint: "Every book is used and order matters. How many are still free for the second slot once the first is filled?",
        options: ["20", "60", "120", "240"],
        correctIndex: 2,
        explanation: "Each slot removes one book from the pool: 5 × 4 × 3 × 2 × 1 = 5! = 120.",
        visualization: .combinatorics
    ),
    Question(
        subject: .discreteMaths,
        text: "In how many ways can you choose 3 people from a group of 7?",
        hint: "Switch the mode picker between 'Permutations' and 'Combinations' with n = 7, k = 3 and compare the two counts.",
        options: ["21", "35", "42", "210"],
        correctIndex: 1,
        explanation: "C(7,3) = (7 × 6 × 5) / 3! = 210 / 6 = 35. Dividing by 3! removes the orderings of the same trio.",
        visualization: .combinatorics
    ),
    Question(
        subject: .discreteMaths,
        text: "How many 3-letter codes can be built from the letters {A, B, C, D} if a letter may be reused?",
        hint: "Select 'Repetition' in the mode picker with n = 4, k = 3 and watch how many options each slot keeps.",
        options: ["12", "24", "64", "81"],
        correctIndex: 2,
        explanation: "Every slot keeps all 4 letters available, so 4 × 4 × 4 = 4³ = 64. Without repetition the pool would shrink each time and give P(4,3) = 4 × 3 × 2 = 24.",
        visualization: .combinatorics
    ),
    Question(
        subject: .discreteMaths,
        text: "A club of 8 members elects a president, a treasurer and a secretary (3 different people). How many outcomes are there?",
        hint: "Three ordered slots, and the pool shrinks by one each time. Build the product yourself, then check it under 'Permutations'.",
        options: ["24", "56", "336", "512"],
        correctIndex: 2,
        explanation: "The roles are different, so order matters: 8 × 7 × 6 = 336. A 3-member committee with no roles would be C(8,3) = 336 / 3! = 56, since each committee shows up once per ordering.",
        visualization: .combinatorics
    ),
]

// MARK: - Permutations  →  CombinatoricsView

let permutationsQuestions = [
    
    Question(
        subject: .discreteMaths,
        text: "From 5 runners, how many different gold-silver podiums are possible?",
        hint: "Select 'Permutations' with n = 5, k = 2: the sample list shows both orders of the same pair as separate outcomes.",
        options: ["10", "20", "25", "120"],
        correctIndex: 1,
        explanation: "Order matters, so this is P(5,2) = 5 × 4 = 20.",
        visualization: .permutations
    ),
    Question(
        subject: .discreteMaths,
        text: "In how many ways can 5 people be seated around a round table?",
        hint: "Select 'Permutations': the view counts arrangements in a row. Fix one person first, then use it on the 4 that remain.",
        options: ["24", "60", "120", "5"],
        correctIndex: 0,
        explanation: "Fix one person to kill the rotations: the other 4 can be arranged in (5−1)! = 4! = 24 ways.",
        visualization: .permutations
    ),
    Question(
        subject: .discreteMaths,
        text: "How many distinguishable ways can you line up 3 identical red balls and 2 identical blue balls?",
        hint: "The balls of one colour are identical, so swapping two reds gives back the same line: order within a colour must not be counted, which rules out a permutation. Ask instead which slots the reds occupy.",
        options: ["6", "10", "12", "20"],
        correctIndex: 1,
        explanation: "5! / (3!·2!) = 10, which is also C(5,3): pick the 3 positions taken by the red balls.",
        visualization: .permutations
    ),
    Question(
        subject: .discreteMaths,
        text: "How many 3-letter codes with no repeated letter can be built from A, B, C, D?",
        hint: "Work out how many letters each of the three slots still has available, then multiply.",
        options: ["12", "24", "64", "4"],
        correctIndex: 1,
        explanation: "P(4,3) = 4 × 3 × 2 = 24.",
        visualization: .permutations
    ),
    Question(
        subject: .discreteMaths,
        text: "How many 3-letter codes can be built from A, B, C, D if a letter may now be reused?",
        hint: "Compare 'Permutations' with 'Repetition' at n = 4, k = 3 and see which count grows.",
        options: ["12", "24", "64", "81"],
        correctIndex: 2,
        explanation: "Each of the 3 slots independently has all 4 letters available, so 4 × 4 × 4 = 4³ = 64. Without repetition the pool shrinks by one at each step and you get only 4 × 3 × 2 = 24: allowing repetition replaces the falling product P(n,k) by the plain power nᵏ.",
        visualization: .permutations
    )
]

// MARK: - Binomial coefficients  →  BinomialCoefficientsView

let binomialQuestions = [
    Question(
        subject: .discreteMaths,
        text: "You know C(9,3) = 84 and C(9,4) = 126. What is C(10,6)?",
        hint: "C(10,6) is not directly above either of the two you were given. Find the entry in row 10 that Pascal's rule builds from them, then ask what else in row 10 has to equal it.",
        options: ["210", "252", "126", "84"],
        correctIndex: 0,
        explanation: "Pascal's rule gives C(10,4) = C(9,3) + C(9,4) = 84 + 126 = 210, and symmetry gives C(10,6) = C(10,10−6) = C(10,4) = 210. Reading row 10 from the wrong end lands on C(10,5) = 252, which is the middle entry and larger than every other in the row.",
        visualization: .binomialCoefficients
    ),
    Question(
        subject: .discreteMaths,
        text: "According to Pascal's identity, C(n,k) + C(n,k+1) equals:",
        hint: "Tap any entry in the triangle: the view highlights the two above it that add up to it. Which row does the child sit in?",
        options: ["C(n+1,k)", "C(n,k+2)", "C(n+1,k+1)", "C(n+2,k)"],
        correctIndex: 2,
        explanation: "C(n,k) + C(n,k+1) = C(n+1,k+1): the two parents add up to the child below them.",
        visualization: .binomialCoefficients
    ),
    Question(
        subject: .discreteMaths,
        text: "C(n,k) counts the subsets of an n-element set that have exactly k elements. How many subsets does {1,…,5} have in total?",
        hint: "Set n = 5 and read the whole row: each of the 5 elements is either in the subset or out of it, independently of the others.",
        options: ["32", "25", "10", "120"],
        correctIndex: 0,
        explanation: "Each element is in or out, so there are 2 × 2 × 2 × 2 × 2 = 32 subsets. Reading row 5 of the triangle and adding it up gives the same 32.",
        visualization: .binomialCoefficients
    ),
]

// MARK: - Pigeonhole principle  →  PigeonholePrincipleView

let pigeonholeQuestions = [
    Question(
        subject: .discreteMaths,
        text: "Your friend holds 10 pairs of socks (20 socks). How many must you pull out to guarantee a matching pair?",
        hint: "Decide first what plays the part of the items and what plays the part of the holes, then set them in the view and look at the worst possible run of draws.",
        options: ["2", "10", "11", "20"],
        correctIndex: 2,
        explanation: "Worst case you draw one sock of each of the 10 colours. The 11th sock must repeat a colour.",
        visualization: .pigeonholePrinciple
    ),
    Question(
        subject: .discreteMaths,
        text: "In a group of 25 people, the pigeonhole principle says at least 3 share a birth month. What kind of statement is that?",
        hint: "Decide which of the two counts are the items and which are the holes, set them in the view, then read the card that compares the room available with the number of items.",
        options: [
            "A probability: it is very likely, but it could fail for an unlucky group",
            "A certainty: no way of assigning 25 people to 12 months can avoid it",
            "It only holds if birthdays are spread uniformly over the year",
            "It only holds on average, over many different groups of 25"
        ],
        correctIndex: 1,
        explanation: "If every month held at most 2 people the group would cap at 12 × 2 = 24, so 25 force some month to 3. Nothing is assumed about the distribution: this is a proof, not a probability.",
        visualization: .pigeonholePrinciple
    ),
    Question(
        subject: .discreteMaths,
        text: "How many people must be in a room to be certain that two of them were born in the same month?",
        hint: "Decide which are the items and which are the holes, then set the holes in the view and add items one at a time until a repeat is forced.",
        options: ["12", "13", "24", "25"],
        correctIndex: 1,
        explanation: "12 people could land on 12 different months, one each. The 13th has to repeat a month already taken, so 13 is the first count that makes it certain.",
        visualization: .pigeonholePrinciple
    ),
]


// MARK: - Set operations  →  VennDiagramView

let setOperationsQuestions = [
    
    Question(
        subject: .discreteMaths,
        text: "By De Morgan's law, (A ∪ B)ᶜ equals:",
        hint: "Shade (A ∪ B)ᶜ in the region picker, then try each candidate: only one of them paints the same area.",
        options: ["Aᶜ ∪ Bᶜ", "Aᶜ ∩ Bᶜ", "A ∩ B", "(A ∩ B)ᶜ"],
        correctIndex: 1,
        explanation: "Not in (A or B) means not in A and not in B: (A ∪ B)ᶜ = Aᶜ ∩ Bᶜ.",
        visualization: .setOperations
    ),
    Question(
        subject: .discreteMaths,
        text: "The set A \\ B can be rewritten as:",
        hint: "Shade A \\ B in the region picker, then shade each candidate in turn: one of them paints exactly the same area.",
        options: ["A ∩ Bᶜ", "Aᶜ ∩ B", "A ∪ Bᶜ", "(A ∩ B)ᶜ"],
        correctIndex: 0,
        explanation: "A \\ B = A ∩ Bᶜ: keep what is in A while staying outside B.",
        visualization: .setOperations
    ),
    Question(
        subject: .discreteMaths,
        text: "If A ⊆ B, what is A ∩ B?",
        hint: "Drag circle A fully inside B and watch what the intersection region becomes.",
        options: ["A", "B", "∅", "A ∪ B"],
        correctIndex: 0,
        explanation: "When A sits inside B, the overlap is all of A: A ∩ B = A (and A ∪ B = B).",
        visualization: .setOperations
    ),
    Question(
        subject: .discreteMaths,
        text: "Which region does Aᶜ ∩ B describe?",
        hint: "Shade Aᶜ ∩ B in the region picker, then compare it with B \\ A and with the other candidates.",
        options: ["B \\ A", "A \\ B", "A ∩ B", "(A ∪ B)ᶜ"],
        correctIndex: 0,
        explanation: "Aᶜ ∩ B keeps exactly the part of B that A does not reach, which is B \\ A.",
        visualization: .setOperations
    ),
]

// MARK: - Recurrence relations  →  RecurrenceRelationsView

let recurrenceQuestions = [
    Question(
        subject: .discreteMaths,
        text: "A sequence is defined by aₙ = 2aₙ₋₁ + 1 with a₀ = 1. What is its closed form?",
        hint: "Select 'Geometric' in the picker and read the strip: 1, 3, 7, 15, 31, … Each term sits one below a power of 2, so find which power.",
        options: ["2ⁿ⁺¹ − 1", "2ⁿ − 1", "2ⁿ + 1", "2ⁿ + n"],
        correctIndex: 0,
        explanation: "The terms are 1, 3, 7, 15, 31, 63: one less than 2, 4, 8, 16, 32, 64. So aₙ = 2ⁿ⁺¹ − 1. The algebra agrees: writing aₙ = A·2ⁿ + B gives B = 2B + 1, so B = −1, and a₀ = A − 1 = 1 forces A = 2.",
        visualization: .recurrenceRelations
    ),
    Question(
        subject: .discreteMaths,
        text: "For which value of c does the sequence aₙ = 2aₙ₋₁ + c with a₀ = 1 stay stuck at 1 forever?",
        hint: "Select 'Geometric' in the picker: it has c = 1 and runs away from 1. A sequence stuck at 1 has aₙ = aₙ₋₁ = 1: put that into the recurrence and solve for c.",
        options: ["c = −1", "c = 0", "c = 1", "no value of c can do that"],
        correctIndex: 0,
        explanation: "A constant sequence has aₙ = aₙ₋₁ = a, so a = 2a + c, giving a = −c. With a = 1 that means c = −1. This value is the fixed point of the recurrence: start anywhere else with c = −1 and the sequence runs away from 1 rather than towards it, because r = 2 > 1.",
        visualization: .recurrenceRelations
    ),
    Question(
        subject: .discreteMaths,
        text: "The Fibonacci sequence is defined by F₀ = 0, F₁ = 1 and Fₙ = Fₙ₋₁ + Fₙ₋₂ for n ≥ 2. What is F₈?",
        hint: "Select 'Fibonacci' in the picker: the strip lists F₀ up to F₇. One more step gives F₈.",
        options: ["13", "21", "34", "55"],
        correctIndex: 1,
        explanation: "0, 1, 1, 2, 3, 5, 8, 13, 21, so F₈ = 21. Two base cases are needed, since each term looks two steps back.",
        visualization: .recurrenceRelations
    ),
    Question(
        subject: .discreteMaths,
        text: "A sequence is defined by aₙ = 2aₙ₋₁ + 1 with a₀ = 1, and a₇ = 255. What is a₈?",
        hint: "Select 'Geometric' in the picker: the chart stops at a₇. Apply the rule one more time, or use the closed form the strip suggests.",
        options: ["511", "512", "256", "383"],
        correctIndex: 0,
        explanation: "a₈ = 2·255 + 1 = 511, which is 2⁹ − 1. Every term of this sequence is one below a power of 2, so doubling and adding one keeps that pattern going.",
        visualization: .recurrenceRelations
    )
]


let closedFormQuestions = [
    Question(
        subject: .discreteMaths,
        text: "A sequence is defined by aₙ = aₙ₋₁ + 3 with a₀ = 1. What is its closed form?",
        hint: "Select 'Arithmetic' in the picker and read the strip: 1, 4, 7, 10, 13, … The same amount is added at every step, so n steps add n times that amount to a₀.",
        options: ["3n + 1", "3n", "n + 3", "3ⁿ + 1"],
        correctIndex: 0,
        explanation: "Each step adds 3, so after n steps aₙ = a₀ + 3n = 3n + 1. Check against the strip: a₀ = 1, a₃ = 10, a₇ = 22. A constant step gives a straight line, which is why the chart is straight here and curved for the geometric example.",
        visualization: .generatingFunctions
    ),
    Question(
        subject: .discreteMaths,
        text: "A sequence follows aₙ = r·aₙ₋₁ + c with a₀ = 1, and its terms are 1, 4, 7, 10, 13, … What are r and c?",
        hint: "Select 'Arithmetic' in the picker: the strip shows exactly these terms. Every step adds the same amount, so ask what r has to be for the previous term to be passed on unchanged.",
        options: [
            "r = 1 and c = 3",
            "r = 3 and c = 1",
            "r = 4 and c = 0",
            "r = 1 and c = 4"
        ],
        correctIndex: 0,
        explanation: "Each term is the previous one plus 3, so the previous term is carried over untouched (r = 1) and 3 is added (c = 3). Check it: 1 → 4 → 7 → 10. r = 3, c = 1 would give 1, 4, 13, 40 instead, growing exponentially rather than in equal steps: r = 1 is exactly what makes the chart a straight line.",
        visualization: .generatingFunctions
    ),
    Question(
        subject: .discreteMaths,
        text: "Fibonacci is given two base cases, F₀ = 0 and F₁ = 1, while aₙ = 2aₙ₋₁ + 1 needs only a₀. Why the difference?",
        hint: "Compare the unfolding panel under 'Fibonacci' with the one under 'Geometric': look at how far back each rule reaches to build one term.",
        options: [
            "Fibonacci reaches two steps back, so one base case leaves F₁ undefined",
            "Because Fibonacci grows faster and needs more information",
            "Because F₀ = 0 and a sequence cannot start at zero",
            "It does not need two: F₁ = 1 can be derived from F₀ = 0"
        ],
        correctIndex: 0,
        explanation: "Fₙ = Fₙ₋₁ + Fₙ₋₂ needs the two previous terms, so it can only start once two terms are known. A rule reaching one step back only needs one starting value. In general a recurrence of depth k needs k base cases.",
        visualization: .generatingFunctions
    ),
    Question(
        subject: .discreteMaths,
        text: "A geometric sequence and an arithmetic one both start at 1. The arithmetic one adds 100 per step, the geometric one multiplies by 1.5. Which is ahead at n = 100?",
        hint: "Switch the picker between 'Arithmetic' and 'Geometric' and push the terms slider as far out as it goes.",
        options: [
            "The geometric one, by an astronomical margin",
            "The arithmetic one, since 100 per step is much more than ×1.5",
            "They stay roughly level",
            "It depends on the starting value"
        ],
        correctIndex: 0,
        explanation: "The arithmetic sequence reaches about 10 001, while the geometric one reaches 1.5¹⁰⁰ ≈ 4·10¹⁷. Any exponential with a base above 1 eventually overtakes every linear sequence, whatever the constant step is: the constant only decides how long 'eventually' takes.",
        visualization: .generatingFunctions
    )
]


let probabilityQuestions = [
    Question(
        subject: .discreteMaths,
        text: "With two fair dice, what is P(sum ≥ 10)?",
        hint: "Select '2 dice' in the experiment picker, then count the ordered pairs that reach 10 or more, out of the 36 equally likely ones.",
        options: ["1/6", "1/12", "1/9", "1/4"],
        correctIndex: 0,
        explanation: "The sums 10, 11 and 12 come from 3, 2 and 1 ordered pairs respectively, so P = (3 + 2 + 1)/36 = 6/36 = 1/6. Because the three events cannot happen together, their probabilities simply add.",
        visualization: .probability
    ),
    Question(
        subject: .discreteMaths,
        text: "The distribution of the sum of two dice is a triangle peaking at 7, not a flat line. What causes the peak?",
        hint: "Select '2 dice' in the experiment picker, then list the ordered pairs that make 7 and the ones that make 2, and compare how many there are.",
        options: [
            "7 is a lucky number, there is no cause",
            "7 comes from six ordered pairs, 12 from only one",
            "The dice become dependent once you add them",
            "Every sum is equally likely, the chart misleads"
        ],
        correctIndex: 1,
        explanation: "The 36 ordered pairs are uniform, the 11 sums are not: 7 comes from 6 pairs, 12 from only (6,6). That is why the chart is a triangle.",
        visualization: .probability
    ),
    Question(
        subject: .discreteMaths,
        text: "What is the probability of rolling an even number on a single fair die?",
        hint: "Select 'Die' in the experiment picker and tap the faces that count as the event.",
        options: ["1/6", "1/3", "1/2", "2/3"],
        correctIndex: 2,
        explanation: "The faces 2, 4 and 6 are even, each with probability 1/6, and they are mutually exclusive: P = 3 × 1/6 = 1/2. An event is a set of outcomes, and its probability is the sum of the probabilities of the outcomes it contains.",
        visualization: .probability
    ),
    Question(
        subject: .discreteMaths,
        text: "For two dice, P(sum = 2) = 1/36 while P(sum = 3) = 2/36. Why is 3 exactly twice as likely as 2?",
        hint: "Select '2 dice' in the experiment picker, then write out the ordered pairs giving 2 and the ones giving 3: how many ways is each sum built?",
        options: [
            "3 is bigger than 2",
            "3 comes from (1,2) and (2,1), while 2 comes only from (1,1)",
            "The two dice influence each other",
            "A rounding artefact: they are equally likely"
        ],
        correctIndex: 1,
        explanation: "The dice are distinguishable, so (1,2) and (2,1) are two different outcomes of the 36, while (1,1) is a single one that swapping leaves unchanged. Forgetting that a sum can be reached in several ordered ways is the most common mistake in dice problems.",
        visualization: .probability
    ),
]

// MARK: - Expectation  →  ExpectationView

let expectationQuestions = [
    Question(
        subject: .discreteMaths,
        text: "A fair six-sided die has E[X] = 3.5, yet no roll can ever show 3.5. What does the expected value actually describe?",
        hint: "Set the law to 'Free', then drag the bars so one side is much taller than the other. The green E[X] marker slides away from the middle of the values and settles where the law balances.",
        options: [
            "The outcome you are most likely to roll",
            "The average of the outcomes, weighted by their probabilities",
            "An error: E[X] must be a possible value",
            "The midpoint between the smallest and largest outcome"
        ],
        correctIndex: 1,
        explanation: "E[X] = Σ x · P(X = x) is the balance point of the distribution, so it need not be a value X can take. The midpoint matches here only because a fair die is symmetric: skew the law and the two part company.",
        visualization: .expectation
    ),
    Question(
        subject: .discreteMaths,
        text: "You win 10 CHF with probability 0.3 and nothing otherwise. What are your expected winnings?",
        hint: "The view carries values 0 and 1, so build that case: 2 outcomes, values 0…1, law 'Free', bars dragged to 0.7 and 0.3. The E[X] it shows is for a prize of 1, and multiplying the prize by 10 multiplies E by 10.",
        options: ["3 CHF", "5 CHF", "7 CHF", "10 CHF"],
        correctIndex: 0,
        explanation: "E[X] = 10 × 0.3 + 0 × 0.7 = 3 CHF.",
        visualization: .expectation
    ),
    Question(
        subject: .discreteMaths,
        text: "X has P(X=1) = 0.5, P(X=2) = 0.3 and P(X=3) = 0.2. What is E[X]?",
        hint: "Set 3 outcomes and select 'Free' as the law: multiply each value by its own probability and add the three terms, and the view writes that same sum out.",
        options: ["1.5", "1.7", "2.0", "2.2"],
        correctIndex: 1,
        explanation: "0.5 + 0.6 + 0.6 = 1.7. The mass leans towards 1, so the balance point sits below the middle.",
        visualization: .expectation
    ),
    Question(
        subject: .discreteMaths,
        text: "A fair coin pays 1 point for heads and 0 for tails. What is the expected total over 10 flips?",
        hint: "Set 2 outcomes with values 0…1 and select 'Uniform' as the law: that is one flip. Then multiply by the number of flips.",
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
        text: "Which formula is NOT equivalent to p → q?",
        hint: "Select each candidate in turn from the formula picker and compare its truth column with the one for p → q.",
        options: ["¬p ∨ q", "¬q → ¬p", "q → p", "¬(p ∧ ¬q)"],
        correctIndex: 2,
        explanation: "¬p ∨ q, the contrapositive ¬q → ¬p and ¬(p ∧ ¬q) match p → q row by row. The converse q → p does not: with p false and q true, p → q is true while q → p is false.",
        visualization: .propositionalLogic
    ),
    Question(
        subject: .discreteMaths,
        text: "How many rows does the truth table of a formula with 3 variables have?",
        hint: "Each variable is true or false independently of the others, so each one you add doubles the cases.",
        options: ["3", "6", "8", "9"],
        correctIndex: 2,
        explanation: "2³ = 8 rows, one per assignment of true/false to p, q and r.",
        visualization: .propositionalLogic
    ),
    Question(
        subject: .discreteMaths,
        text: "The formula p ∨ ¬p is:",
        hint: "Take p true, then p false, and evaluate the formula yourself in each case.",
        options: ["a contradiction", "a tautology", "a contingency", "not well-formed"],
        correctIndex: 1,
        explanation: "It is true in every row, so it is a tautology.",
        visualization: .propositionalLogic
    ),
    Question(
        subject: .discreteMaths,
        text: "A formula is in CNF when it is a conjunction of clauses, each clause a disjunction of literals. Which formula is in CNF?",
        hint: "Select 'CNF' in the form picker and compare the shape it highlights with each candidate formula.",
        options: [
            "(p ∨ ¬q) ∧ (¬p ∨ q ∨ r)",
            "(p ∧ ¬q) ∨ (¬p ∧ r)",
            "¬(p ∨ q) ∧ r",
            "p ∧ (q ∨ (r ∧ p))"
        ],
        correctIndex: 0,
        explanation: "Only the first has the shape (…∨…) ∧ (…∨…) with every ¬ on a variable. The second is a disjunction of conjunctions (DNF), the third negates a whole clause, and the fourth hides an ∧ inside an ∨.",
        visualization: .propositionalLogic
    ),
    
]


