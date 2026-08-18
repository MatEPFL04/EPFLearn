//
//  LinearAlgebraQuestions.swift
//  EPFLearn
//
//  Created on 21.07.2026.
//

import Foundation

// MARK: - Matrix Operations Questions

let matrixShapeQuestions = [
    Question(
        subject: .linearAlgebra,
        text: "What is the resulting dimension when multiplying a 3×2 matrix A by a 2×3 matrix B?",
        hint: "The inner dimensions have to match, and the outer ones survive. Drag each matrix by its corner to check your answer.",
        options: [
            "3×3 matrix",
            "2×2 matrix",
            "3×2 matrix",
            "The multiplication is undefined"
        ],
        correctIndex: 0,
        explanation: "Multiplying an m×n matrix by an n×p matrix gives an m×p matrix: the inner dimensions cancel and the outer ones survive. Here (3×2) × (2×3) yields a 3×3 matrix. Note the reverse order, (2×3) × (3×2), is also defined but comes out 2×2, so the two products are not even the same size.",
        visualization: .matrixOperations
    ),
    Question(
        subject: .linearAlgebra,
        text: "For any non-square matrix A of dimension m×n (where m ≠ n), which statement about its transpose Aᵀ is correct?",
        hint: "Pick the transpose operation and drag A by its corner to make it non-square: watch which products the view still allows.",
        options: [
            "Only A·Aᵀ is well-defined",
            "Only Aᵀ·A is well-defined",
            "Both Aᵀ·A and A·Aᵀ are well-defined square matrices",
            "Neither product is well-defined"
        ],
        correctIndex: 2,
        explanation: "Since A is m×n and Aᵀ is n×m, the product Aᵀ·A is (n×m)×(m×n) = n×n, and A·Aᵀ is (m×n)×(n×m) = m×m. Both are perfectly valid and result in square matrices.",
        visualization: .matrixOperations
    ),
    Question(
        subject: .linearAlgebra,
        text: "Let A be a 3×2 matrix and B be a 3×2 matrix. What is the shape of ((A·Bᵀ)ᵀ)·A?",
        hint: "Use (X·Y)ᵀ = Yᵀ·Xᵀ to remove the outer transpose first, then count the dimensions left to right.",
        options: [
            "3×2 matrix",
            "2×3 matrix",
            "The operation is mathematically undefined",
            "3×3 matrix"
        ],
        correctIndex: 0,
        explanation: "Simplify first: (A·Bᵀ)ᵀ = (Bᵀ)ᵀ·Aᵀ = B·Aᵀ, so the whole expression is B·Aᵀ·A. Now count left to right: B is 3×2, Aᵀ is 2×3, and A is 3×2. So (3×2)×(2×3) gives 3×3, and (3×3)×(3×2) gives 3×2.",
        visualization: .matrixOperations
    ),
    Question(
        subject: .linearAlgebra,
        text: "Given matrices A (3×3) and B (3×2), what is the shape of the product A·B·Bᵀ·A?",
        hint: "Build the chain in the view one multiplication at a time and carry the result shape into the next step.",
        options: [
            "3×2 matrix",
            "3×3 matrix",
            "2×2 matrix",
            "Undefined: the dimensions do not match"
        ],
        correctIndex: 1,
        explanation: "Step by step: A·B is (3×3)×(3×2) = 3×2. Then A·B·Bᵀ is (3×2)×(2×3) = 3×3. Finally A·B·Bᵀ·A is (3×3)×(3×3) = 3×3.",
        visualization: .matrixOperations
    )
]


let gaussQuestions: [Question] = [
    
    Question(
            subject: .linearAlgebra,
            text: "A system of three equations turns out to describe only two distinct planes, and those two planes are not parallel. What is its solution set?",
            hint: "Pick 'A whole line' and step to the end: watch what the three planes have in common once one row empties.",
            options: [
                "A single point",
                "A line",
                "A plane",
                "The empty set"
            ],
            correctIndex: 1,
            explanation: "Dividing the second equation by 2 gives back the first one exactly, constant included, so the two describe one and the same plane and only two distinct planes remain. Two non-parallel planes always cut each other along a line, which is the solution set here.",
            visualization: .gaussianElimination
        ),
    
    Question(
        subject: .linearAlgebra,
        text: "During an elimination, one row becomes zero everywhere on the left of the bar while its constant on the right stays non-zero. What does the system look like?",
        hint: "Pick 'No solution' and advance one step: read the row that empties on the left but not on the right.",
        options: [
            "It has a unique solution, that constant",
            "It has no solution at all",
            "It has infinitely many solutions",
            "The elimination was performed incorrectly"
        ],
        correctIndex: 1,
        explanation: "That row states 0·x + 0·y + 0·z = 1, which no triple can satisfy, so the system is inconsistent and the solution set is empty. Geometrically the three planes have no common point, they can still meet pairwise, which is why the contradiction is invisible until the elimination brings it out.",
        visualization: .gaussianElimination
    ),
    Question(
            subject: .linearAlgebra,
            text: "A system contains the two equations x + y + z = 2 and 2x + 2y + 2z = 5. What is their geometric relationship?",
            hint: "Pick 'No solution' and read L₁ and L₂ at step 0, before any operation runs.",
            options: [
                "They describe the same plane",
                "They describe two parallel planes that never meet",
                "They meet along a line",
                "They meet at a single point"
            ],
            correctIndex: 1,
            explanation: "Halving the second equation gives x + y + z = 2.5, the same normal direction as the first but a different offset: two parallel planes, distinct, with no common point. Any third plane cutting through them cannot fix that, which is why the system has no solution no matter what the last equation says.",
            visualization: .gaussianElimination
        ),
    Question(
        subject: .linearAlgebra,
        text: "Two systems both have a second equation whose left-hand side is exactly twice the first equation's. One has no solution, the other has infinitely many. What settles which is which?",
        hint: "Compare 'No solution' and 'A whole line' at step 0: only the constant column differs. Then step both once.",
        options: [
            "The number of unknowns involved",
            "Whether the constant is also doubled, or not",
            "The order in which the rows are written",
            "The sign of the coefficients in the third equation"
        ],
        correctIndex: 1,
        explanation: "When the constant follows the same doubling, the second equation says nothing new and dissolves into 0 = 0, leaving fewer equations than unknowns. When it does not, the same elimination produces 0 = a non-zero number, a flat contradiction. The left blocks are indistinguishable; the augmented column is what carries the verdict, which is exactly why the bar is drawn.",
        visualization: .gaussianElimination
    ),
]


let determinantQuestions = [
    Question(
        subject: .linearAlgebra,
        text: "What is det([[1, 0], [c, 1]])? How does varying c affect the area of the parallelogram spanned by the column vectors?",
        hint: "Drag one tip sideways so the parallelogram leans over, keeping the other vector put, and watch det.",
        options: [
            "det = 1",
            "det = 1 + c",
            "det = c",
            "det = 0 for every c"
        ],
        correctIndex: 0,
        explanation: "det = 1 × 1 − 0 × c = 1. Geometrically, varying c creates a shear (transvection). The vertex slides parallel to the base, keeping both the base (length 1) and the height (1) constant. Therefore, the signed area remains exactly 1.",
        visualization: .determinant
    ),
    Question(
        subject: .linearAlgebra,
        text: "If you scale one column vector v⃗ by a factor of 3, what happens to the determinant?",
        hint: "Set the length of v⃗₁ to 1 with the slider, read det, then set it to 3 and read det again.",
        options: [
            "It triples",
            "It does not change",
            "It is multiplied by 9",
            "It changes sign but keeps its size"
        ],
        correctIndex: 0,
        explanation: "The determinant is linear in each column. Visually, multiplying v⃗ by 3 stretches the parallelogram in that direction by a factor of 3, equivalent to stacking 3 copies of the original parallelogram.",
        visualization: .determinant
    ),
    Question(
        subject: .linearAlgebra,
        text: "The two column vectors of a 2×2 matrix A cross over each other, so the pair goes from counter-clockwise to clockwise. What happens to det(A)?",
        hint: "Drag one vector past the other in the view and watch the sign of the determinant as they cross.",
        options: [
            "It flips sign",
            "It stays positive: an area cannot be negative",
            "It drops to zero and stays there",
            "It becomes undefined"
        ],
        correctIndex: 0,
        explanation: "The determinant measures signed area. Reversing the orientation (switching from counter-clockwise to clockwise order) flips the sign of det(A) from positive to negative, even though the absolute area stays identical.",
        visualization: .determinant
    )
]



let vectorSpaceQuestions = [
    
    Question(
            subject: .linearAlgebra,
            text: "You are given three vectors {v⃗₁, v⃗₂, v⃗₃} in ℝ². What can you immediately conclude?",
            hint: "Select ℝ²: the view hands you exactly two arrows, and that is not an accident. Set them so det ≠ 0, and they already reach every point of the plane between them. Where would a third one have to point to add anything?",
            options: [
                "They must be dependent, since dim(ℝ²) = 2",
                "They form a basis: more vectors cover more",
                "They span a 3D subspace",
                "They must all be zero vectors"
            ],
            correctIndex: 0,
            explanation: "In ℝⁿ, any set containing more than n vectors is always linearly dependent. Since dim(ℝ²) = 2, any group of 3 vectors in the plane must contain redundancy.",
            visualization: .vectorSpaces
        ),
    
    Question(
           subject: .linearAlgebra,
           text: "You apply a reflection across a line L to vector v⃗, producing v⃗'. Under what geometric condition does {v⃗, v⃗'} fail to form a basis for ℝ²?",
           hint: "A reflection keeps the length of v⃗, so v⃗' is v⃗ turned by some angle. Lay the two arrows exactly on top of one another, then make one the exact opposite of the other: det collapses to 0 both times. Which positions of v⃗ relative to L produce those two cases?",
           options: [
               "When v⃗ ∈ L or v⃗ ⊥ L",
               "Only when v⃗ ⊥ L",
               "When v⃗ makes a 45° angle with L",
               "Reflections always preserve independence"
           ],
           correctIndex: 0,
           explanation: "If v⃗ ∈ L (on the axis), then v⃗' = v⃗. If v⃗ ⊥ L (perpendicular), then v⃗' = −v⃗. In both cases, v⃗ and v⃗' are collinear, so span{v⃗, v⃗'} is one-dimensional and cannot form a basis for ℝ².",
           visualization: .determinant
       ),
    
    Question(
            subject: .linearAlgebra,
            text: "Two vectors v⃗₁ and v⃗₂ in ℝ² span a parallelogram. You rotate v⃗₂ about the origin, keeping its length, until it points the same way as v⃗₁. What happens to det?",
            hint: "Turn v⃗₂ towards v⃗₁ and watch det shrink. What is left of the parallelogram when they line up?",
            options: [
                "It reaches 0: the parallelogram has been squashed flat",
                "It reaches its largest value, since the vectors agree",
                "It stays the same: only the angle changed, not the lengths",
                "It becomes negative but keeps its size"
            ],
            correctIndex: 0,
            explanation: "det is the signed area of the parallelogram they span. Two vectors pointing the same way span no area at all, so det = 0 and the pair is no longer a basis. The lengths make no difference to that.",
            visualization: .determinant
        ),
    
    Question(
        subject: .linearAlgebra,
        text: "In ℝ³, you have a plane P = span{v⃗₁, v⃗₂}. You add w⃗ forming angle ε > 0 with P. Do {v⃗₁, v⃗₂, w⃗} form a basis for ℝ³?",
        hint: "Independence is not a matter of degree: either w⃗ lies in the plane, or it does not. Lift it slightly in the view.",
        options: [
            "No, because ε is too small",
            "Yes: ε ≠ 0 puts w⃗ outside P, so the three are independent",
            "Only if w⃗ ⊥ P",
            "No, they only span a 2D subspace"
        ],
        correctIndex: 1,
        explanation: "As long as ε > 0, w⃗ does not lie in span{v⃗₁, v⃗₂}. The parallelepiped formed has non-zero volume (however tiny). The vectors are linearly independent and form a basis for ℝ³.",
        visualization: .vectorSpaces
    ),

]



let matrix3DQuestions = [
    Question(
            subject: .linearAlgebra,
            text: "A rotation of ℝ³ about the z-axis leaves a non-zero vector v⃗ fixed, so that A·v⃗ = v⃗. Where does v⃗ lie?",
            hint: "Pick 'Rotation about z' and drag v⃗ around: look for the direction whose golden image arrow never moves off it.",
            options: [
                "In the xy-plane, perpendicular to the axis",
                "Along the z-axis: v⃗ is an eigenvector with eigenvalue 1",
                "v⃗ must be the zero vector",
                "Anywhere: a rotation fixes every vector of ℝ³"
            ],
            correctIndex: 1,
            explanation: "A rotation moves everything except the axis it turns around, so the fixed vectors form exactly that line. In eigenvalue language, A·v⃗ = 1·v⃗ makes v⃗ an eigenvector with eigenvalue 1, and the axis of any 3D rotation is precisely its eigenspace for λ = 1. Vectors in the xy-plane are the ones that move the most.",
            visualization: .linearTransformations,
    ),
    Question(
            subject: .linearAlgebra,
            text: "A matrix A has dependent columns, its second column being twice the first. A non-zero vector v⃗ = (2, −1, 0) belongs to ?",
            hint: "Pick 'Dependent columns', set v⃗ to (2, −1, 0) and watch where the golden A·v⃗ arrow lands.",
            options: [
                "The image of A",
                "The kernel of A",
                "The set of eigenvectors with eigenvalue 1",
                "Nothing special: every vector maps to 0⃗ here"
            ],
            correctIndex: 1,
            explanation: "Writing A·v⃗ = 2·c⃗₁ − c⃗₂ and using c⃗₂ = 2·c⃗₁ makes the two terms cancel exactly. A non-zero vector sent to the origin is precisely what a non-trivial kernel means, and it is the reason A cannot be inverted: no map could tell v⃗ and 0⃗ apart afterwards. Try (1, −0.5, 0) too, the whole line collapses.",
            visualization: .linearTransformations
        ),
    
    Question(
        subject: .linearAlgebra,
        text: "What are the columns of the identity matrix I?",
        hint: "Each column of a matrix is where one basis vector lands. I leaves every vector where it is.",
        options: [
            "e⃗₁, e⃗₂, e⃗₃",
            "All zero",
            "All equal to (1, 1, 1)",
            "Whatever basis you happen to be using"
        ],
        correctIndex: 0,
        explanation: "A column says where a basis vector is sent, and I sends each one to itself, so its columns are e⃗₁, e⃗₂, e⃗₃. That is exactly why I·v⃗ = v⃗ for every v⃗.",
        visualization: .linearTransformations
    ),
    Question(
            subject: .linearAlgebra,
            text: "The map P(x, y, z) = (x, y, 0) sends both (1, 1, 1) and (1, 1, 0) to (1, 1, 0). What does that say about P?",
            hint: "Pick 'Projection onto xy', set v⃗ to (1, 1, 1) then (1, 1, 0), and compare the two golden arrows.",
            options: [
                "It is not injective, and not surjective onto ℝ³",
                "It is not injective, but surjective onto ℝ³",
                "It is injective, since the two inputs are different",
                "It is invertible"
            ],
            correctIndex: 0,
            explanation: "Two different inputs with one output means P is not injective, and their difference (0, 0, 1) sits in the kernel. The image is only the xy-plane, so P is not onto ℝ³ either.",
            visualization: .linearTransformations
        ),
    
  
]



let imagesQuestions = [
    Question(
        subject: .linearAlgebra,
        text: "A 3×3 matrix A satisfies A·v⃗ = v⃗ for every v⃗. What is A?",
        hint: "Pick 'Identity' in the examples: every point of the lattice stays exactly where it started. Read off where e⃗₁, e⃗₂ and e⃗₃ land: each one is a column of A.",
        options: [
            "The identity: its columns are e⃗₁, e⃗₂, e⃗₃",
            "Any matrix with det = 1",
            "Any symmetric matrix",
            "Any diagonal matrix"
        ],
        correctIndex: 0,
        explanation: "A column of a matrix is where a basis vector lands. Demanding A·e⃗ᵢ = e⃗ᵢ fixes all three columns at once, so A = I. det = 1 is far weaker: rotations have det = 1 too and move plenty of vectors.",
        visualization: .image
    ),

    Question(
        subject: .linearAlgebra,
        text: "A 3×3 matrix has columns c⃗₁ = (1,0,0), c⃗₂ = (0,1,0) and c⃗₃ = (1,1,0). What is im A?",
        hint: "Pick 'Plane · rank 2' in the examples. The image is spanned by the columns, so check whether the third one adds a direction the first two miss.",
        options: [
            "im A = ℝ³: three non-zero columns always span all of ℝ³",
            "im A is the xy-plane (dim 2): c⃗₃ is redundant, so the image flattens",
            "im A is a line (dim 1), since the columns are collinear",
            "im A = {0⃗}: dependent columns kill every vector"
        ],
        correctIndex: 1,
        explanation: "The columns are c⃗₁ = (1, 0, 0), c⃗₂ = (0, 1, 0), c⃗₃ = (1, 1, 0). Since c⃗₃ = c⃗₁ + c⃗₂, only two directions are independent: dim(im A) = 2. The yellow plane is span{c⃗₁, c⃗₂}. By Rank-Nullity, dim(ker A) = 3 − 2 = 1: one entire direction collapses to 0⃗.",
        visualization: .image
    ),
    Question(
        subject: .linearAlgebra,
        text: "For the zero matrix 0, what are dim(ker 0) and dim(im 0)?",
        hint: "Pick 'Zero map' in the examples: every point lands on the origin. What is left of the image?",
        options: [
            "dim(ker 0) = 3, dim(im 0) = 0",
            "dim(ker 0) = 0, dim(im 0) = 0",
            "dim(ker 0) = 3, dim(im 0) = 3",
            "The dimensions are independent; no relation holds"
        ],
        correctIndex: 0,
        explanation: "Rank-Nullity: dim(ker A) + dim(im A) = 3. For 0, every point maps to 0⃗, so ker 0 = ℝ³ and im 0 = {0⃗}. Thus 3 + 0 = 3. The identity sits at the opposite extreme (0 + 3).",
        visualization: .image
    ),
    Question(
        subject: .linearAlgebra,
        text: "For P(x, y, z) = (x, y, 0), what is dim(ker P) and which vector spans that kernel?",
        hint: "Pick 'Projection onto xy' in the examples and watch which direction collapses onto the origin.",
        options: [
            "dim(ker A) = 0: the kernel is {0⃗}",
            "dim(ker A) = 1, spanned by e⃗₃ = (0, 0, 1)",
            "dim(ker A) = 2, spanned by {e⃗₁, e⃗₂}",
            "dim(ker A) = 1, spanned by e⃗₁ = (1, 0, 0)"
        ],
        correctIndex: 1,
        explanation: "A(0, 0, z) = z·A·e⃗₃ = 0⃗ since A·e⃗₃ = 0⃗. The entire z-axis maps to the origin: ker A = span{e⃗₃}, so dim(ker A) = 1. By Rank-Nullity, dim(im A) = 2 (the xy-plane), and 2 + 1 = 3. Don't confuse them: xy-plane is the image, z-axis is the kernel.",
        visualization: .image
    ),
    Question(
        subject: .linearAlgebra,
        text: "A 3×3 matrix collapses points onto a single line. What are rank(T) and dim(ker T)?",
        hint: "Pick 'Line · rank 1' in the examples: the whole lattice lands on one line. That line is the image, so one dimension survives and rank-nullity accounts for the other two.",
        options: [
            "rank(T) = 2, dim(ker T) = 1",
            "rank(T) = 1, dim(ker T) = 2",
            "rank(T) = 1, dim(ker T) = 1",
            "T is still invertible because the image is not a point"
        ],
        correctIndex: 1,
        explanation: "The image is a line, so rank(T) = dim(im T) = 1. By Rank-Nullity, dim(ker T) = 3 − 1 = 2. A whole 2D plane of ℝ³ maps to 0⃗, and the remaining structure collapses into that line.",
        visualization: .image),
    Question(
        subject: .linearAlgebra,
        text: "A shear maps (x, y, z) to (x + z, y, z). Which points of ℝ³ stay exactly where they are?",
        hint: "Pick 'Shear' in the examples and rotate it: a point moves only if the amount added to x is non-zero.",
        options: [
            "Every point with z = 0, that is the whole xy-plane",
            "Only the origin",
            "Every point with x = 0, that is the yz-plane",
            "No point stays fixed"
        ],
        correctIndex: 0,
        explanation: "The map only shifts x, and it shifts it by z. So a point moves unless z = 0, which leaves the entire xy-plane fixed while the layers above and below slide sideways.",
        visualization: .image
    ),

]


