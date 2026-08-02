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
        text: "int[] u = {1, 2, 3};\nint[] v = u;\nv[0] = 9;\nWhat is v[1] after this code runs?",
        hint: "Only index 0 was ever written. Step through the view above and check whether the untouched cells of the shared array ever change.",
        options: ["1", "2", "9", "0"],
        correctIndex: 1,
        explanation: "v[0] = 9 only overwrites the cell at index 0. u and v still share the exact same array, but index 1 was never touched, so it's still 2.",
        visualization: .variablesMemory
    ),
    Question(
        subject: .programmingBasics,
        text: "int[] u = {1, 2, 3};\nint[] v = u;\nu[2] = 7;\nWhat is v[2] after this code runs?",
        hint: "It doesn't matter which name does the writing: u and v are two names for the same array. Trace the aliasing the same way the view above does, just through u instead of v.",
        options: ["3", "7", "2", "Error"],
        correctIndex: 1,
        explanation: "u and v point to the same array, so writing through u is just as visible through v. u[2] = 7 changes the one shared array, so v[2] is 7 too.",
        visualization: .variablesMemory
    ),
    Question(
        subject: .programmingBasics,
        text: "int[] u = {1, 2, 3};\nint[] v = {1, 2, 3};\nv[0] = 9;\nWhat is u[0] after this code runs?",
        hint: "This time v is built from its own {1, 2, 3} literal instead of v = u like in the view above. Does writing to v still reach u?",
        options: ["1", "9", "3", "Error"],
        correctIndex: 0,
        explanation: "Unlike v = u, writing 'int[] v = {1, 2, 3}' creates a brand-new, independent array. u and v never share memory here, so changing v[0] leaves u completely untouched at 1.",
        visualization: .variablesMemory
    ),
    Question(
        subject: .programmingBasics,
        text: "int[] u = {1, 2, 3};\nint[] v = u;\nv = new int[]{9, 9, 9};\nWhat is u[0] after this code runs?",
        hint: "This is different from writing into a cell like v[0] = 9 in the view above. Here v is reassigned to point at a whole new array. Does that ever reach back to u?",
        options: ["1", "9", "0", "Error"],
        correctIndex: 0,
        explanation: "v = new int[]{9, 9, 9} makes v point to a brand-new array; it does not change what u points to. u still refers to the original array, so u[0] is still 1.",
        visualization: .variablesMemory
    ),
]

    static let ifElseQuestions: [Question] = [
    Question(
        subject: .programmingBasics,
        text: "What will be printed?\nint score = 75;\nif (score >= 90) {\n  System.out.println(\"A\");\n} else if (score >= 70) {\n  System.out.println(\"B\");\n} else {\n  System.out.println(\"C\");\n}",
        hint: "Scrub the score slider in the view above to 75: it fails score >= 90 but passes score >= 70, so the second branch wins.",
        options: ["A", "B", "C", "Error"],
        correctIndex: 1,
        explanation: "score is 75, which is >= 70 but not >= 90, so the second condition is true and 'B' is printed.",
        visualization: .ifStatement
    ),
    Question(
        subject: .programmingBasics,
        text: "int score = 65;\nString grade;\nif (score >= 90) {\n  grade = \"A\";\n} else if (score >= 75) {\n  grade = \"B\";\n} else if (score >= 60) {\n  grade = \"C\";\n} else {\n  grade = \"F\";\n}\nWhat is the value of grade?",
        hint: "Scrub the score slider in the view above to 65: it fails the first two conditions but passes score >= 60, landing on grade C.",
        options: ["\"A\"", "\"B\"", "\"C\"", "\"F\""],
        correctIndex: 2,
        explanation: "score = 65 fails score >= 90 and score >= 75, but passes score >= 60, so grade becomes \"C\". The final else is never reached.",
        visualization: .ifStatement
    ),
    Question(
        subject: .programmingBasics,
        text: "What gets printed?\nint x = 10;\nif (x > 5) {\n  System.out.println(\"big\");\n} else if (x > 8) {\n  System.out.println(\"medium\");\n}",
        hint: "Once one branch of an if / else-if chain runs, the rest are skipped, even if their condition would also be true.",
        options: ["big", "medium", "big and medium", "Nothing"],
        correctIndex: 0,
        explanation: "x > 5 is true, so \"big\" is printed and the chain stops there. The else-if is never even evaluated, even though x > 8 would also have been true.",
        visualization: .ifStatement
    ),
]

    static let forLoopQuestions: [Question] = [
    Question(
        subject: .programmingBasics,
        text: "How many times will this loop execute?\nfor (int i = 0; i < 5; i++) {\n  System.out.println(i);\n}",
        hint: "Step through the loop in the view above and count how many times the body highlights before i < 5 fails.",
        options: ["4 times", "5 times", "6 times", "Infinite"],
        correctIndex: 1,
        explanation: "The loop executes for i = 0, 1, 2, 3, 4 (5 values), so it runs 5 times.",
        visualization: .forLoop
    ),
    Question(
        subject: .programmingBasics,
        text: "What is the final value of sum?\nint sum = 0;\nfor (int i = 1; i <= 3; i++) {\n  sum += i;\n}",
        hint: "This mirrors the practice program above. Step through it and add i into sum on each pass: 1, then 3, then 6.",
        options: ["3", "6", "10", "0"],
        correctIndex: 1,
        explanation: "Loop iterations: sum = 0+1 = 1, then 1+2 = 3, then 3+3 = 6",
        visualization: .forLoop
    ),
    Question(
        subject: .programmingBasics,
        text: "How many times does the loop body run?\nfor (int i = 5; i < 5; i++) {\n  System.out.println(i);\n}",
        hint: "Check the condition before assuming the loop runs at all: it's tested before the very first pass.",
        options: ["0 times", "1 time", "5 times", "Infinite"],
        correctIndex: 0,
        explanation: "The condition i < 5 is checked before the first iteration. Since i already starts at 5, the condition is false from the very first check, so the body never executes.",
        visualization: .forLoop
    ),
]

    static let whileLoopQuestions: [Question] = [
    Question(
        subject: .programmingBasics,
        text: "What is the value of count after this loop?\nint count = 0;\nwhile (count < 3) {\n  count++;\n}",
        hint: "Step through in the view above: count increases by 1 each pass until count < 3 fails. Watch the value the loop stops on, not the number of passes.",
        options: ["2", "3", "4", "Infinite"],
        correctIndex: 1,
        explanation: "The loop stops when count becomes 3 (no longer < 3), so the final value is 3.",
        visualization: .whileLoop
    ),
    Question(
        subject: .programmingBasics,
        text: "int n = 8;\nint steps = 0;\nwhile (n > 1) {\n  n = n / 2;\n  steps++;\n}\nWhat is the value of steps when the loop ends?",
        hint: "Scrub n to 8 in the view above and step through: n halves each pass (8, 4, 2, 1) and steps only counts the passes that actually run.",
        options: ["2", "3", "4", "8"],
        correctIndex: 1,
        explanation: "n goes 8 -> 4 -> 2 -> 1, checking > 1 before each division. The body runs 3 times (for n = 8, n = 4, n = 2), so steps ends at 3.",
        visualization: .whileLoop
    ),
    Question(
        subject: .programmingBasics,
        text: "int n = 1;\nint steps = 0;\nwhile (n > 1) {\n  n = n / 2;\n  steps++;\n}\nWhat is the value of steps when this code finishes?",
        hint: "Scrub n down to 1 in the view above: while checks its condition before the very first pass. Does the body ever get a chance to run?",
        options: ["0", "1", "2", "Infinite loop"],
        correctIndex: 0,
        explanation: "while checks n > 1 before running the body at all. Since n starts at 1, the check fails immediately and the body never executes, so steps stays 0.",
        visualization: .whileLoop
    ),
]

    static let functionQuestions: [Question] = [
    Question(
        subject: .programmingBasics,
        text: "What will this method return?\npublic static int multiply(int a, int b) {\n  return a * b;\n}\nint result = multiply(4, 3);",
        hint: "Substitute a = 4 and b = 3 into the method body and evaluate the return expression directly.",
        options: ["7", "12", "1", "0"],
        correctIndex: 1,
        explanation: "The method multiplies 4 * 3 = 12 and returns that value.",
        visualization: .functions
    ),
    Question(
        subject: .programmingBasics,
        text: "static int twice(int a) {\n  a = a * 2;\n  return a;\n}\nint a = 7;\nint b = twice(a);\nWhat is the value of a (the caller's variable) after this code runs?",
        hint: "Step through the view above: the parameter a gets its own box, separate from the caller's. Watch whether doubling the parameter's box ever changes the caller's box.",
        options: ["7", "14", "21", "0"],
        correctIndex: 0,
        explanation: "twice(a) receives its own copy of 7 in a brand-new box. Doubling that copy to 14 never touches the caller's a, which stays 7 the whole time.",
        visualization: .functions
    ),
    Question(
        subject: .programmingBasics,
        text: "static int twice(int a) {\n  a = a * 2;\n  a = a + 100;\n  return a;\n}\nint a = 7;\nint b = twice(a);\nWhat is the value of b?",
        hint: "Step through the view above to the return: follow the parameter's box through both lines (x2, then +100), then see what value crosses back to b.",
        options: ["7", "14", "114", "107"],
        correctIndex: 2,
        explanation: "Inside twice, the parameter's copy goes 7 -> 14 -> 114, and return sends 114 back to the caller, so b = 114.",
        visualization: .functions
    ),
]

    static let bitwiseQuestions: [Question] = [
    Question(
        subject: .programmingBasics,
        text: "In java, how can we effectively set to 0 eight consecutive bits within an int value (32 bits) starting with an offset of k (from the LSB) ?",
        hint: "Which operator forces bits to 0 no matter what they currently are, and how do you build a mask with exactly 8 zero bits sitting at offset k?",
        options: ["int res = a & (~(0xFF << k))", "int res = a & (0xFFFF0000 >> k)", "int res = a & ((0xF >> k) & (0xF >> (k+1))) ", "int res = a & (1 - (2 <<k)) "],
        correctIndex: 0,
        explanation: "first option applies a mask with a number that has ones everywhere except 8 zeros at the desired positions" ,
        visualization: .bitwiseOperations
    ),
    Question(
        subject: .programmingBasics,
        text: "What does the left shift operator (<<) do in Java?",
        hint: "Pick << in the view above, keep a couple of a's bits set to 1, and watch every 1 slide one column to the left as you shift.",
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
        hint: "a ^ a is always 0, no matter what a is. Work out what ~0 looks like in binary, then apply & with it.",
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
        hint: "Pick XOR in the view above and toggle a single bit of b: XORing with 1 flips a bit, XORing with 0 leaves it alone. Which mask does exactly that at position k?",
        options: ["int res = a^(1 << k)", "int res = a|(1 << k)", "int res = a & (-1 >> k)", "int res = ~a && (1 << k)"],
        correctIndex: 0,
        explanation: "Xor (^) is the right operator as if we already have a zero or 1 at a certain position, that bit is not flipped, otherwise it is.",
        visualization: .bitwiseOperations
    ),
    Question(
        subject: .programmingBasics,
        text: "What does 'a >> 1' compute for a non-negative int a?",
        hint: "Pick >> in the view above and watch every bit slide one column to the right, with a 0 filling in on the left.",
        options: [
            "a multiplied by 2",
            "a divided by 2 (integer division), every bit shifted right",
            "a divided by 1",
            "The bits of a reversed"
        ],
        correctIndex: 1,
        explanation: "Right shift by 1 moves every bit one position toward the least significant bit, which is equivalent to integer division by 2 for non-negative numbers.",
        visualization: .bitwiseOperations
    ),
]

    static let classQuestions: [Question] = [
    Question(
        subject: .programmingBasics,
        text: "Given:\nCounter a = new Counter();\nCounter b = new Counter();\na.inc();\na.inc();\nb.inc();\nWhat is b.count?",
        hint: "Step through the view above: a.inc() only ever touches a's box. Does it ever reach into b's?",
        options: ["0", "1", "2", "3"],
        correctIndex: 1,
        explanation: "a and b are two independent instances, each with its own count field. a.inc() is called twice, so a.count becomes 2, but it never touches b. b.inc() is called once, so b.count = 1.",
        visualization: .classes
    ),
    Question(
        subject: .programmingBasics,
        text: "What does the 'new' keyword do when you write 'Counter a = new Counter();'?",
        hint: "Before the first 'new' runs in the view above, there's no instance at all, only the dashed blueprint. What does 'new' actually create?",
        options: [
            "It declares a variable named Counter",
            "It creates a brand-new object in memory, with its own copy of the class's fields",
            "It calls a static method on the Counter class",
            "It imports the Counter class"
        ],
        correctIndex: 1,
        explanation: "'new' allocates a fresh object following the class's blueprint, giving it its own independent storage for every field the class declares.",
        visualization: .classes
    ),
    Question(
        subject: .programmingBasics,
        text: "Inside the method 'void inc() { count++; }', what does 'count' refer to?",
        hint: "The same inc() method runs for both a and b in the view above. Watch the 'this' tag jump between them. What decides which instance's count field it touches?",
        options: [
            "A single value shared by every Counter that ever exists",
            "The count field of whichever instance the method was called on",
            "A local variable that resets on every call",
            "The Counter class itself"
        ],
        correctIndex: 1,
        explanation: "'count' is shorthand for 'this.count': the field belonging to the specific instance the method runs on. That is why a.inc() only ever changes a's count, never b's.",
        visualization: .classes
    ),
    Question(
        subject: .programmingBasics,
        text: "Why can 'a' and 'b' hold different values of count even though they were created from the exact same class?",
        hint: "Watch the two instance boxes in the view above stay independent the whole time. What does each separate 'new Counter()' actually allocate?",
        options: [
            "Because Java classes are mutable",
            "Because a and b are two separate objects, each with their own memory for their fields",
            "Because count is declared as static",
            "They can't: this would be a compile error"
        ],
        correctIndex: 1,
        explanation: "A class defines what fields an object has, not one shared storage location for them. Every object created with 'new' gets its own memory, so two instances of the same class can hold completely independent state.",
        visualization: .classes
    ),
]

    static let abstractionQuestions: [Question] = [
    Question(
        subject: .programmingBasics,
        text: "abstract class Shape {\n    abstract double area();\n}\nWhy can't you write 'Shape s = new Shape();'?",
        hint: "abstract area() has no body in the code above. If Java allowed 'new Shape()', what would s.area() even run?",
        options: [
            "Shape has too many methods",
            "An abstract class can leave methods unimplemented, so it can't be instantiated on its own",
            "abstract is just a comment, this should actually compile",
            "Shape is misspelled"
        ],
        correctIndex: 1,
        explanation: "An abstract class may declare methods (like area()) with no body, so it doesn't fully describe an object yet. Java refuses to instantiate it directly; only a concrete subclass that implements every abstract method can be created with new.",
        visualization: .abstraction
    ),
    Question(
        subject: .programmingBasics,
        text: "Circle and Square both extend Shape and each define their own area().\nShape[] shapes = { new Circle(2), new Square(3) };\nfor (Shape s : shapes) s.area();\nWhat happens when s.area() is called for each shape?",
        hint: "Step through the view above: the call site sh.area() never changes, but watch which concrete method the arrow resolves to for each shape.",
        options: [
            "It always runs Shape's version, since s is declared as type Shape",
            "It runs the area() implementation that belongs to the object's real class: Circle's or Square's",
            "It causes a compile error because Shape has no body for area()",
            "Both formulas are averaged together"
        ],
        correctIndex: 1,
        explanation: "This is polymorphism through abstraction: the code only depends on the abstract Shape interface, but at runtime Java calls the actual object's own area(): Circle's formula for the Circle, Square's for the Square.",
        visualization: .abstraction
    ),
    Question(
        subject: .programmingBasics,
        text: "What is the main benefit of coding against an abstract type like Shape, instead of writing separate code for Circle and Square everywhere?",
        hint: "In the view above, the same call site works for both Circle and Square without any change to it. What would adding a third subclass require you to touch?",
        options: [
            "It makes the program run faster",
            "The same loop or method works for any current or future subclass of Shape, without being rewritten",
            "It removes the need to write area() at all",
            "It prevents any bugs in area()"
        ],
        correctIndex: 1,
        explanation: "Code written against the abstraction (Shape) doesn't need to know which concrete subclass it's dealing with. Adding a new Triangle class that extends Shape and implements area() plugs right into existing loops with no changes.",
        visualization: .abstraction
    ),
    Question(
        subject: .programmingBasics,
        text: "Shape sh = new Circle(2);\nWhat determines which area() method actually runs when you call sh.area(): the declared type of sh, or the type of the object it refers to?",
        hint: "Step through the view above: sh.area() on the left never changes, but the box on the right flips between Circle.area() and Square.area(). What decides which one it resolves to?",
        options: [
            "The declared type of the variable, Shape, so Shape's own area() runs",
            "The type of the actual object sh refers to at runtime: here, Circle's area()",
            "Java picks whichever area() was compiled first",
            "Both versions run, and the results are added together"
        ],
        correctIndex: 1,
        explanation: "The variable's declared type (Shape) only controls what you're allowed to call; it says area() must exist. Which body actually runs is decided by the real, runtime class of the object, which is why the exact same call site can resolve differently every time.",
        visualization: .abstraction
    ),
]

}
