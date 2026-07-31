//
//  LinearAlgebraQuestions.swift
//  EPFLearn
//
//  Created on 21.07.2026.
//

import Foundation

// MARK: - Matrix Operations Questions

let matrixOperationsQuestions = [
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
            "4×2 matrix",
            "3×2 matrix",
            "4×3 matrix",
            "The operation is mathematically undefined"
        ],
        correctIndex: 0,
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



let determinantQuestions = [
    Question(
        subject: .linearAlgebra,
        text: "What is det([[2, 0], [c, 3]])? How does varying c affect the area of the parallelogram spanned by the column vectors?",
        hint: "Drag the vertex horizontally to change c. Does the base or the height of the parallelogram change?",
        options: [
            "det = 6 for any c, because shearing preserves both base and height",
            "det = 6 + c, because increasing c stretches the sides",
            "det = 3c, because the area depends entirely on the horizontal shift",
            "det = 0 for all c, because the matrix becomes singular"
        ],
        correctIndex: 0,
        explanation: "det = 2 × 3 − 0 × c = 6. Geometrically, varying c creates a shear (transvection). The vertex slides parallel to the base, keeping both the base (length 2) and the height (3) constant. Therefore, the signed area remains exactly 6.",
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
           visualization: .vectorSpaces
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
    Question(
            subject: .linearAlgebra,
            text: "You rotate both e⃗₁ and e⃗₂ by 30° around the origin. What happens to their span and linear independence?",
            hint: "Does rotation change the angle between vectors or destroy their ability to span ℝ²? Try moving them by the same amountnow plea",
            options: [
                "They remain independent and still span ℝ²",
                "They lose independence because rotation bends their paths",
                "Their span drops to 1D because they're no longer grid-aligned",
                "They become a 3D basis because rotation adds depth"
            ],
            correctIndex: 0,
            explanation: "Rigid rotations preserve lengths and angles. The vectors remain orthogonal (90° apart) and non-zero, forming a new orthonormal basis that spans the same ℝ².",
            visualization: .vectorSpaces
        ),
]

let linearTransformQuestions = [
    Question(
        subject: .linearAlgebra,
        text: "A 3×3 matrix T collapses a 2D plane of grid points into a 1D line. What are rank(T) and dim(ker T)?",
        hint: "Select 'Line · rank 1' to see this collapse. Rank-Nullity: dim(ker T) + dim(im T) = 3.",
        options: [
            "rank(T) = 2, dim(ker T) = 1",
            "rank(T) = 1, dim(ker T) = 2",
            "rank(T) = 1, dim(ker T) = 1",
            "T is still invertible because the image is not a point"
        ],
        correctIndex: 1,
        explanation: "The image is a line, so rank(T) = dim(im T) = 1. By Rank-Nullity, dim(ker T) = 3 − 1 = 2. A whole 2D plane of ℝ³ maps to 0⃗, and the remaining structure collapses into that line.",
        visualization: .linearTransformations
    ),
    Question(
        subject: .linearAlgebra,
        text: "You have rotation R (around z-axis, 90°) and non-uniform scaling S (stretches x-axis only). Does RS = SR?",
        hint: "Combine 'Rotation about z' with 'Scaling ×1.5'. Drag the morph slider to see which components get affected first.",
        options: [
            "Yes, matrix multiplication is associative",
            "No, stretching x then rotating affects a different component than rotating then stretching",
            "Yes, rotations and scalings always commute in ℝ³",
            "No, but only when vectors lie on the z-axis"
        ],
        correctIndex: 1,
        explanation: "Matrix multiplication is generally non-commutative (RS ≠ SR). If you scale x first, the stretched part rotates onto the y-axis. If you rotate first, the original y-component lands on x and then gets stretched. The final vectors differ.",
        visualization: .linearTransformations
    ),
    Question(
        subject: .linearAlgebra,
        text: "You compose a reflection M (det M = −1) with a rotation R (det R = +1). What happens to the orientation of ℝ³?",
        hint: "Select 'Reflection' (det = −1) and watch the colored axes flip. Can rotation undo this inversion?",
        options: [
            "The space becomes left-handed; rotation cannot undo the reflection",
            "The space stays right-handed; rotation corrects the inversion",
            "The vectors become coplanar",
            "Orientation flips only if the rotation axis is parallel to the reflection plane"
        ],
        correctIndex: 0,
        explanation: "det(MR) = det(M) · det(R) = (−1)(+1) = −1. The composition inverts orientation (right-handed → left-handed). No 3D rotation can undo a mirror reflection.",
        visualization: .linearTransformations
    ),
    Question(
        subject: .linearAlgebra,
        text: "You rotate ℝ³ around an unknown axis. A non-zero vector v⃗ satisfies T(v⃗) = v⃗. What is the geometric relationship between v⃗ and the axis?",
        hint: "Select 'Rotation about z' and observe which vectors stay still. The z-axis is an eigenvector with λ = 1.",
        options: [
            "v⃗ is perpendicular to the axis",
            "v⃗ lies along the axis (eigenvector with λ = 1)",
            "v⃗ is the zero vector",
            "v⃗ has been scaled to zero"
        ],
        correctIndex: 1,
        explanation: "During 3D rotation, only points on the axis remain fixed (aside from 0⃗). Since T(v⃗) = v⃗, v⃗ is an eigenvector with eigenvalue λ = 1, identifying the rotation axis.",
        visualization: .linearTransformations
    )
]


let matrix3DQuestions = [
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
        explanation: "The columns of a matrix represent where the basis vectors land. Since I has columns {e⃗₁, e⃗₂, e⃗₃}, it maps each basis vector to itself: I·e⃗ᵢ = e⃗ᵢ. Thus I·v⃗ = v⃗ for all v⃗. The identity is not 'neutral by convention'—it's the unique map whose columns are the basis you're reading coordinates in.",
        visualization: .linearTransformations
    ),
    Question(
        subject: .linearAlgebra,
        text: "For the shear matrix (I + 2 in entry (1,3)), which points in ℝ³ remain fixed?",
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
]


let imagesQuestions = [
    Question(
        subject: .linearAlgebra,
        text: "Why is the canonical basis {e⃗₁, e⃗₂, e⃗₃} the basis associated with I?",
        hint: "Select 'Identity'. Each column of a matrix is the image of one basis vector. What must those images be for v⃗ to survive untouched?",
        options: [
            "Because the columns of I are exactly {e⃗₁, e⃗₂, e⃗₃}, so I·v⃗ = v₁·e⃗₁ + v₂·e⃗₂ + v₃·e⃗₃ = v⃗",
            "Because det(I) = 1, and any matrix with det = 1 preserves coordinates",
            "Because I is symmetric, so it cannot favor one axis",
            "Because I is the only matrix with entries in {0, 1}"
        ],
        correctIndex: 0,
        explanation: "Writing v⃗ = v₁·e⃗₁ + v₂·e⃗₂ + v₃·e⃗₃ and applying linearity: A·v⃗ = v₁·(A·e⃗₁) + v₂·(A·e⃗₂) + v₃·(A·e⃗₃). A matrix is entirely determined by where it sends the basis vectors (its columns). Asking A·v⃗ = v⃗ for all v⃗ forces A·e⃗ᵢ = e⃗ᵢ, i.e., A = I. The identity is not 'neutral by convention'—it's the unique map whose columns are the basis you're using. (det = 1 is weaker: rotations also have det = 1.)",
        visualization: .image
    ),

    Question(
        subject: .linearAlgebra,
        text: "For the 'Plane · rank 2' preset, what is im A?",
        hint: "Select 'Plane · rank 2'. The third column c⃗₃ = c⃗₁ + c⃗₂ is redundant. Watch the flat yellow plane form.",
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
        text: "For 'Projection onto xy', what is A·(2, −3, c) for any c ∈ ℝ?",
        hint: "Select 'Projection onto xy'. The entire z-axis collapses. The z-component is discarded.",
        options: [
            "(2, −3, c)",
            "(2, −3, 0)",
            "(0, 0, c)",
            "(2, −3, −c)"
        ],
        correctIndex: 1,
        explanation: "A·e⃗₃ = 0⃗, so the z-component vanishes: A·(2, −3, c) = (2, −3, 0). The image is the xy-plane (dim 2), the kernel is the z-axis (dim 1).",
        visualization: .image
    ),
]


