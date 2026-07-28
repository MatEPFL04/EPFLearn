//
//  ProgrammingBasicsQuestions.swift
//  EPFLearn
//
//  Created on 22.07.2026.
//

import Foundation

extension Question {
    
    static let variablesQuestions: [Question] = [
    Question(
        subject: .programmingBasics,
        text: "What is the value of 'result' after executing this code?\nint x = 5;\nint y = 3;\nint result = x + y * 2;",
        hint: "Remember operator precedence: multiplication before addition",
        options: ["16", "11", "13", "10"],
        correctIndex: 1,
        explanation: "Multiplication has higher precedence than addition. So: y * 2 = 6, then x + 6 = 11",
        visualization: .variablesMemory
    ),
    Question(
        subject: .programmingBasics,
        text: "Which keyword is used to declare a constant in Java?",
        hint: "Constants cannot be changed after initialization",
        options: ["var", "let", "const", "final"],
        correctIndex: 3,
        explanation: "In Java, 'final' is used to declare constants, preventing reassignment after initialization.",
        visualization: .variablesMemory
    ),
]
    
    static let ifElseQuestions: [Question] = [
    Question(
        subject: .programmingBasics,
        text: "What will be printed?\nint score = 75;\nif (score >= 90) {\n  System.out.println(\"A\");\n} else if (score >= 70) {\n  System.out.println(\"B\");\n} else {\n  System.out.println(\"C\");\n}",
        hint: "Check conditions in order from top to bottom",
        options: ["A", "B", "C", "Error"],
        correctIndex: 1,
        explanation: "score is 75, which is >= 70 but not >= 90, so the second condition is true and 'B' is printed.",
        visualization: .ifStatement
    ),
    Question(
        subject: .programmingBasics,
        text: "In Java, what happens when the if condition is false?",
        hint: "Think about the control flow",
        options: [
            "The program crashes",
            "The else block executes",
            "Nothing happens",
            "The if block executes anyway"
        ],
        correctIndex: 1,
        explanation: "When the if condition evaluates to false, the program skips the if block and executes the else block.",
        visualization: .ifStatement
    ),
]
    
    static let forLoopQuestions: [Question] = [
    Question(
        subject: .programmingBasics,
        text: "How many times will this loop execute?\nfor (int i = 0; i < 5; i++) {\n  System.out.println(i);\n}",
        hint: "The loop continues while i < 5",
        options: ["4 times", "5 times", "6 times", "Infinite"],
        correctIndex: 1,
        explanation: "The loop executes for i = 0, 1, 2, 3, 4 (5 values), so it runs 5 times.",
        visualization: .forLoop
    ),
    Question(
        subject: .programmingBasics,
        text: "What is the final value of sum?\nint sum = 0;\nfor (int i = 1; i <= 3; i++) {\n  sum += i;\n}",
        hint: "Trace through each iteration",
        options: ["3", "6", "10", "0"],
        correctIndex: 1,
        explanation: "Loop iterations: sum = 0+1 = 1, then 1+2 = 3, then 3+3 = 6",
        visualization: .forLoop
    ),
]
    
    static let whileLoopQuestions: [Question] = [
    Question(
        subject: .programmingBasics,
        text: "What is the value of count after this loop?\nint count = 0;\nwhile (count < 3) {\n  count++;\n}",
        hint: "The loop continues while the condition is true",
        options: ["2", "3", "4", "Infinite"],
        correctIndex: 1,
        explanation: "The loop stops when count becomes 3 (no longer < 3), so the final value is 3.",
        visualization: .whileLoop
    ),
    Question(
        subject: .programmingBasics,
        text: "In Java, what's the main difference between for and while loops?",
        hint: "Think about when you know the number of iterations",
        options: [
            "No difference",
            "For loops are faster",
            "For loops are best when you know the iteration count",
            "While loops can't use variables"
        ],
        correctIndex: 2,
        explanation: "For loops are typically used when you know how many times to iterate, while loops are used when the number of iterations depends on a condition.",
        visualization: .whileLoop
    ),
]
    
    static let functionQuestions: [Question] = [
    Question(
        subject: .programmingBasics,
        text: "What will this method return?\npublic static int multiply(int a, int b) {\n  return a * b;\n}\nint result = multiply(4, 3);",
        hint: "Trace through the method with the given parameters",
        options: ["7", "12", "1", "0"],
        correctIndex: 1,
        explanation: "The method multiplies 4 * 3 = 12 and returns that value.",
        visualization: .functions
    ),
    Question(
        subject: .programmingBasics,
        text: "In Java, what keyword is used to send a value back from a method?",
        hint: "Think about how methods give results",
        options: ["send", "return", "output", "result"],
        correctIndex: 1,
        explanation: "The 'return' keyword is used to send a value back to the caller of the method.",
        visualization: .functions
    ),
]
    
    static let bitwiseQuestions: [Question] = [
    Question(
        subject: .programmingBasics,
        text: "In java, how can we effectively set to 0 eight consecutive bits within an int value (32 bits) starting with an offset of k (from the LSB) ?",
        hint: "How do we force bits to 0 ? Which operator do we use ?",
        options: ["int res = a & (~(0xFF << k))", "int res = a & (0xFFFF0000 >> k)", "int res = a & ((0xF >> k) & (0xF >> (k+1))) ", "int res = a & (1 - (2 <<k)) "],
        correctIndex: 0,
        explanation: "first option applies a mask with a number that has ones everywhere except 8 zeros at the desired positions" ,
        visualization: .bitwiseOperations
    ),
    Question(
        subject: .programmingBasics,
        text: "What does the left shift operator (<<) do in Java?",
        hint: "Think about the positional importance of a bit",
        options: [
            "Divides by 2",
            "Multiplies by 2 for each position",
            "Adds 2",
            "Subtracts 2"
        ],
        correctIndex: 1,
        explanation: "Left shift by 1 position multiplies the number by 2. For example: 5 << 1 = 10",
        visualization: .bitwiseOperations
    ),
    Question(
        subject: .programmingBasics,
        text: "What is the result of the following code: int res = a & ~(a ^ a)",
        hint: "Decompose the expression and finish by applying the & operator",
        options: [
            "res = a >> 1",
            "res = ~a ",
            "res = a ",
            "res = a & 0xFF"
        ],
        correctIndex: 1,
        explanation: "a ^ a = 0 and therefore the ~ creates a number that has only 1's, which is the identity mask for \"&\"",
        visualization: .bitwiseOperations
    ),
    
    Question(
        subject: .programmingBasics,
        text: "In Java, what line of code works for changing the bit from 0 to 1 or vice-versa at position k in variable a?",
        hint: "Try a certain b that does the job in the playground, how can we describe b?",
        options: ["int res = a^(1 << k)", "int res = a|(1 << k)", "int res = a & (-1 >> k)", "int res = ~a && (1 << k)"],
        correctIndex: 0,
        explanation: "Xor (^) is the right operator as if we already have a zero or 1 at a certain position, that bit is not flipped, otherwise it is.",
        visualization: .bitwiseOperations
    ),
]
    
}
