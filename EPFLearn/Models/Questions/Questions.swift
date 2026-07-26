//
//  Probabilities.swift
//  EPFLearn
//
//  Created by Mat on 04.04.2026.
//

//
//  Models.swift (English version)
//  EPFLearn
//
//  Questions rewritten in simple English for EPFL 1st/2nd year students
//

import SwiftUI

enum Subject: String, Codable, CaseIterable {
    case analysis, arrays, graphs, discreteMaths, linearAlgebra, programmingBasics
}
struct Question: Identifiable {
    let id = UUID()
    let subject: Subject
    let text: String
    let hint: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
    let visualization: VisualizationType
}

enum VisualizationType {
    
    case derivative
    case darboux
    case sequence
    case meanTheorem
    case TFI
    case fixedPoint
    case TAF
    case taylor
    case convergence
    case lhopital
    case sandwich
    case complexNumbers
    case trigo
    
    
    case matrixOperations
    case determinant
    case vectorSpaces
    case linearTransformations
    case gaussianElimination
    case ker
    case image
    
    
    case DFS
    case BFS
    case kruskal
    case prim
    case djikistra
    case bellmanford
    case topologicalorder
    
    
    case sorting_basic
    case sorting_zigzag
    case sorting_reverse_merge
    case sorting_bubble
    case quickSort
    case search
    case kadane
    case dynamicProgramming
    
    
    case combinatorics
    case permutations
    case binomialCoefficients
    case pigeonholePrinciple
    case inclusionExclusion
    case recurrenceRelations
    case generatingFunctions
    case probability
    case expectation
    

    case whileLoop
    case forLoop
    case ifStatement
    case bitwiseOperations
    case recursion
    case variablesMemory
    case functions
}

extension Question {
    
    static func sampleQuestionsAnalysis() -> [Question] {
        return [
            trigoQuestions.shuffled().first!,
            complexPlaneQuestions.shuffled().first!,
            darbouxQuestions.shuffled().first!,
            derivativeQuestions.shuffled().first!,
            sequenceQuestions.shuffled().first!,
            meanTheoremQuestions.shuffled().first!,
            TFIQuestions.shuffled().first!,
            TAFQuestions.shuffled().first!,
            fixedPointQuestions.shuffled().first!,
            convergenceQuestions.shuffled().first!,
            lhopitalQuestions.shuffled().first!,
            sandwichQuestions.shuffled().first!,
            taylorQuestions.shuffled().first!,
       
        ]
    }
    static func sampleQuestionsArrays() -> [Question] {
        return [
            insertionQuestions.shuffled().first!,
            mergesortQuestions.shuffled().first!,
            selectionQuestions.shuffled().first!,
            bubbleQuestions.shuffled().first!,
            DPquestions.shuffled().first!,
            searchQuestions.shuffled().first!,
            quicksortQuestions.shuffled().first!,
            kadaneQuestions.shuffled().first!,
        ]
    }
    
    static func sampleQuestionsGraphs() -> [Question] {
        return [
            dfsQuestions.shuffled().first!,
            bfsQuestions.shuffled().first!,
            primQuestions.shuffled().first!,
            kruskalQuestions.shuffled().first!,
            bellmanQuestion.shuffled().first!,
            djikistraQuestion.shuffled().first!,
        ]
    }
    
    static func sampleQuestionsDiscreteMaths() -> [Question] {
        return [
            combinatoricsQuestions.shuffled().first!,
            permutationsQuestions.shuffled().first!,
            binomialQuestions.shuffled().first!,
            pigeonholeQuestions.shuffled().first!,
            inclusionExclusionQuestions.shuffled().first!,
            recurrenceQuestions.shuffled().first!,
            probabilityQuestions.shuffled().first!,
            expectationQuestions.shuffled().first!,
        ]
    }
    
    static func sampleQuestionsLinearAlgebra() -> [Question] {
        return [
            matrixOperationsQuestions.shuffled().first!,
            determinantQuestions.shuffled().first!,
            vectorSpaceQuestions.shuffled().first!,
            linearTransformQuestions.shuffled().first!,
            //gramSchmidtQuestions.shuffled().first!,
            matrix3DQuestions.shuffled().first!,
        ]
    }
    
    static func sampleQuestionsProgrammingBasics() -> [Question] {
        return [
            variablesQuestions.shuffled().first!,
            ifElseQuestions.shuffled().first!,
            forLoopQuestions.shuffled().first!,
            whileLoopQuestions.shuffled().first!,
            functionQuestions.shuffled().first!,
            bitwiseQuestions.shuffled().first!,
        ]
    }
}


    

