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
        text: "What is the result of multiplying a 3×2 matrix A by a 2×4 matrix B?",
        hint: "Matrix multiplication AB is only defined when the number of columns in A equals the number of rows in B.",
        options: ["3×4 matrix", "2×2 matrix", "3×2 matrix", "Undefined"],
        correctIndex: 0,
        explanation: "When multiplying an m×n matrix by an n×p matrix, the result is an m×p matrix. Here: (3×2) × (2×4) = 3×4 matrix.",
        visualization: .matrixOperations
    ),
    Question(
        subject: .linearAlgebra,
        text: "For a matrice A that is non-square, which statement is correct?",
        hint: "Consider the dimensions and order of multiplication.",
        options: ["AAt is well-defined", "AtA is well-defined", "Both AtA and AAt are well-defined", "Neither AtA is well-defined, nor AAt"],
        correctIndex: 1,
        explanation: "A has shape nxm where n!= m, therefore: (n,m),(m,n) and (m,n)(n,m) are valid shapes for products",
        visualization: .matrixOperations
    ),
    Question(
        subject: .linearAlgebra,
        text: "Let A has shape (3,2) and B has shape (4,3) what is the resulting shape of the following operation: A((ABt)t) ?",
        hint: "Decompose the product",
        options: ["(ABt)T", "3×2 matrix", "3×3 matrix", "2×2 matrix"],
        correctIndex: 1,
        explanation: "Transposing an m×n matrix produces an n×m matrix. The transpose of a 2×3 matrix is a 3×2 matrix.",
        visualization: .matrixOperations
    ),
    Question(
        subject: .linearAlgebra,
        text: "What is the identity matrix I multiplied by any matrix A of compatible size?",
        hint: "The identity matrix is the multiplicative identity.",
        options: ["0 (zero matrix)", "A", "A²", "I"],
        correctIndex: 1,
        explanation: "IA = AI = A. The identity matrix I is the multiplicative identity, leaving any matrix unchanged.",
        visualization: .matrixOperations
    )
]

// MARK: - Determinant Questions

let determinantQuestions = [
    Question(
        subject: .linearAlgebra,
        text: "What is the determinant of [[2, 0], [c, 3]]?",
        hint: "Think about the area spanned by the parallelogramm how does it differ when you change c",
        options: ["5", "6", "0", "c"],
        correctIndex: 1,
        explanation: "TO BE C",
        visualization: .determinant
    ),
    Question(
        subject: .linearAlgebra,
        text: "Why intuitively does [[2, 0], [c, 3]] has 1/3 of det of [ 3 * [2, 0], [c, 3]] ",
        hint: "TO BE C",
        options: ["three times the new area, we take three copies of a parallelogramm", "TO BE C", "TO BE C", "TO BE C"],
        correctIndex: 0,
        explanation: "TO BE C",
        visualization: .determinant
    ),
]



let vectorSpaceQuestions = [
    
    Question(
        subject: .linearAlgebra,
        text: "Are the vectors (1,0), (0,1), and (1,1) linearly independent in ℝ²?",
        hint: "Can you express one as a linear combination of the others?",
        options: ["Yes", "No", "Only if scaled", "Cannot determine"],
        correctIndex: 1,
        explanation: "(1,1) = (1,0) + (0,1), so they are linearly dependent. You cannot have 3 independent vectors in ℝ².",
        visualization: .vectorSpaces
    ),
    Question(
        subject: .linearAlgebra,
        text: "What does it mean if a plane is spanned by two vectors in R3 and one of them forms an angle epislon with the plane, does the whole form a basis",
        hint: "Try to incline slightly one of the vector, is the volume empty or just small ?.",
        options: ["A single vector", "All linear combinations of those vectors", "The zero vector only", "The largest vector"],
        correctIndex: 1,
        explanation: "Span(v₁, v₂, ..., vₙ) = {a₁v₁ + a₂v₂ + ... + aₙvₙ | aᵢ ∈ ℝ}, all linear combinations.",
        visualization: .vectorSpaces
    ),
    Question(
        subject: .linearAlgebra,
        text: "Given ",
        hint: "A basis must span the space and be linearly independent.",
        options: ["Any set of vectors", "A linearly independent set that spans V", "The largest set of vectors", "Only orthogonal vectors"],
        correctIndex: 1,
        explanation: "A basis is a linearly independent set of vectors that spans the entire vector space V.",
        visualization: .vectorSpaces
    )
]

let linearTransformQuestions = [
    
    Question(
        subject: .linearAlgebra,
        text: "What does a rotation matrix do in 2D?",
        hint: "It rotates vectors around the origin.",
        options: ["Scales vectors", "Rotates vectors around origin", "Reflects vectors", "Translates vectors"],
        correctIndex: 1,
        explanation: "A 2D rotation matrix rotates vectors by a fixed angle θ around the origin without changing their length.",
        visualization: .linearTransformations
    ),
    Question(
        subject: .linearAlgebra,
        text: "What is the effect of a diagonal matrix [[2,0],[0,3]] on a vector?",
        hint: "Diagonal matrices scale each coordinate independently.",
        options: ["Rotates the vector", "Scales x by 2, y by 3", "Reflects the vector", "Adds 2 to x, 3 to y"],
        correctIndex: 1,
        explanation: "A diagonal matrix scales each coordinate independently: (x,y) → (2x, 3y).",
        visualization: .linearTransformations
    )
]


// MARK: - 3D Matrix Transform Questions

let matrix3DQuestions = [
    Question(
        subject: .linearAlgebra,
        text: "why is the canonical base (profound reason) associated to the identity matrix",
        hint: "How do we guarantee for any vector v the same coefficients as in the initial base ?",
        options: ["after applying A, we have that e1 * coeff 1... = v (unchanged)", "To BE CONTINUED..]", "[[1,1,1],[1,1,1],[1,1,1]]", "[[2,0,0],[0,2,0],[0,0,2]]"],
        correctIndex: 0,
        explanation: "The 3D identity matrix I₃ = [[1,0,0],[0,1,0],[0,0,1]] leaves every vector v unchanged: I₃v = v.",
        visualization: .linearTransformations
    ),
    Question(
        subject: .linearAlgebra,
        text: "What does the matrix [[2,0,0],[0,2,0],[0,0,2]] do to a 3D object?",
        hint: "All diagonal entries are the same.",
        options: ["Rotates it", "Scales it uniformly by 2", "Reflects it", "Shears it"],
        correctIndex: 1,
        explanation: "This is a uniform scaling matrix that multiplies all coordinates by 2, making the object twice as large.",
        visualization: .linearTransformations
    ),
]

