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

enum Subject {
    case algebra, analysis, algorithm
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
    case DFS
    case BFS
    case sorting_basic
    case sorting_zigzag
    case sorting_reverse_merge
    case sorting_bubble
    case quickSort
    case search
    case kadane
    case dynamicProgramming
    case kruskal
    case prim
    case djikistra
    case bellmanford
    case topologicalorder
    case complexNumbers
    case trigo
}

// MARK: - Random, one question per theme

extension Question {
    
    static func sampleQuestions() -> [Question] {
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
            
            insertionQuestions.shuffled().first!,
            mergesortQuestions.shuffled().first!,
            selectionQuestions.shuffled().first!,
            bubbleQuestions.shuffled().first!,
            DPquestions.shuffled().first!,
            searchQuestions.shuffled().first!,
            quicksortQuestions.shuffled().first!,
            kadaneQuestions.shuffled().first!,
            
            dfsQuestions.shuffled().first!,
            bfsQuestions.shuffled().first!,
            primQuestions.shuffled().first!,
            kruskalQuestions.shuffled().first!,
            bellmanQuestion.shuffled().first!,
            djikistraQuestion.shuffled().first!,
            
           
        ]
    }
}


    

