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
        text: "What is the resulting dimension when multiplying a 3×2 matrix A by a 2×4 matrix B?",
        hint: "Matrix multiplication AB is only defined if the number of columns in A equals the number of rows in B. The outer dimensions give the final size.",
        options: [
            "3×4 matrix",
            "2×2 matrix",
            "3×2 matrix",
            "The multiplication is undefined"
        ],
        correctIndex: 0,
        explanation: "Multiplying an m×n matrix by an n×p matrix results in an m×p matrix. Here, (3×2) × (2×4) yields a 3×4 matrix.",
        visualization: .matrixOperations
    ),
    Question(
        subject: .linearAlgebra,
        text: "For any non-square matrix A of dimension m×n (where m ≠ n), which statement about its transpose Aᵀ is correct?",
        hint: "Check the dimensions of A (m×n) and Aᵀ (n×m) to see which products are mathematically allowed.",
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
        text: "Let A be a 3×2 matrix and B be a 4×2 matrix. What is the resulting shape of the composite operation: ((A·Bᵀ)ᵀ)·A ?",
        hint: "Simplify the expression using the property (X·Y)ᵀ = Yᵀ·Xᵀ before analyzing the dimensions step by step.",
        options: [
            "3×2 matrix",
            "4×3 matrix",
            "The operation is mathematically undefined",
            "4×2 matrix"
        ],
        correctIndex: 3,
        explanation: "Let's simplify: ((A·Bᵀ)ᵀ) = (Bᵀ)ᵀ·Aᵀ = B·Aᵀ. Now the full expression becomes: B·Aᵀ·A. Checking dimensions: B is 4×2, Aᵀ is 2×3, and A is 3×2. The composition (4×2)×(2×3)×(3×2) is perfectly valid and results in a 4×2 matrix.",
        visualization: .matrixOperations
    ),
    Question(
        subject: .linearAlgebra,
        text: "Given matrices A (3×3) and B (3×2), what is the shape of the product A·B·Bᵀ·A?",
        hint: "Track dimensions step by step from left to right.",
        options: [
            "3×2 matrix",
            "3×3 matrix",
            "2×2 matrix",
            "The operation is undefined due to a dimension mismatch"
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
            hint: "Pick 'Infinitely many' and read L₁ and L₂ in the system block before touching the slider: divide the second by 2 in your head. T",
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
        hint: "Pick 'No solution' and advance a single step, then read L₂ and the verdict card underneath.",
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
            hint: "Pick 'No solution' and read L₁ and L₂ in the system block before touching the slider. Divide the second one by 2 in your head.",
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
        hint: "Compare 'No solution' and 'Infinitely many' at step 0: the left blocks are identical, only the constant column differs. Then advance one step in each.",
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
        hint: "Drag the vertex horizontally to change c. Does the base or the height of the parallelogram change?",
        options: [
            "det = 1",
            "det = 1 + c",
            "det = c",
            "det = 0 for all c, because the matrix becomes singular"
        ],
        correctIndex: 0,
        explanation: "det = 1 × 1 − 0 × c = 1. Geometrically, varying c creates a shear (transvection). The vertex slides parallel to the base, keeping both the base (length 1) and the height (1) constant. Therefore, the signed area remains exactly 1.",
        visualization: .determinant
    ),
    Question(
        subject: .linearAlgebra,
        text: "If you scale one column vector v⃗ by a factor of 3, what happens to the determinant?",
        hint: "Drag a vertex to triple the length of one column vector. What happens to the area?",
        options: [
            "The determinant triples, because scaling one vector by 3 scales the height or base by 3",
            "The determinant stays the same, because the other vector compensates",
            "The determinant increases by 3² = 9, because both dimensions are affected",
            "The determinant changes sign but not magnitude"
        ],
        correctIndex: 0,
        explanation: "The determinant is linear in each column. Visually, multiplying v⃗ by 3 stretches the parallelogram in that direction by a factor of 3, equivalent to stacking 3 copies of the original parallelogram.",
        visualization: .determinant
    ),
    Question(
        subject: .linearAlgebra,
        text: "What happens to det(A) if you drag the column vectors so they cross over, reversing their orientation?",
        hint: "Drag the vectors until v⃗₁ moves past v⃗₂. Watch the sign of the determinant.",
        options: [
            "det(A) flips sign, reflecting the orientation reversal",
            "det(A) remains positive, because area cannot be negative",
            "det(A) drops to zero at the crossing",
            "det(A) becomes undefined"
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
            hint: "Think about the maximum dimension of ℝ² versus the number of vectors you have.",
            options: [
                "They must be linearly dependent, because dim(ℝ²) = 2",
                "They form a valid basis because more vectors give better coverage",
                "They automatically span a 3D subspace",
                "They must all be zero vectors"
            ],
            correctIndex: 0,
            explanation: "In ℝⁿ, any set containing more than n vectors is always linearly dependent. Since dim(ℝ²) = 2, any group of 3 vectors in the plane must contain redundancy.",
            visualization: .vectorSpaces
        ),
    
    Question(
           subject: .linearAlgebra,
           text: "You apply a reflection across a line L to vector v⃗, producing v⃗'. Under what geometric condition does {v⃗, v⃗'} fail to form a basis for ℝ²?",
           hint: "Move v⃗ around. Where does the original vector and its mirror image become collinear?",
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
            text: "You rotate both e⃗₁ and e⃗₂ by 30° around the origin. What happens to their span and linear independence?",
            hint: "Does rotation change the angle between vectors or destroy their ability to span ℝ²? Try moving them by the same rotation amount.",
            options: [
                "They remain independent and still span ℝ²",
                "They lose independence because rotation bends their paths",
                "Their span drops to 1D because they're no longer grid-aligned",
                "They become a 3D basis because rotation adds depth"
            ],
            correctIndex: 0,
            explanation: "Rigid rotations preserve lengths and angles. The vectors remain orthogonal (90° apart) and non-zero, forming a new orthonormal basis that spans the same ℝ².",
            visualization: .determinant
        ),
    
    Question(
        subject: .linearAlgebra,
        text: "In ℝ³, you have a plane P = span{v⃗₁, v⃗₂}. You add w⃗ forming angle ε > 0 with P. Do {v⃗₁, v⃗₂, w⃗} form a basis for ℝ³?",
        hint: "Slightly lift w⃗ out of the plane. Is the volume spanned completely flat (zero) or just very small?",
        options: [
            "No, because ε is too small",
            "Yes, because ε ≠ 0 means w⃗ ∉ P, so they're independent and span ℝ³",
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
            hint: "Pick 'Rotation about z', then try to find a v⃗ untouched by the linear transformation",
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
            hint: "Pick 'Dependent columns', drag the v⃗ cells to (2, −1, 0) and watch the golden A·v⃗ arrow. WHere does it land ?",
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
        text: "Why is the canonical basis {e⃗₁, e⃗₂, e⃗₃} fundamentally associated with the identity matrix I?",
        hint: "Select 'Identity' and observe how each colored arrow points exactly along the standard basis directions.",
        options: [
            "Because the columns of I are exactly {e⃗₁, e⃗₂, e⃗₃}, so I·v⃗ = v⃗ for all v⃗",
            "Because any diagonal matrix with identical entries defaults to I",
            "Because det(I) equals the sum of the basis vectors",
            "Because changing basis always transforms any matrix into I"
        ],
        correctIndex: 0,
        explanation: "The columns of a matrix represent where the basis vectors land. Since I has columns {e⃗₁, e⃗₂, e⃗₃}, it maps each basis vector to itself: I·e⃗ᵢ = e⃗ᵢ. Thus I·v⃗ = v⃗ for all v⃗. The identity is not 'neutral by convention', it's the unique map whose columns are the basis you're reading coordinates in.",
        visualization: .linearTransformations
    ),
    Question(
            subject: .linearAlgebra,
            text: "Under the projection onto the xy-plane, the vectors v⃗ = (1, 1, 1) and w⃗ = (1, 1, 0) have the same image. What does that say about the transformation?",
            hint: "Pick 'Projection onto xy' and set v⃗ to (1, 1, 1), then to (1, 1, 0).",
            options: [
                "It is not injective: distinct vectors share an image, but surjective with ℝ³ spanned by the transformation",
                "It is injective, since the two vectors are close together",
                "It is not injective: distinct vectors share an image, but not surjective as the kernel has dimension 1.",
                "It is surjective onto ℝ³"
            ],
            correctIndex: 0,
            explanation: "Two different inputs landing on the same output makes A non-injective, and the difference v⃗ − w⃗ = (0, 0, 1) sits in the kernel. In fact, every vector of the form (0,0,c), with c in ℝ, belongs to the kernel, a line in ℝ³, meaning the image has dimension 2.",
            visualization: .linearTransformations
        ),
    
  
]



let imagesQuestions = [
    Question(
        subject: .linearAlgebra,
        text: "Why is the canonical basis {e⃗₁, e⃗₂, e⃗₃} the basis associated with the identity matrix?",
        hint: "Select 'Identity'. Each column of a matrix is the image of one basis vector. What must those images be for v⃗ to survive untouched?",
        options: [
            "Because the columns of I are exactly {e⃗₁, e⃗₂, e⃗₃}, so I·v⃗ = v₁·e⃗₁ + v₂·e⃗₂ + v₃·e⃗₃ = v⃗",
            "Because det(I) = 1, and any matrix with det = 1 preserves coordinates",
            "Because I is symmetric, so it cannot favor one axis",
            "Because I is the only matrix with entries in {0, 1}"
        ],
        correctIndex: 0,
        explanation: "Writing v⃗ = v₁·e⃗₁ + v₂·e⃗₂ + v₃·e⃗₃ and applying linearity: A·v⃗ = v₁·(A·e⃗₁) + v₂·(A·e⃗₂) + v₃·(A·e⃗₃). A matrix is entirely determined by where it sends the basis vectors (its columns). Asking A·v⃗ = v⃗ for all v⃗ forces A·e⃗ᵢ = e⃗ᵢ, i.e., A = I. The identity is not 'neutral by convention'; it's the unique map whose columns are the basis you're using. (det = 1 is weaker: rotations also have det = 1.)",
        visualization: .image
    ),

    Question(
        subject: .linearAlgebra,
        text: "For the a linear transformation such that the columns of the matrix form a horizontal plane, what is im A?",
        hint: "Select 'Plane · rank 2'. The third column c⃗₃ = c⃗₁ + c⃗₂ is redundant. Watch the transformation, what is the dimension of the resulting shape ?",
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
        hint: "Select 'Zero map'. Every lattice point collapses to the origin. Count the dimensions.",
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
        text: "For the projection onto xy (third column is 0⃗), what are dim(ker A) and the vector spanning it?",
        hint: "Select 'Projection onto xy'. Watch which axis collapses to the origin while the xy-plane stays flat.",
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
        hint: "Select 'Line · rank 1' to see this collapse. Rank Theorem: dim(ker T) + dim(im T) = 3.",
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
        text: "For a shear matrix (I + the value 1 in entry (1,3)), which points in ℝ³ remain fixed?",
        hint: "Select 'Shear' and rotate the view. Which plane stays still while other layers slide sideways?",
        options: [
            "The xy-plane (z = 0), because the shear only affects x based on z",
            "Only the origin (0, 0, 0)",
            "The yz-plane (x = 0)",
            "No points are fixed"
        ],
        correctIndex: 0,
        explanation: "With 2 in position (1,3), the transformation modifies x' = x + 2z. Any point with z = 0 (the entire xy-plane) remains stationary, while points above/below slide sideways.",
        visualization: .image
    ),

]


