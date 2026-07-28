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
            "Only A Aᵀ is well-defined",
            "Only Aᵀ A is well-defined",
            "Both Aᵀ A and A Aᵀ are well-defined square matrices",
            "Neither product is well-defined"
        ],
        correctIndex: 2,
        explanation: "Since A is m×n and Aᵀ is n×m, the product Aᵀ A is (n×m) × (m×n) = n×n, and A Aᵀ is (m×n) × (n×m) = m×m. Both are perfectly valid and result in square matrices.",
        visualization: .matrixOperations
    ),
    Question(
            subject: .linearAlgebra,
            text: "Let A be a 3×2 matrix and B be a 4×2 matrix. What is the resulting shape of the composite operation: ((A · Bᵀ)ᵀ) · A ?",
            hint: "Simplify the expression using the property (X · Y)ᵀ = Yᵀ · Xᵀ before analyzing the dimensions step by step.",
            options: [
                "4×2 matrix",
                "3×2 matrix",
                "4×3 matrix",
                "The operation is mathematically undefined"
            ],
            correctIndex: 0,
            explanation: "Let's simplify: ((A · Bᵀ)ᵀ) = (Bᵀ)ᵀ · Aᵀ = B · Aᵀ. Now the full expression becomes: B · Aᵀ · A. Checking dimensions: B is 4×2, Aᵀ is 2×3, and A is 3×2. The composition (4×2) × (2×3) × (3×2) is perfectly valid and results in a 4×2 matrix.",
            visualization: .matrixOperations
    ),
    Question(
        subject: .linearAlgebra,
        text: "What is the shape of the product $A B B^T A$?",
        hint: "Track dimensions step by step from left to right.",
        options: [
                "3×2 matrix",
                "3×3 matrix",
                "2×2 matrix",
                "The operation is undefined due to a dimension mismatch"
        ],
        correctIndex: 0,
        explanation: "1) AB is (3×3). 2) ABBᵀ is (3×2). 3) ABBᵀA is (3×2).",
        visualization: .matrixOperations
    )
]



let determinantQuestions = [
    Question(
        subject: .linearAlgebra,
        text: "What is the determinant of the matrix [[2, 0], [c, 3]]? How does changing the value of 'c' affect the area of the grid's parallelogram?",
        hint: "Try dragging the vertex horizontally to change 'c'. Does the base or the height of the parallelogram change?",
        options: [
            "6, because changing 'c' shears the parallelogram but leaves its base and height completely unchanged",
            "6 + c, because increasing 'c' stretches the sides and increases the total area",
            "3c, because the area depends entirely on the horizontal shift",
            "0, because the matrix becomes dependent when 'c' varies"
        ],
        correctIndex: 0,
        explanation: "The determinant is 2 × 3 - 0 × c = 6. Geometrically, changing 'c' creates a shearing effect (transvection). This shifts the vertex parallel to the base, keeping both the base (2) and the height (3) constant. Therefore, the area remains exactly 6.",
        visualization: .determinant
    ),
    Question(
        subject: .linearAlgebra,
        text: "If you drag a vertex to triple the length of one row vector, why does the new parallelogram have exactly 3 times the original determinant?",
        hint: "What happens to the area when you scale only one dimension of the parallelogram?",
        options: [
            "Because scaling one vector by 3 scales the height or base by 3, creating an area equivalent to 3 identical copies stacked together",
            "Because scaling one vector automatically triples the length of the other vector as well",
            "Because the determinant always increases by 3² (9) whenever any change is made to the coordinate space",
            "Because it changes the orientation of the shape without modifying its internal grid proportions"
        ],
        correctIndex: 0,
        explanation: "The determinant is linear with respect to each row/column. Visually, multiplying one vector by 3 stretches the parallelogram in that direction by a factor of 3. This is equivalent to stacking 3 copies of the original area together.",
        visualization: .determinant
    ),
    Question(
        subject: .linearAlgebra,
        text: "What happens to the signed area (determinant) if you drag the vectors so that they cross over each other, reversing their relative orientation?",
        hint: "Watch the sign of the determinant in your view when vector 1 moves past vector 2.",
        options: [
            "The determinant flips its sign and becomes negative, reflecting the change in orientation",
            "The determinant remains strictly positive because an area cannot be negative",
            "The determinant drops to zero and stays there as long as they are crossed",
            "The determinant becomes undefined because the parallelogram turns inside out"
        ],
        correctIndex: 0,
        explanation: "The determinant measures *signed* area. Reversing the orientation of the vectors (switching from a counter-clockwise to a clockwise order) flips the sign of the determinant from positive to negative, even if the absolute area is identical.",
        visualization: .determinant
    )
]



let vectorSpaceQuestions = [
    
    Question(
            subject: .linearAlgebra,
            text: "Imagine you are given three vectors in a 2D plane. Without doing any math, what can you immediately conclude about this set of vectors?",
            hint: "Think about the maximum possible dimension of the space versus the number of vectors you have.",
            options: [
                "They must be linearly dependent because a 2D space can hold at most two linearly independent vectors",
                "They form a valid basis for the 2D plane because more vectors give more coverage",
                "They automatically span a 3D subspace",
                "They must all be zero vectors"
            ],
            correctIndex: 0,
            explanation: "In an n-dimensional space, any set containing more than n vectors is always linearly dependent. Since a 2D plane has a maximum dimension of 2, any group of 3 vectors in that plane must contain redundancy.",
            visualization: .vectorSpaces
        ),
    
    Question(
           subject: .linearAlgebra,
           text: "You have a vector v on the screen. You apply a reflection (symmetry) across a line, turning it into v'. If you now look at the set {v, v'}, under what exact geometric alignment will this set suddenly fail to form a basis for your 2D space?",
           hint: "Move v around. Is there a specific position where the original vector and its mirrored image fall onto the exact same line?",
           options: [
               "Whenever v lies perfectly on the axis of reflection, or is perpendicular to it",
               "Only when v is strictly perpendicular to the axis of reflection",
               "Whenever v makes a 45-degree angle with the axis of reflection",
               "A reflection always preserves independence; they will never fail to form a basis"
           ],
           correctIndex: 0,
           explanation: "If v is on the axis, the reflection does nothing (v' = v). If v is perpendicular to the axis, the reflection reverses it (v' = -v). In both specific cases, v and v' become collinear (parallel). Their span drops to a 1D line, failing to form a 2D basis.",
           visualization: .vectorSpaces
       ),
    
    Question(
        subject: .linearAlgebra,
        text: "In a 3D space, you have a plane spanned by two vectors. You add a third vector that forms a tiny angle ε (epsilon) with this plane. Do these three vectors form a basis for ℝ³?",
        hint: "Try to slightly lift the third vector out of the plane. Is the volume spanned by the three vectors completely flat (zero) or just very small?",
        options: [
            "No, because the angle is too small and the vectors remain virtually dependent",
            "Yes, because as long as ε ≠ 0, the third vector is not in the plane, meaning they are independent and span ℝ³",
            "Only if the third vector is perfectly orthogonal (90 degrees) to the plane",
            "No, they only span a 2D subspace regardless of the angle"
        ],
        correctIndex: 1,
        explanation: "As long as the angle ε is strictly greater than zero, the third vector does not belong to the span of the first two. Visually, the parallelopiped formed has a non-zero volume (even if tiny). They are linearly independent and thus form a valid basis for ℝ³.",
        visualization: .vectorSpaces
    ),
    Question(
            subject: .linearAlgebra,
            text: "You take two perpendicular unit vectors pointing along the x and y axes, and you rotate both of them by 30 degrees around the origin. What happens to the span and linear independence of this new pair of vectors?",
            hint: "Think about whether rotation changes the angle between vectors or destroys their ability to cover the plane.",
            options: [
                "They remain linearly independent and still span the exact same 2D plane",
                "They lose their independence because rotating them bends their straight paths",
                "Their span drops to 1D because they are no longer aligned with the grid lines",
                "They transform into a 3D basis because rotation adds depth"
            ],
            correctIndex: 0,
            explanation: "Rigid rotations preserve lengths and angles. Since the vectors remain orthogonal (still at a 90-degree angle to each other) and non-zero, they form a new valid orthonormal basis that spans the exact same 2D vector space.",
            visualization: .vectorSpaces
        ),
]

let linearTransformQuestions = [
    Question(
        subject: .linearAlgebra,
        text: "You apply a 3D transformation matrix T to the entire space. You notice that an entire 2D flat plane of grid points instantly collapses into a single straight 1D line. What does this tell you about the rank and the kernel (Ker) of T?",
        hint: "Think about the dimension lost. If a plane (2D) squashes into a line (1D), how many independent directions were completely flattened to zero?",
        options: [
            "The rank of T is 1, and the kernel has a dimension of 2",
            "The rank of T is 2, and the kernel has a dimension of 1",
            "The rank of T is 1, and the kernel has a dimension of 1",
            "The transformation is still invertible because the line is not a single point"
        ],
        correctIndex: 1,
        explanation: "The space started in 3D. The image of the transformation is a line, so Rank(T) = dim(Im(T)) = 1. By the Rank-Nullity theorem, dim(Ker(T)) = 3 - 1 = 2. This means a whole 2D plane of the original space was squashed into the origin (zero vector), causing the remaining plane to flatten into that line.",
        visualization: .linearTransformations
    ),
    Question(
        subject: .linearAlgebra,
        text: "You have two transformations in your 3D view: a rotation R around the z-axis by 90° and a non-uniform scaling S that only stretches the x-axis. If you take a vector and apply these two transformations one after the other, does the order matter?",
        hint: "Try it in your head. Rotate then stretch the x-axis, versus stretch the x-axis then rotate. Do they target the same physical components of the vector?",
        options: [
            "No, because matrix multiplication is associative, so R after S is always equal to S after R",
            "Yes, because stretching the x-axis before rotating changes a different spatial component than stretching it after the vector has already turned",
            "No, because non-uniform scaling and rotations always commute in 3D space",
            "Yes, but only if the vector lies perfectly on the z-axis"
        ],
        correctIndex: 1,
        explanation: "Matrix multiplication is generally non-commutative (RS ≠ SR). Visually, if you scale x first then rotate, the stretched part is rotated onto the y-axis. If you rotate first, the original y-component lands on the x-axis and *then* gets stretched. The final vectors point in completely different directions.",
        visualization: .linearTransformations
    ),
    Question(
        subject: .linearAlgebra,
        text: "You apply a 3D transformation matrix that reflects the space across a plane (mirror effect) followed by a 3D rotation. If you look at a right-handed trio of vectors (like your thumb, index, and middle finger pointing along x, y, and z), what happens to their relative orientation after the transformation?",
        hint: "Can you rotate a mirrored object in 3D space to make it look exactly like the original again?",
        options: [
            "The trio becomes left-handed (inverted orientation) because the reflection permanently flipped the space, and the rotation cannot undo this",
            "The trio remains right-handed because the rotation corrects the inversion caused by the mirror",
            "The vectors become coplanar because reflections collapse one degree of freedom",
            "The orientation flips only if the rotation axis is perfectly parallel to the reflection plane"
        ],
        correctIndex: 0,
        explanation: "A reflection has a negative determinant (-1), which flips the orientation of the space (right-handed becomes left-handed). A rotation has a positive determinant (+1) and preserves orientation. The composite transformation has a determinant of (-1) × (+1) = -1. The space remains inverted, and no amount of 3D rotation can ever undo a mirror reflection.",
        visualization: .linearTransformations
    ),
    Question(
        subject: .linearAlgebra,
        text: "You rotate the 3D space around a specific axis vector, but you don't know which one. You track a special non-zero vector v and notice that after the rotation, v has not moved a single millimeter. What is the geometric relationship between v and the axis of rotation?",
        hint: "If the whole space turns, which points are the only ones that stay perfectly still?",
        options: [
            "v is strictly perpendicular to the axis of rotation",
            "v lies perfectly along the axis of rotation, meaning it is an eigenvector with an eigenvalue of 1",
            "v is the zero vector, which is why its coordinates didn't change",
            "v has been scaled down to zero by the rotation matrix"
        ],
        correctIndex: 1,
        explanation: "During a 3D rotation, the only invariant points (aside from the origin) are the ones lying directly on the axis of rotation. Since T(v) = v, v is an eigenvector corresponding to the eigenvalue λ = 1, identifying the axis itself.",
        visualization: .linearTransformations
    )
]


let matrix3DQuestions = [
    Question(
        subject: .linearAlgebra,
        text: "Why is the canonical basis fundamentally associated with the identity matrix?",
        hint: "Think about how a matrix transformation is built using the images of the standard basis vectors.",
        options: [
            "Because its columns are precisely the canonical basis vectors (e₁, e₂, e₃), meaning each basis vector is mapped to itself",
            "Because any diagonal matrix with identical non-one entries on the main diagonal automatically defaults to the identity mapping",
            "Because the identity matrix is the unique matrix whose determinant equals the sum of its canonical column vectors",
            "Because changing the basis of a vector space always transforms any arbitrary linear map into an identity matrix"
        ],
        correctIndex: 0,
        explanation: "The columns of a transformation matrix represent the exact coordinates where the canonical basis vectors land. Since the identity matrix uses standard unit vectors as its columns, it leaves every basis vector—and by extension every vector v—completely unchanged.",
        visualization: .linearTransformations
    ),
    Question(
        subject: .linearAlgebra,
        text: "You tweak the transformation matrix to a shear matrix (i.e. Identity matrix + 2 in the top-right entry, affecting e₃). Which points are completely unaffected by this linear transformation?",
        hint: "Check which layers are affected by looking from different angles",
        options: [
            "The entire xy-plane (where z = 0), because the shear only displaces coordinates along the x-axis based on z",
            "Only the single point at the exact origin (0,0,0)",
            "The entire yz-plane (where x = 0), because x-coordinates remain locked",
            "No points are unaffected; every single point in space is forced to move"
        ],
        correctIndex: 0,
        explanation: "With a 2 in the top-right entry of a 3×3 matrix (position row 1, column 3), the transformation modifies the x-coordinate by adding $2z$ to it ($x' = x + 2z$). Therefore, any point where $z = 0$ (the entire xy-plane) undergoes zero change, remaining completely stationary while points above or below slide sideways.",
        visualization: .image
    ),
    Question(
        subject: .linearAlgebra,
        text: "You are given the null matrix (only zero entries). How does this extreme case reveal the trade-off between the dimensions of ker A and im A?",
        hint: "Everything that dies in the kernel is a direction the image never gets to use — count how many directions each one absorbs here",
        options: [
            "$\\dim \\ker A = 3$ and $\\dim \\text{im } A = 0$: the kernel swallows all three directions, so the image has none left, and $3 + 0 = 3$",
            "$\\dim \\ker A = 0$ and $\\dim \\text{im } A = 0$: nothing moves and nothing is reached, so both are empty",
            "$\\dim \\ker A = 3$ and $\\dim \\text{im } A = 3$: every point is a preimage of the origin and the origin belongs to ℝ³",
            "The dimensions are independent quantities; the null matrix is a degenerate case where no relation holds"
        ],
        correctIndex: 0,
        explanation: "Rank–nullity gives $\\dim \\ker A + \\dim \\text{im } A = 3$, and the null matrix pushes it to one extreme: $\\ker A = \\mathbb{R}^3$, $\\text{im } A = \\{0\\}$, so $3 + 0 = 3$. Visually, the entire lattice is squeezed onto the single dot at the origin — the identity sits at the opposite end ($0 + 3$), and every preset in between splits the same three directions.",
        visualization: .image
    ),
    Question(
        subject: .linearAlgebra,
        text: "Select the preset \"Projection on xy\" (the third column is zeroed out). What is the dimension of ker A, and which vector spans it?",
        hint: "Zero out the third column and follow the thin threads: which ones never leave the origin?",
        options: [
            "dim ker A = 0: the kernel is just {0}, a linear map is always injective on the lattice",
            "dim ker A = 1, spanned by $e_3 = (0,0,1)$: the whole z-axis collapses onto the origin",
            "dim ker A = 2, spanned by $e_1$ and $e_2$: the xy-plane is exactly what gets crushed",
            "dim ker A = 1, spanned by $e_1 = (1,0,0)$: the first column is the one that survives"
        ],
        correctIndex: 1,
        explanation: "$A(0,0,z) = z \\cdot Ae_3$, and the preset sets $Ae_3 = 0$, so every point of the z-axis lands on the origin: $\\ker A = \\text{span}(e_3)$, a line, hence $\\dim \\ker A = 1$. Rank–nullity confirms it: $\\dim \\text{im } A = 2$ (the xy-plane) and $2 + 1 = 3$. Careful not to swap the two: the xy-plane is where everything *lands* (the image), the z-axis is what gets *crushed* (the kernel) — rotate the view to see them as two distinct subspaces meeting only at the origin.",
        visualization: .image
    ),
]


let imagesQuestions = [
    Question(
        subject: .linearAlgebra,
        text: "Set the matrix to the identity. Why is the canonical basis, more profoundly than \"it has ones on the diagonal\", the basis associated with I?",
        hint: "Look at the three coloured arrows: each column of a matrix is the image of one basis vector. What must those images be for the coefficients of v to survive untouched?",
        options: [
            "Because its columns are exactly e⃗₁, e⃗₂, e⃗₃, so Iv⃗ = v_1e_1 + v_2e_2 + v_3e_3 = v$: the coefficients read in the source basis are re-used unchanged as coordinates of the output",
            "Because its determinant equals 1, and any matrix of determinant 1 preserves coordinates",
            "Because it is symmetric, so it cannot favour one axis over another",
            "Because it is the only matrix whose entries are all 0 or 1"
        ],
        correctIndex: 0,
        explanation: "Writing $v = v_1e_1 + v_2e_2 + v_3e_3$ and applying linearity gives $Av = v_1(Ae_1) + v_2(Ae_2) + v_3(Ae_3)$: a matrix is entirely determined by where it sends the basis vectors, and those images *are* its columns. Asking for $Av = v$ for every $v$ therefore forces $Ae_i = e_i$, i.e. $A = I$. The identity is not \"the neutral matrix\" by convention — it is the unique map whose columns are the very basis you are reading coordinates in. Determinant 1 is far weaker: a rotation also has $\\det = 1$ and moves every coefficient.",
        visualization: .image
    ),

    Question(
        subject: .linearAlgebra,
        text: "Enter the matrix [[1,0,0],[0,1,1],[0,0,0]] by dragging the cells. What is im A, and what does the last row being zero tell you?",
        hint: "Write down the three columns and see how many independent directions they really span",
        options: [
            "im A = ℝ³: three non-zero columns always span the whole space",
            "im A is the xy-plane (dim 2): the columns are $(1,0,0)$, $(0,1,0)$, $(0,1,0)$ — the last two coincide, and the zero bottom row forbids any output with $z \\neq 0$",
            "im A is a line (dim 1), since only one row is free of zeros",
            "im A = {0}: a matrix with a zero row kills every vector"
        ],
        correctIndex: 1,
        explanation: "Read the matrix column by column: $Ae_1 = (1,0,0)$, $Ae_2 = (0,1,0)$, $Ae_3 = (0,1,0)$. Only two of them are distinct directions, so $\\dim \\text{im } A = 2$ and $\\text{im } A$ is the xy-plane. A zero *row* is a constraint on the output — no image can ever have a third coordinate — while a zero *column* would mean a basis vector is killed. Rank–nullity then gives $\\dim \\ker A = 1$, and indeed $A(0,1,-1) = 0$: the collapse direction is tilted, not an axis.",
        visualization: .image
    ),

    Question(
        subject: .linearAlgebra,
        text: "Select 'Projection on xy' (diag(1, 1, 0)) what bis the ker A",
        hint: "Read the matrix column by column: what is the image of e₃?",
        options: ["(2, −3, 7)", "(2, −3, 0)", "(0, 0, 7)", "(2, −3, −7)"],
        correctIndex: 1,
        explanation: "A·e₃ = 0, so the z-component is simply discarded: Ax = (2, −3, 0). The image is the xy-plane (dim 2) and the kernel is the z-axis (dim 1). Note that A² = A — projecting twice changes nothing, which you can check by feeding (2,−3,0) back in.",
        visualization: .image
    ),
]

