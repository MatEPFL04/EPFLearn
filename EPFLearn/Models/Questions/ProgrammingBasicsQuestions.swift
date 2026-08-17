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
        text: "int x = 5;\nint y = x;\ny = 9;\nWhat is x after this code runs?",
        hint: "Step the view to the 'int t = m' line: primitives get their own box. Does writing to one touch the other?",
        options: ["5", "9", "14", "0"],
        correctIndex: 0,
        explanation: "For an int, 'int y = x' copies the value into a new box, so writing to y leaves x at 5. Arrays differ: 'int[] v = u' copies only the reference.",
        visualization: .variablesMemory
    ),
    Question(
        subject: .programmingBasics,
        text: "int[] u = {1, 2, 3};\nint[] v = u;\nv[0] = 9;\nWhat is v[1] after this code runs?",
        hint: "Run the 'shared' variant in the view and watch which cells change when one is written.",
        options: ["1", "2", "9", "0"],
        correctIndex: 1,
        explanation: "v[0] = 9 only overwrites the cell at index 0. u and v still share the exact same array, but index 1 was never touched, so it's still 2.",
        visualization: .variablesMemory
    ),
    Question(
        subject: .programmingBasics,
        text: "int[] u = {1, 2, 3};\nint[] v = u;\nu[2] = 7;\nWhat is v[2] after this code runs?",
        hint: "Select 'shared' in the picker: both arrows land on the same array. Follow either arrow and see what the write reaches.",
        options: ["3", "7", "2", "Error"],
        correctIndex: 1,
        explanation: "u and v point to the same array, so writing through u is just as visible through v. u[2] = 7 changes the one shared array, so v[2] is 7 too.",
        visualization: .variablesMemory
    ),
    Question(
        subject: .programmingBasics,
        text: "int[] u = {1, 2, 3};\nint[] v = {1, 2, 3};\nv[0] = 9;\nWhat is u[0] after this code runs?",
        hint: "Switch the view to 'independent': a second {…} draws a second array, so the two arrows no longer meet.",
        options: ["1", "9", "3", "Error"],
        correctIndex: 0,
        explanation: "Unlike v = u, writing 'int[] v = {1, 2, 3}' creates a brand-new, independent array. u and v never share memory here, so changing v[0] leaves u completely untouched at 1.",
        visualization: .variablesMemory
    ),
    Question(
        subject: .programmingBasics,
        text: "int[] u = {1, 2, 3};\nint[] v = u;\nv = new int[]{9, 9, 9};\nWhat is u[0] after this code runs?",
        hint: "Select 'shared' in the picker, then compare a write into a cell with re-pointing an arrow: only one of them changes what u sees.",
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
        hint: "Set the score slider to 75 in the view and watch which branch lights up, and which are skipped.",
        options: ["A", "B", "C", "Error"],
        correctIndex: 1,
        explanation: "score is 75, which is >= 70 but not >= 90, so the second condition is true and 'B' is printed.",
        visualization: .ifStatement
    ),
    Question(
        subject: .programmingBasics,
        text: "int score = 65;\nString grade;\nif (score >= 90) {\n  grade = \"A\";\n} else if (score >= 75) {\n  grade = \"B\";\n} else if (score >= 60) {\n  grade = \"C\";\n} else {\n  grade = \"F\";\n}\nWhat is the value of grade?",
        hint: "Slide the score down to 65 and watch the highlight walk down the chain until a test passes.",
        options: ["\"A\"", "\"B\"", "\"C\"", "\"F\""],
        correctIndex: 2,
        explanation: "score = 65 fails score >= 90 and score >= 75, but passes score >= 60, so grade becomes \"C\". The final else is never reached.",
        visualization: .ifStatement
    ),
    Question(
        subject: .programmingBasics,
        text: "What gets printed?\nint x = 10;\nif (x > 5) {\n  System.out.println(\"big\");\n} else if (x > 8) {\n  System.out.println(\"medium\");\n}",
        hint: "In the view, notice the chain stops at the first true test: the later conditions are never even evaluated.",
        options: ["big", "medium", "big and medium", "Nothing"],
        correctIndex: 0,
        explanation: "x > 5 is true, so \"big\" is printed and the chain stops there. The else-if is never even evaluated, even though x > 8 would also have been true.",
        visualization: .ifStatement
    ),
    Question(
        subject: .programmingBasics,
        text: "What gets printed?\nint x = 10;\nif (x > 5) {\n  System.out.println(\"big\");\n}\nif (x > 8) {\n  System.out.println(\"medium\");\n}",
        hint: "Set s = 10 and step through: the chain stops at the first test that passes, so nothing below it is even evaluated. Now ask what would change if each if stood on its own.",
        options: ["big", "medium", "big and medium", "Nothing"],
        correctIndex: 2,
        explanation: "Without else, both ifs are tested on their own, so both print. In the else-if version the first match ends the chain and only \"big\" appears.",
        visualization: .ifStatement
    ),
]

    static let forLoopQuestions: [Question] = [
    Question(
        subject: .programmingBasics,
        text: "int s = 0;\nfor (int i = 1; i < 10; i += 3) {\n  s += i;\n}\nWhat is s at the end?",
        hint: "Select 'one loop', set start = 1, i < 10, += 3, and step through: the tiles show exactly which values i takes.",
        options: ["12", "10", "22", "45"],
        correctIndex: 0,
        explanation: "i takes 1, 4, 7; the next one, 10, fails i < 10. So s = 1 + 4 + 7 = 12.",
        visualization: .forLoop
    ),
    Question(
        subject: .programmingBasics,
        text: "How many times does the body run?\nfor (int i = 3; i < 20; i += 4) {\n  System.out.println(i);\n}",
        hint: "Select 'one loop', set start = 3, i < 20, += 4, and count the filled tiles as you scrub the step slider.",
        options: ["4 times", "5 times", "6 times", "17 times"],
        correctIndex: 1,
        explanation: "i takes 3, 7, 11, 15, 19, then 23 fails i < 20: 5 passes. The step does not divide the range evenly, so count the values rather than dividing.",
        visualization: .forLoop
    ),
    Question(
        subject: .programmingBasics,
        text: "How many times does the loop body run?\nfor (int i = 5; i < 5; i++) {\n  System.out.println(i);\n}",
        hint: "Select 'one loop', set start = 5 and i < 5: watch whether the body line ever highlights.",
        options: ["0 times", "1 time", "5 times", "Infinite"],
        correctIndex: 0,
        explanation: "The condition i < 5 is checked before the first iteration. Since i already starts at 5, the condition is false from the very first check, so the body never executes.",
        visualization: .forLoop
    ),
    Question(
        subject: .programmingBasics,
        text: "How many times does println run?\nfor (int i = 0; i < 3; i++) {\n  for (int j = 0; j < 4; j++) {\n    System.out.println(i + j);\n  }\n}",
        hint: "Select 'nested' in the picker with i < 3, j < 4 and count the cells filled in one row, then all rows.",
        options: ["7", "12", "4", "3"],
        correctIndex: 1,
        explanation: "The inner loop runs 4 times for each of the 3 values of i, so 3 × 4 = 12. Nested loops multiply, which is why a doubly-nested loop over n elements costs n².",
        visualization: .forLoop
    ),
]

    static let whileLoopQuestions: [Question] = [
    Question(
        subject: .programmingBasics,
        text: "What is the value of count after this loop?\nint count = 0;\nwhile (count < 3) {\n  count++;\n}",
        hint: "Select 'c = c + 1' in the picker: the loop stops as soon as the test fails, so which is the first value of count that fails it?",
        options: ["2", "3", "4", "Infinite"],
        correctIndex: 1,
        explanation: "The loop stops when count becomes 3 (no longer < 3), so the final value is 3.",
        visualization: .whileLoop
    ),
    Question(
        subject: .programmingBasics,
        text: "int n = 8;\nint steps = 0;\nwhile (n > 1) {\n  n = n / 2;\n  steps++;\n}\nWhat is the value of steps when the loop ends?",
        hint: "Select 'v = v / 2' in the picker, set n = 8 and scrub: count how many times the body line highlights.",
        options: ["2", "3", "4", "8"],
        correctIndex: 1,
        explanation: "n goes 8 → 4 → 2 → 1, checking > 1 before each division. The body runs 3 times (for n = 8, n = 4, n = 2), so steps ends at 3.",
        visualization: .whileLoop
    ),
    Question(
        subject: .programmingBasics,
        text: "int n = 1;\nint steps = 0;\nwhile (n > 1) {\n  n = n / 2;\n  steps++;\n}\nWhat is the value of steps when this code finishes?",
        hint: "Select 'v = v / 2' in the picker, set n = 1 and scrub: does the body line ever light up?",
        options: ["0", "1", "2", "Infinite loop"],
        correctIndex: 0,
        explanation: "while checks n > 1 before running the body at all. Since n starts at 1, the check fails immediately and the body never executes, so steps stays 0.",
        visualization: .whileLoop
    ),
    Question(
        subject: .programmingBasics,
        text: "int n = 5;\nwhile (n > 0) {\n  System.out.println(n);\n}\nWhat happens when this code runs?",
        hint: "Run the 'no update' mode in the view: the check never turns false, so the step slider never reaches an end.",
        options: [
            "It prints 5 once, then stops",
            "It prints 5, 4, 3, 2, 1",
            "It prints 5 forever: the loop never ends",
            "It does not compile"
        ],
        correctIndex: 2,
        explanation: "The body never modifies n, so n > 0 stays true forever. A while loop only ends if its body makes the condition false: the missing n-- matters as much as the condition.",
        visualization: .whileLoop
    ),
]

    static let functionQuestions: [Question] = [
    Question(
        subject: .programmingBasics,
        text: "static int f(int a) {\n  return a + 1;\n}\nstatic int g(int a) {\n  return a * 2;\n}\nint r = g(f(3));\nWhat is the value of r?",
        hint: "Select 'int' in the picker and step through the nested call: the inner frame opens, returns a value, and only then the outer one uses it.",
        options: ["8", "7", "9", "12"],
        correctIndex: 0,
        explanation: "f(3) returns 4, and that returned value is what g receives: g(4) = 8. The two a's are unrelated boxes.",
        visualization: .functions
    ),
    Question(
        subject: .programmingBasics,
        text: "static int twice(int a) {\n  a = a * 2;\n  return a;\n}\nint a = 7;\nint b = twice(a);\nWhat is the value of a (the caller's variable) after this code runs?",
        hint: "Select 'int' in the picker and watch the caller's box while the parameter box is being written to.",
        options: ["7", "14", "21", "0"],
        correctIndex: 0,
        explanation: "twice(a) receives its own copy of 7 in a brand-new box. Doubling that copy to 14 never touches the caller's a, which stays 7 the whole time.",
        visualization: .functions
    ),
    Question(
        subject: .programmingBasics,
        text: "static int twice(int a) {\n  a = a * 2;\n  a = a + 100;\n  return a;\n}\nint a = 7;\nint b = twice(a);\nWhat is the value of b?",
        hint: "Select 'int' in the picker, step to the return line and read what leaves the frame, not what the caller still holds.",
        options: ["7", "14", "114", "107"],
        correctIndex: 2,
        explanation: "Inside twice, the parameter's copy goes 7 → 14 → 114, and return sends 114 back to the caller, so b = 114.",
        visualization: .functions
    ),
    Question(
        subject: .programmingBasics,
        text: "static void bump(int[] arr) {\n  arr[0] = 99;\n}\nint[] a = {1, 2, 3};\nbump(a);\nWhat is a[0] after this code runs?",
        hint: "Select 'int[]' in the picker: the parameter box holds an arrow, so both names reach the same cells.",
        options: ["1", "99", "0", "Error: an array cannot be passed to a method"],
        correctIndex: 1,
        explanation: "What gets copied into the parameter is the reference, so arr and a reach the same array and a[0] becomes 99. Reassigning arr itself would only repoint arr's own box.",
        visualization: .functions
    ),
]

    static let bitwiseQuestions: [Question] = [
    Question(
        subject: .programmingBasics,
        text: "In Java, which line sets the bit at position k of a to 1, leaving every other bit alone?",
        hint: "Turn on 'b = 1 << k' so b carries a single 1 at position k, then try each operator in turn. You want the one that leaves column k at 1 whatever a had there, and leaves every other column untouched.",
        options: ["int res = a | (1 << k)", "int res = a & (1 << k)", "int res = a ^ ~k", "int res = a + k"],
        correctIndex: 0,
        explanation: "1 << k is a single 1 at position k. x | 1 = 1 and x | 0 = x, so OR forces that one bit to 1 and leaves the rest untouched. The & version would instead clear every other bit.",
        visualization: .bitwiseOperations
    ),
    Question(
        subject: .programmingBasics,
        text: "What does the left shift operator (<<) do in Java?",
        hint: "Select '<<' in the operation picker and slide k: watch the value in the r chip against the value of a.",
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
        text: "a is 1100 in binary (12) and b is 1010 (10).\nWhat is a & b?",
        hint: "Select '&' in the operation picker and work the four columns out yourself: a 1 only where both rows carry one. Then tap them in and check.",
        options: ["1000 (8)", "1110 (14)", "0110 (6)", "0000 (0)"],
        correctIndex: 0,
        explanation: "& compares the two rows column by column and keeps a 1 only where both have one: 1100 & 1010 = 1000, which is 8. (| would give 1110 = 14, ^ would give 0110 = 6.)",
        visualization: .bitwiseOperations
    ),

    Question(
        subject: .programmingBasics,
        text: "In Java, what line of code flips the bit at position k in variable a (0 becomes 1, 1 becomes 0)?",
        hint: "Turn on 'b = 1 << k' and try each operator against both values of bit k of a. You want the one that sends 0 to 1 and 1 to 0 in that column, and leaves the rest alone.",
        options: ["int res = a ^ (1 << k)", "int res = a | (1 << k)", "int res = a & (-1 >> k)", "int res = ~a && (1 << k)"],
        correctIndex: 0,
        explanation: "x ^ 1 flips x and x ^ 0 leaves it, and 1 << k has a single 1 at position k, so only that bit flips. a | (1 << k) would only ever set the bit to 1, never back to 0.",
        visualization: .bitwiseOperations
    ),
    Question(
        subject: .programmingBasics,
        text: "Which expression is true exactly when bit k of a is 1?",
        hint: "Turn on 'b = 1 << k': the result is non-zero only when that one column survives.",
        options: [
            "(a & (1 << k)) != 0",
            "(a | (1 << k)) != 0",
            "(a ^ (1 << k)) != 0",
            "(a >> k) == 1"
        ],
        correctIndex: 0,
        explanation: "a & (1 << k) keeps bit k and zeroes the rest, so it is non-zero exactly when that bit was 1. a | (1 << k) is always non-zero, and (a >> k) == 1 also demands every bit above k be 0.",
        visualization: .bitwiseOperations
    ),
    Question(
        subject: .programmingBasics,
        text: "What does 'a >> 1' compute for a non-negative int a?",
        hint: "Select '>>' in the operation picker and compare the r chip with a as k grows.",
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
        text: "class Counter {\n  int count = 0;\n  void inc() { count++; }\n}\n\nCounter a = new Counter();\nCounter b = new Counter();\na.inc();\na.inc();\nb.inc();\nWhat is b.count?",
        hint: "Select 'two objects' in the picker and step past both 'new' lines: two instance boxes appear, each with its own count.",
        options: ["0", "1", "2", "3"],
        correctIndex: 1,
        explanation: "a and b are two independent instances, each with its own count field. a.inc() is called twice, so a.count becomes 2, but it never touches b. b.inc() is called once, so b.count = 1.",
        visualization: .classes
    ),
    Question(
        subject: .programmingBasics,
        text: "What does the 'new' keyword do when you write 'Counter a = new Counter();'?",
        hint: "Select 'two objects' in the picker and step from the top: nothing exists as an object until the first 'new' line runs.",
        options: [
            "It declares a variable named Counter",
            "It creates a new object, with its own copy of the fields",
            "It calls a static method on the Counter class",
            "It imports the Counter class"
        ],
        correctIndex: 1,
        explanation: "'new' allocates a fresh object following the class's blueprint, giving it its own independent storage for every field the class declares.",
        visualization: .classes
    ),
    Question(
        subject: .programmingBasics,
        text: "class Counter {\n  int count = 0;\n  void inc() { count++; }\n}\n\nCounter a = new Counter();\nCounter b = new Counter();\na.inc();\nInside inc(), which 'count' does count++ increment?",
        hint: "Select 'two objects' in the picker, step to an a.inc() call and see which instance box the highlighted method is acting on.",
        options: [
            "One count shared by every Counter that exists",
            "a.count: the field of the instance the call was made on",
            "A local variable that resets on every call",
            "Both a.count and b.count"
        ],
        correctIndex: 1,
        explanation: "'count' is shorthand for 'this.count', the field of the instance the method runs on. The call was a.inc(), so this = a and only a.count changes; b.count stays 0.",
        visualization: .classes
    ),
    Question(
        subject: .programmingBasics,
        text: "class Counter {\n  int count = 0;\n  void inc() { count++; }\n}\n\nCounter a = new Counter();\nCounter b = a;\na.inc();\na.inc();\nWhat is b.count?",
        hint: "Select 'one object, two names' in the picker and step past 'Counter b = a': only one 'new' ran, so there is a single instance box with both names on it.",
        options: ["0", "1", "2", "Error"],
        correctIndex: 2,
        explanation: "'new' ran once, so there is one object: 'Counter b = a' copies the reference, so a and b name the same instance and b.count is 2. Only a second 'new' would give b its own count.",
        visualization: .classes
    ),
]

    static let abstractionQuestions: [Question] = [
    Question(
        subject: .programmingBasics,
        text: "abstract class Shape {\n    abstract double area();\n}\nWhy can't you write 'Shape s = new Shape();'?",
        hint: "In the view, the abstract row has no implementation to point at, unlike the two concrete ones.",
        options: [
            "Shape has too many methods",
            "An abstract class can leave methods unimplemented, so it cannot be instantiated",
            "abstract is just a comment, this should actually compile",
            "Shape is misspelled"
        ],
        correctIndex: 1,
        explanation: "area() has no body, so Shape does not fully describe an object yet. Only a subclass that implements every abstract method can be created with new.",
        visualization: .abstraction
    ),
    Question(
        subject: .programmingBasics,
        text: "Circle and Square both extend Shape and each define their own area().\nShape[] shapes = { new Circle(2), new Square(3) };\nfor (Shape s : shapes) s.area();\nWhat happens when s.area() is called for each shape?",
        hint: "Step the view through the loop and watch which implementation lights up for each object in turn.",
        options: [
            "Shape's version, since s is declared as a Shape",
            "It runs the area() of the object's real class, Circle or Square",
            "It causes a compile error because Shape has no body for area()",
            "Both formulas are averaged together"
        ],
        correctIndex: 1,
        explanation: "Polymorphism: the loop only depends on Shape, but at runtime Java runs the real object's own area(): Circle's formula, then Square's.",
        visualization: .abstraction
    ),
    Question(
        subject: .programmingBasics,
        text: "What is the main benefit of coding against an abstract type like Shape, instead of writing separate code for Circle and Square everywhere?",
        hint: "In the view, add-a-shape means one new row; the calling code above it never changes.",
        options: [
            "It makes the program run faster",
            "The same loop works for any subclass of Shape, without a rewrite",
            "It removes the need to write area() at all",
            "It prevents any bugs in area()"
        ],
        correctIndex: 1,
        explanation: "Code written against Shape never needs to know the concrete subclass, so a new Triangle that implements area() plugs into existing loops unchanged.",
        visualization: .abstraction
    ),
    Question(
        subject: .programmingBasics,
        text: "Shape sh = new Circle(2);\nWhat determines which area() method actually runs when you call sh.area(): the declared type of sh, or the type of the object it refers to?",
        hint: "In the view, follow the arrow from the declared type to the object actually stored, then to the method that runs.",
        options: [
            "The declared type of the variable, Shape, so Shape's own area() runs",
            "The runtime type of the object sh points at, so Circle's area()",
            "Java picks whichever area() was compiled first",
            "Both versions run, and the results are added together"
        ],
        correctIndex: 1,
        explanation: "The declared type only controls what you may call; the object's real class decides which body runs, so one call site can resolve differently every time.",
        visualization: .abstraction
    ),
]

}
