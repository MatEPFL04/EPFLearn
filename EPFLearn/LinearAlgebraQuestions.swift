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
        text: "For matrices A and B, is AB always equal to BA?",
        hint: "Consider the dimensions and order of multiplication.",
        options: ["Yes, always", "No, matrix multiplication is not commutative", "Only if A = B", "Only for square matrices"],
        correctIndex: 1,
        explanation: "Matrix multiplication is NOT commutative. In general, AB ≠ BA. Even when both products are defined, they usually differ.",
        visualization: .matrixOperations
    ),
    Question(
        subject: .linearAlgebra,
        text: "What is the transpose of a 2×3 matrix?",
        hint: "Transposing swaps rows and columns.",
        options: ["2×3 matrix", "3×2 matrix", "3×3 matrix", "2×2 matrix"],
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
        text: "What is the determinant of [[2, 0], [0, 3]]?",
        hint: "For a diagonal matrix, the determinant is the product of diagonal elements.",
        options: ["5", "6", "0", "1"],
        correctIndex: 1,
        explanation: "det([[2,0],[0,3]]) = 2×3 - 0×0 = 6. For diagonal matrices, det = product of diagonal entries.",
        visualization: .determinant
    ),
    Question(
        subject: .linearAlgebra,
        text: "If det(A) = 0, what can we conclude about matrix A?",
        hint: "A zero determinant indicates the matrix is not invertible.",
        options: ["A is invertible", "A is singular (non-invertible)", "A is the zero matrix", "A is symmetric"],
        correctIndex: 1,
        explanation: "det(A) = 0 means A is singular (non-invertible). The columns/rows are linearly dependent.",
        visualization: .determinant
    ),
    Question(
        subject: .linearAlgebra,
        text: "What is det(AB) in terms of det(A) and det(B)?",
        hint: "The determinant has a multiplicative property.",
        options: ["det(A) + det(B)", "det(A) × det(B)", "det(A) - det(B)", "det(A) / det(B)"],
        correctIndex: 1,
        explanation: "det(AB) = det(A) × det(B). The determinant is multiplicative.",
        visualization: .determinant
    ),
    Question(
        subject: .linearAlgebra,
        text: "What happens to the determinant if you swap two rows of a matrix?",
        hint: "Row swapping is an elementary row operation.",
        options: ["Stays the same", "Changes sign", "Becomes zero", "Doubles"],
        correctIndex: 1,
        explanation: "Swapping two rows (or columns) multiplies the determinant by -1, changing its sign.",
        visualization: .determinant
    )
]

// MARK: - Eigenvalue Questions

let eigenvalueQuestions = [
    Question(
        subject: .linearAlgebra,
        text: "What is an eigenvector of a matrix A?",
        hint: "An eigenvector only gets scaled when multiplied by the matrix.",
        options: ["A vector that becomes zero when multiplied by A", "A non-zero vector v such that Av = λv for some scalar λ", "The determinant of A", "A row of matrix A"],
        correctIndex: 1,
        explanation: "An eigenvector v satisfies Av = λv, where λ is the corresponding eigenvalue. The matrix only scales the vector.",
        visualization: .eigenvalues
    ),
    Question(
        subject: .linearAlgebra,
        text: "What is the characteristic equation for finding eigenvalues of matrix A?",
        hint: "It involves the determinant and the identity matrix.",
        options: ["det(A) = 0", "det(A - λI) = 0", "Av = λv", "A - λI = 0"],
        correctIndex: 1,
        explanation: "Eigenvalues λ satisfy det(A - λI) = 0. This is the characteristic equation.",
        visualization: .eigenvalues
    ),
    Question(
        subject: .linearAlgebra,
        text: "What is the sum of eigenvalues of a matrix equal to?",
        hint: "Look at the diagonal elements.",
        options: ["The determinant", "The trace (sum of diagonal elements)", "Zero", "The rank"],
        correctIndex: 1,
        explanation: "The sum of eigenvalues equals the trace of the matrix (sum of diagonal elements).",
        visualization: .eigenvalues
    ),
    Question(
        subject: .linearAlgebra,
        text: "What is the product of eigenvalues of a matrix equal to?",
        hint: "This relates to invertibility.",
        options: ["The trace", "The determinant", "The rank", "1"],
        correctIndex: 1,
        explanation: "The product of eigenvalues equals the determinant of the matrix.",
        visualization: .eigenvalues
    )
]

// MARK: - Vector Space Questions

let vectorSpaceQuestions = [
    Question(
        subject: .linearAlgebra,
        text: "What is the dimension of ℝ³?",
        hint: "Dimension is the number of vectors in a basis.",
        options: ["1", "2", "3", "Infinite"],
        correctIndex: 2,
        explanation: "ℝ³ has dimension 3. A basis is {(1,0,0), (0,1,0), (0,0,1)} with 3 vectors.",
        visualization: .vectorSpaces
    ),
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
        text: "What is the span of a set of vectors?",
        hint: "It's all possible linear combinations.",
        options: ["A single vector", "All linear combinations of those vectors", "The zero vector only", "The largest vector"],
        correctIndex: 1,
        explanation: "Span(v₁, v₂, ..., vₙ) = {a₁v₁ + a₂v₂ + ... + aₙvₙ | aᵢ ∈ ℝ}, all linear combinations.",
        visualization: .vectorSpaces
    ),
    Question(
        subject: .linearAlgebra,
        text: "What defines a basis of a vector space V?",
        hint: "A basis must span the space and be linearly independent.",
        options: ["Any set of vectors", "A linearly independent set that spans V", "The largest set of vectors", "Only orthogonal vectors"],
        correctIndex: 1,
        explanation: "A basis is a linearly independent set of vectors that spans the entire vector space V.",
        visualization: .vectorSpaces
    )
]

// MARK: - Linear Transformation Questions

let linearTransformQuestions = [
    Question(
        subject: .linearAlgebra,
        text: "What defines a linear transformation T: V → W?",
        hint: "It must preserve vector addition and scalar multiplication.",
        options: ["T(v + w) = T(v) + T(w) and T(cv) = cT(v)", "T maps all vectors to zero", "T is always invertible", "T must be represented by a square matrix"],
        correctIndex: 0,
        explanation: "A linear transformation must satisfy: T(v + w) = T(v) + T(w) and T(cv) = cT(v) for all vectors v, w and scalars c.",
        visualization: .linearTransformations
    ),
    Question(
        subject: .linearAlgebra,
        text: "What is the kernel (null space) of a linear transformation T?",
        hint: "It's the set of vectors that map to zero.",
        options: ["All vectors in the domain", "Vectors v such that T(v) = 0", "The image of T", "The determinant of T"],
        correctIndex: 1,
        explanation: "ker(T) = {v | T(v) = 0}. The kernel consists of all vectors that map to the zero vector.",
        visualization: .linearTransformations
    ),
    Question(
        subject: .linearAlgebra,
        text: "What is the image (range) of a linear transformation T?",
        hint: "It's all possible output vectors.",
        options: ["All vectors v such that T(v) = 0", "All vectors w that can be written as T(v) for some v", "The domain of T", "The zero vector only"],
        correctIndex: 1,
        explanation: "Im(T) = {T(v) | v ∈ V}. The image is the set of all vectors that can be reached by T.",
        visualization: .linearTransformations
    ),
    Question(
        subject: .linearAlgebra,
        text: "What does the Rank-Nullity Theorem state?",
        hint: "It relates dimension, rank, and nullity.",
        options: ["rank(T) = nullity(T)", "dim(V) = rank(T) + nullity(T)", "rank(T) × nullity(T) = dim(V)", "rank(T) = dim(V)"],
        correctIndex: 1,
        explanation: "Rank-Nullity Theorem: dim(V) = rank(T) + nullity(T), where rank = dim(Im(T)) and nullity = dim(ker(T)).",
        visualization: .linearTransformations
    )
]

// MARK: - Gaussian Elimination Questions

let gaussianQuestions = [
    Question(
        subject: .linearAlgebra,
        text: "What is the goal of Gaussian elimination?",
        hint: "Transform the matrix to a simpler form.",
        options: ["Calculate the determinant", "Transform a matrix to row echelon form", "Find eigenvalues", "Multiply matrices"],
        correctIndex: 1,
        explanation: "Gaussian elimination transforms a matrix into row echelon form (REF) using elementary row operations.",
        visualization: .gaussianElimination
    ),
    Question(
        subject: .linearAlgebra,
        text: "What are the three elementary row operations?",
        hint: "Operations that don't change the solution set.",
        options: ["Add, subtract, multiply", "Swap rows, multiply row by scalar, add multiple of one row to another", "Transpose, inverse, determinant", "Eigenvalues, eigenvectors, diagonalization"],
        correctIndex: 1,
        explanation: "The three operations are: (1) swap two rows, (2) multiply a row by a non-zero scalar, (3) add a multiple of one row to another.",
        visualization: .gaussianElimination
    ),
    Question(
        subject: .linearAlgebra,
        text: "What is a pivot in row echelon form?",
        hint: "It's the first non-zero element in each row.",
        options: ["Any element in the matrix", "The first non-zero element in a row", "The diagonal elements", "The determinant"],
        correctIndex: 1,
        explanation: "A pivot is the first (leftmost) non-zero entry in a row of a matrix in row echelon form.",
        visualization: .gaussianElimination
    ),
    Question(
        subject: .linearAlgebra,
        text: "How many solutions does a consistent system Ax = b have if rank(A) < n (number of variables)?",
        hint: "Free variables lead to multiple solutions.",
        options: ["No solution", "Exactly one solution", "Infinitely many solutions", "Two solutions"],
        correctIndex: 2,
        explanation: "If rank(A) < n and the system is consistent, there are free variables, leading to infinitely many solutions.",
        visualization: .gaussianElimination
    )
]

// MARK: - Gram-Schmidt Questions

let gramSchmidtQuestions = [
    Question(
        subject: .linearAlgebra,
        text: "What is the purpose of the Gram-Schmidt process?",
        hint: "It creates a special kind of basis.",
        options: ["Find eigenvalues", "Create an orthonormal basis from a linearly independent set", "Solve linear systems", "Calculate determinants"],
        correctIndex: 1,
        explanation: "Gram-Schmidt transforms a linearly independent set into an orthonormal basis (orthogonal unit vectors).",
        visualization: .gramSchmidt
    ),
    Question(
        subject: .linearAlgebra,
        text: "What does 'orthogonal' mean for two vectors u and v?",
        hint: "Think about their inner product.",
        options: ["u = v", "u · v = 0", "||u|| = ||v||", "u + v = 0"],
        correctIndex: 1,
        explanation: "Two vectors are orthogonal if their inner product is zero: u · v = 0. They're perpendicular.",
        visualization: .gramSchmidt
    ),
    Question(
        subject: .linearAlgebra,
        text: "What does 'orthonormal' mean?",
        hint: "It combines two properties.",
        options: ["Orthogonal only", "Unit vectors only", "Orthogonal AND unit vectors (normalized)", "Linearly independent"],
        correctIndex: 2,
        explanation: "Orthonormal vectors are both orthogonal (perpendicular) to each other AND normalized (have length 1).",
        visualization: .gramSchmidt
    ),
    Question(
        subject: .linearAlgebra,
        text: "In Gram-Schmidt, how do you normalize a vector v?",
        hint: "Divide by its length.",
        options: ["v / det(v)", "v / ||v||", "v · v", "v + ||v||"],
        correctIndex: 1,
        explanation: "To normalize v, divide by its norm: û = v / ||v||. This creates a unit vector in the same direction.",
        visualization: .gramSchmidt
    )
]

// MARK: - Diagonalization Questions

let diagonalizationQuestions = [
    Question(
        subject: .linearAlgebra,
        text: "What does it mean for a matrix A to be diagonalizable?",
        hint: "It can be written using eigenvalues and eigenvectors.",
        options: ["A is already diagonal", "A = PDP⁻¹ where D is diagonal", "A has all zeros off the diagonal", "A is invertible"],
        correctIndex: 1,
        explanation: "A is diagonalizable if A = PDP⁻¹, where D is diagonal (containing eigenvalues) and P contains eigenvectors.",
        visualization: .diagonalization
    ),
    Question(
        subject: .linearAlgebra,
        text: "When is an n×n matrix A guaranteed to be diagonalizable?",
        hint: "It needs enough linearly independent eigenvectors.",
        options: ["Always", "When it has n linearly independent eigenvectors", "When det(A) ≠ 0", "When A is symmetric"],
        correctIndex: 1,
        explanation: "An n×n matrix is diagonalizable if and only if it has n linearly independent eigenvectors.",
        visualization: .diagonalization
    ),
    Question(
        subject: .linearAlgebra,
        text: "Are all symmetric matrices diagonalizable?",
        hint: "Symmetric matrices have special properties.",
        options: ["No", "Yes, and they're orthogonally diagonalizable", "Only if they're invertible", "Only 2×2 symmetric matrices"],
        correctIndex: 1,
        explanation: "Yes! All symmetric matrices are diagonalizable. In fact, they can be orthogonally diagonalized: A = QDQ^T.",
        visualization: .diagonalization
    ),
    Question(
        subject: .linearAlgebra,
        text: "If A = PDP⁻¹, what is A^k (A to the k-th power)?",
        hint: "Diagonalization makes computing powers easy.",
        options: ["PD^kP⁻¹", "P^kD^kP^-k", "kPDP⁻¹", "(PDP⁻¹)^k = A^k (no simplification)"],
        correctIndex: 0,
        explanation: "A^k = PD^kP⁻¹. Powers of diagonal matrices are easy: just raise each diagonal element to the k-th power.",
        visualization: .diagonalization
    )
]
