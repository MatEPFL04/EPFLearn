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
    
    case darboux
    case derivative
    case sequence
    case meanTheorem
    case TFI
    case TAF
    case fixedPoint
    
    case taylor
    case convergence
    case lhopital
    case sandwich
    case complexNumbers
    case trigo
    case bijectivity
    
    
    case matrixOperations
    case determinant
    case vectorSpaces
    case linearTransformations
    case gaussianElimination
    case ker
    case image
    
    
    case combinatorics
    case permutations
    case binomialCoefficients
    case pigeonholePrinciple
    case inclusionExclusion
    case recurrenceRelations
    case generatingFunctions
    case probability
    case expectation
    case setOperations
    case propositionalLogic
    

    case whileLoop
    case forLoop
    case ifStatement
    case bitwiseOperations
    case recursion
    case variablesMemory
    case functions
    
    
    case DFS
    case BFS
    case kruskal
    case prim
    case djikistra
    case bellmanford
    case topologicalorder
    
    
    case sorting
    case quickSort
    case search
    case kadane
    case dynamicProgramming
    
 
}

extension Question {
    
    static func sampleQuestionsAnalysis() -> [Question] {
        let banks = [
            trigoQuestions,complexPlaneQuestions,darbouxQuestions,bijectivityQuestions,
            derivativeQuestions,sequenceQuestions,meanTheoremQuestions,TFIQuestions,TAFQuestions,
            fixedPointQuestions,convergenceQuestions,lhopitalQuestions,sandwichQuestions,taylorQuestions
        ]
        return banks.map { $0.shuffled().first! }.shuffled()
        
    }
    
    
    static func sampleQuestionsLinearAlgebra() -> [Question] {
        let banks = [
            determinantQuestions,vectorSpaceQuestions,gaussQuestions,imagesQuestions,matrix3DQuestions, matrixShapeQuestions
        ]
        return banks.map { $0.shuffled().first! }.shuffled()
        
    }
    static func sampleQuestionsArrays() -> [Question] {
        let banks = [
            insertionQuestions,
            mergesortQuestions,
            selectionQuestions,
            bubbleQuestions,
            DPquestions,
            searchQuestions,
            quicksortQuestions,
            kadaneQuestions
        ]
        return banks.map { $0.shuffled().first! }.shuffled()
    }
    
    static func sampleQuestionsGraphs() -> [Question] {
        
        let banks = [
            dfsQuestions,
            bfsQuestions,
            primQuestions,
            kruskalQuestions,
            bellmanQuestion,
            djikistraQuestion
        ]
        return banks.map { $0.shuffled().first! }.shuffled()
            
    }
    
    static func sampleQuestionsDiscreteMaths() -> [Question] {
        let banks = [
            combinatoricsQuestions, permutationsQuestions, binomialQuestions,
            pigeonholeQuestions, setOperationsQuestions,
            recurrenceQuestions, closedFormQuestions, probabilityQuestions,
            expectationQuestions, propositionalLogicQuestions,
        ]
        return banks.map { $0.shuffled().first! }.shuffled()
    }
    
    
    static func sampleQuestionsProgrammingBasics() -> [Question] {
        
        let banks = [
            variablesQuestions,ifElseQuestions,forLoopQuestions,whileLoopQuestions,functionQuestions,bitwiseQuestions
        ]
        return banks.map { $0.shuffled().first! }.shuffled()
    }
}


    

