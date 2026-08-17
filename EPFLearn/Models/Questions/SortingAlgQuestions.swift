//
//  Analysis.swift
//  EPFLearn
//
//  Created by Mat on 06.07.2026.
//

extension Question {
    
    static let insertionQuestions: [Question] = [
        Question(
            subject: .arrays,
            text: "Consider the array [1, 2, 3, …, n/2, n/2, …, 3, 2, 1] (increasing then decreasing, an 'organ pipe'). What is insertion sort's running time?",
            hint: "Build the organ-pipe shape in the view and step insertion sort: the first half costs nothing, the second explodes.",
            options: ["Θ(n)", "Θ(n log n)", "Θ(n²)", "Θ(n √n)"],
            correctIndex: 2,
            explanation: "The ascending half is free, but the descending half of length n/2 is reverse-sorted, giving ≈ (n/2)²/2 = Θ(n²) inversions. A sorted prefix never rescues insertion sort if the suffix is adversarial.",
            visualization: .sorting
        ),
        Question(
            subject: .arrays,
            text: "What is the invariant that makes insertion sort correct?",
            hint: "Step insertion sort and pause between passes: describe what is always true of the left part of the array.",
            options: [
                "Before placing an element at index j, 1 ≤ j ≤ n−1, A[0..j−1] is sorted",
                "A[0..j−1] is sorted at any given point in time",
                "Elements in A[j..n−1] will stay at their position",
                "Once an element A[j] is placed correctly, it never moves again"
            ],
            correctIndex: 0,
            explanation: "Initialization: A[0] is trivially sorted. At the end of each iteration, A[j] is correctly inserted, and the new array A[0..j] is sorted.",
            visualization: .sorting
        ),
        Question(
            subject: .arrays,
            text: "Which statement about insertion sort is false?",
            hint: "Select 'Insertion' and run it on 'Sorted', then on 'Reversed', and compare the step counts.",
            options: [
                "The algorithm runs in Θ(n) time on an already sorted array",
                "There exist instances where insertion sort's running time is Ω(n)",
                "Merge sort can be worse (slower) than insertion sort on some instances",
                "Having a sorted subarray of length ≥ n/2 somewhere guarantees a running time of O(n)"
            ],
            correctIndex: 3,
            explanation: "If we use \"Rotated\" and a disorder of ~n/2, we can invalidate option 3, as the running time is clearly quadratic",
            visualization: .sorting
        ),
        Question(
            subject: .arrays,
            text: "An array is built by taking a sorted array of n elements and swapping each element at an even index with its immediate right neighbor. What is insertion sort's running time on it?",
            hint: "Build the zigzag shape in the view and step through: count how far each element has to travel back.",
            options: ["Θ(n)", "Θ(n log n)", "Θ(n²)", "Θ(n √n)"],
            correctIndex: 0,
            explanation: "Each adjacent swap creates exactly one inversion, and there are n/2 of them, so Θ(n) inversions total. Insertion sort runs in Θ(n + inversions) = Θ(n). It looks shuffled but every element is at most one slot from home, the visualization shows each element settling in a single shift.",
            visualization: .sorting
        ),
    ]

    static let mergesortQuestions: [Question] = [
        Question(
            subject: .arrays,
            text: "Right before the last two calls to the merge function, what is the minimum number of sorted subarrays that exist within the array?",
            hint: "Select 'Merge' with 'Random' and step back a couple of frames from the end: count the sorted blocks still separate.",
            options: ["1", "2", "3", "4"],
            correctIndex: 2,
            explanation: "Right before the second-to-last call, the indices up to the middle will be sorted.",
            visualization: .sorting
        ),
        Question(
            subject: .arrays,
            text: "Merge sort has fully sorted the left half but hasn't processed the right half yet. In the worst case, how many sorted runs (maximal sorted subarrays) can the array contain at this moment?",
            hint: "Select 'Merge' with 'Reversed' and stop the slider halfway: count the sorted blocks on screen.",
            options: ["2", "n/2", "n/2 + 1", "n"],
            correctIndex: 2,
            explanation: "The sorted left half is 1 run. The right half is still in its original order: in the worst case (strictly decreasing) every element is its own run of length 1, giving n/2 runs. Total = n/2 + 1. The minimum, by contrast, would be 2 if the right half happened to already be sorted.",
            visualization: .sorting
        ),
        Question(
            subject: .arrays,
            text: "The very last call to merge in merge sort combines how many sorted subarrays, and of what sizes?",
            hint: "Step merge sort to its final frame and look at the two blocks being combined.",
            options: [
                "n subarrays of size 1",
                "Two subarrays, each about n/2, both already sorted",
                "Two subarrays of sizes 1 and n−1",
                "log n subarrays"
            ],
            correctIndex: 1,
            explanation: "The final merge combines the two fully sorted halves of size ≈ n/2 into the complete sorted array. All the work below just produced these two sorted halves.",
            visualization: .sorting
        ),
        Question(
            subject: .arrays,
            text: "When merging two sorted halves of total length n, what is the maximum number of comparisons the merge step can make?",
            hint: "Select 'Merge' with 'Organ pipe' and watch the comparison counter during the last merge.",
            options: ["n/2", "n − 1", "n log n", "n²"],
            correctIndex: 1,
            explanation: "Each comparison places one element; the very last element needs no comparison (the other side is already empty). The worst case is when the two halves interleave perfectly: n−1 comparisons. If one half lies entirely below the other, its remaining elements are copied for free.",
            visualization: .sorting
        ),
    ]

    static let quicksortQuestions: [Question] = [
        Question(
            subject: .arrays,
            text: "On an array of n identical elements, how does quicksort behave?",
            hint: "Set the array so all values match and step quicksort: watch how the partition splits them.",
            options: [
                "Θ(n), there is nothing to sort",
                "Θ(n log n), partitions stay balanced",
                "Θ(n²), every partition is maximally unbalanced",
                "It depends on the pivot choice"
            ],
            correctIndex: 2,
            explanation: "All elements are ≤ pivot, so they all fall on one side: a 0 / (n−1) split at every level, just like a sorted array. Θ(n²). Duplicate-heavy inputs are a hidden worst case unless you use three-way partitioning.",
            visualization: .quickSort
        ),
        Question(
            subject: .arrays,
            text: "On a reverse-sorted array [n, n−1, …, 2, 1] using the last element as pivot, what is the running time of quicksort?",
            hint: "Select 'Reversed' and watch the size of the two sides after the first partition.",
            options: [
                "Θ(n log n), reverse order balances the splits",
                "Θ(n²), each partition peels off only the pivot",
                "Θ(n), it's already almost sorted",
                "Faster than on a sorted array"
            ],
            correctIndex: 1,
            explanation: "The last element of a reverse-sorted array is the minimum, so everything goes to the other side: a 0 / (n−1) split, depth n, Θ(n²). Sorted and reverse-sorted are both worst cases for a last-element pivot.",
            visualization: .quickSort
        ),
        Question(
            subject: .arrays,
            text: "You have a uniformely shuffled array. With the last element as pivot, what is the expected running time?",
            hint: "Compare the random panel with the structured one in the view: watch how the step counts differ.",
            options: [
                "Θ(n²), last-element pivot is always bad",
                "Θ(n log n) expected: a random pivot usually splits well",
                "Θ(n), no comparisons needed",
                "Θ(n √n)"
            ],
            correctIndex: 1,
            explanation: "The last-element pivot only degenerates on ordered input. On a shuffled array the last element is a random value, so partitions are balanced in expectation: Θ(n log n). The danger of a last-element pivot is sorted data, not data in general.",
            visualization: .quickSort
        ),
        Question(
            subject: .arrays,
            text: "An array is sorted except for its last element, which is the smallest value. Using the last element as pivot, what happens on the first partition?",
            hint: "Set the smallest value at the end and step one partition: count how many elements land on each side.",
            options: [
                "It splits cleanly in half",
                "Every other element is larger, so they all go to one side: 0/(n−1) split",
                "Nothing moves, the array is already sorted",
                "The pivot ends up in the middle"
            ],
            correctIndex: 1,
            explanation: "Because the pivot is the minimum, all n−1 other elements are greater and pile onto one side. The first partition is maximally unbalanced, marking the start of the Θ(n²) degeneration, even though the array looked 'almost sorted'.",
            visualization: .quickSort
        ),
    ]

    static let searchQuestions: [Question] = [
        Question(
            subject: .arrays,
            text: "You receive an unsorted array and must answer many search queries on it. You decide to sort it once, then binary search each query. For a single query on a one-time array, is this ever worth it?",
            hint: "Compare the cost of sorting once with the cost of the single scan it would save.",
            options: [
                "Yes, binary search is always faster than linear",
                "No: sorting costs Θ(n log n), a single linear scan only Θ(n)",
                "Yes, because sorting in Θ(n log n) is the fastest we can do",
                "It depends on the target value"
            ],
            correctIndex: 1,
            explanation: "Binary search needs sorted input. Paying Θ(n log n) to sort, then Θ(log n) to search, costs more than a single Θ(n) linear scan. Sorting only pays off when amortized over many queries. For one query, just scan.",
            visualization: .search
        ),
        Question(
            subject: .arrays,
            text: "In the worst case, how many elements can binary search still possibly examine after it has already made k comparisons on an array of size n?",
            hint: "Step the binary panel and watch the highlighted region halve at every comparison.",
            options: ["n − k", "n / 2^k", "n / k", "k"],
            correctIndex: 1,
            explanation: "Every comparison discards half the window, so after k steps at most n/2^k candidates remain.",
            visualization: .search
        ),
        Question(
            subject: .arrays,
            text: "On an array of 1000 sorted elements, what is the maximum number of comparisons binary search can make before concluding the target is absent?",
            hint: "Set the array to its largest size and step the binary panel to the end: count the comparisons it needed.",
            options: ["About 10", "About 100", "About 500", "About 1000"],
            correctIndex: 0,
            explanation: "log₂(1000) ≈ 10, so at most ~10 comparisons even on a failed search. A linear scan would need all 1000. The gap between the two counters on the panels is exactly this.",
            visualization: .search
        ),
        Question(
            subject: .arrays,
            text: "An array is 'k-sorted': every element is at most k positions away from its sorted location. In terms of n and k, what is insertion sort's running time?",
            hint: "Build the k-sorted shape with a small k and step insertion sort: watch how far each element shifts back.",
            options: ["Θ(n²) always", "Θ(n·k)", "Θ(n + k)", "Θ(n log k)"],
            correctIndex: 1,
            explanation: "Each element travels at most k positions, so Θ(n·k) total. At k=1 it's linear (the zigzag case), at k=n it degrades to Θ(n²). This single parameter k spans the whole range.",
            visualization: .sorting
        ),
    ]

    static let kadaneQuestions: [Question] = [
        Question(
            subject: .arrays,
            text: "On an array where every element is negative, what does Kadane's algorithm return as the maximum subarray sum?",
            hint: "A subarray must hold at least one element, and every element hurts. Which single one hurts least?",
            options: [
                "0, the empty subarray",
                "The single least-negative element",
                "The sum of all elements",
                "Undefined, it crashes"
            ],
            correctIndex: 1,
            explanation: "If the empty subarray isn't allowed, the best you can do with all negatives is the single largest (least negative) element. Kadane handles this by tracking the best sum seen, which never turns positive but settles on that one element.",
            visualization: .kadane
        ),
        Question(
            subject: .arrays,
            text: "A student claims Kadane also finds the maximum-product contiguous subarray, just by replacing '+' with '×' and resetting whenever the running product drops below 1. What's wrong with this?",
            hint: "Watch the running value in the view reset on a negative element, and ask whether a product would behave the same.",
            options: [
                "Nothing, the analogy is exact",
                "Two negatives make a positive, so the minimum product has to be tracked as well",
                "It only fails on arrays with zeros",
                "It works but runs in Θ(n²)"
            ],
            correctIndex: 1,
            explanation: "On [−2, 3, −4] the best product is the whole array: (−2)·3·(−4) = 24. A negative running product isn't worthless, since a later negative can flip it to a large positive. So max-product needs to track the minimum product too, since min×negative can become the new max. Kadane's single-value reset doesn't carry over.",
            visualization: .kadane
        ),
        Question(
            subject: .arrays,
            text: "A student adds a large constant C to every element, runs Kadane, then subtracts C from the result. Does this recover the correct max subarray sum?",
            hint: "Adding C to every element adds C once per element taken, so a long window gains more than a short one.",
            options: [
                "Yes, shifting doesn't affect the result",
                "No: adding C rewards longer subarrays, so the winner can change",
                "Yes, but only if C > 0",
                "Yes, and the winning range is the same as before adding C"
            ],
            correctIndex: 1,
            explanation: "The maximizing subarray can change entirely. Max subarray sum isn't invariant under additive shifts.",
            visualization: .kadane
        ),
        Question(
            subject: .arrays,
            text: "Kadane's 'best ending at j' value is computed as max(a[j], best_ending_at_{j−1} + a[j]). A student simplifies it to just best_ending_at_{j−1} + a[j]. When does this give the wrong answer?",
            hint: "Watch the moment the running sum resets in the view, and ask what would happen if it could not.",
            options: [
                "Never, the two are equivalent",
                "Whenever best_{j−1} is negative: the simplified version keeps dragging a bad prefix instead of restarting at a[j]",
                "Only on positive arrays",
                "Only at index 0"
            ],
            correctIndex: 1,
            explanation: "The max(a[j], …) is exactly the restart decision. Dropping it forces every element to inherit the previous (possibly very negative) sum, so the window never resets: it degenerates into a single running total, not Kadane.",
            visualization: .kadane
        ),
        Question(
            subject: .arrays,
            text: "Kadane returns sum 6 on some array. You now multiply every element by −1. Is the new answer simply −6?",
            hint: "Use the offset slider to push elements negative and compare which subarray the view then picks out.",
            options: [
                "Yes, the answer becomes −6",
                "No: it becomes minus the smallest sum of the original, usually not −6",
                "Yes, but only if all elements were positive",
                "No, it stays 6"
            ],
            correctIndex: 1,
            explanation: "Negating turns max-subarray into min-subarray of the original array. The minimum-sum subarray has no fixed relation to the maximum one, so the new answer is −(min subarray sum), not −6. Assuming symmetry is the trap.",
            visualization: .kadane
        ),
    ]

    static let bubbleQuestions: [Question] = [
        Question(
            subject: .arrays,
            text: "Bubble sort with an early-exit flag (stop if a full pass makes no swaps) runs on an already-sorted array. How many swaps, comparisons, and passes?",
            hint: "The flag stops the sort after a pass that swaps nothing. On sorted input, which pass is that?",
            options: [
                "0 swaps, n comparisons, 1 pass",
                "0 swaps, log n comparisons, n passes",
                "n swaps, n comparisons, 1 pass",
                "n² swaps, n/2 comparisons, n passes"
            ],
            correctIndex: 0,
            explanation: "One pass finds no inversions, the flag stays false, and the algorithm stops. So 0 swaps and exactly 1 pass: the optimized bubble sort is Θ(n) on sorted input.",
            visualization: .sorting
        ),
        Question(
            subject: .arrays,
            text: "An array is sorted except the smallest element sits at the very end: [2, 3, 4, …, n, 1]. With left-to-right bubble sort, how many swaps and comparisons are needed to sort it?",
            hint: "Build the rotated shape so the smallest value sits last and step bubble sort, counting passes.",
            options: [
                "n swaps, Θ(n) comparisons",
                "n swaps, Θ(n²) comparisons",
                "n − 1 swaps, Θ(n²) comparisons",
                "n − 1 swaps, Θ(n) comparisons"
            ],
            correctIndex: 2,
            explanation: "Bubble sort only moves a left-bound element one step per pass, so the 1 needs n−1 swaps to crawl to the front. A single badly-placed small element forces near-worst-case behavior.",
            visualization: .sorting
        ),
        Question(
            subject: .arrays,
            text: "You need to sort records where comparing two keys is cheap but moving a record is very expensive (large objects). Between selection sort and bubble sort, which minimizes moves?",
            hint: "Run 'Bubble' and then 'Selection' on the same shape and compare the swap counters, not the comparisons.",
            options: [
                "Bubble sort, it makes fewer moves",
                "Selection sort: at most n−1 swaps total, regardless of input",
                "They make the same number of moves",
                "Bubble sort, it makes Θ(n) moves on average"
            ],
            correctIndex: 1,
            explanation: "Selection sort performs at most n−1 swaps (one per position), while bubble sort can do up to Θ(n²) swaps. When writes dominate cost, selection wins despite both being Θ(n²) in comparisons.",
            visualization: .sorting
        ),
        Question(
            subject: .arrays,
            text: "Bubble sort on [1, 2, 3, …, n−1, 0] (sorted, but 0 stuck at the end) versus [n−1, 0, 1, 2, …, n−2] (max stuck at the front). Which needs more passes?",
            hint: "Compare the two rotated shapes in the view and count the passes each one needs.",
            options: [
                "The max-at-front array needs more passes",
                "The 0-at-end array needs ≈ n passes; max-at-front needs ≈ 1",
                "Both need the same number of passes",
                "Both need n² passes"
            ],
            correctIndex: 1,
            explanation: "The 0 at the end moves left only one slot per pass → ≈ n passes. The max at the front bubbles fully to the right in one pass, leaving a sorted array. Identical-looking single-element displacements, wildly different costs, bubble sort is directionally asymmetric.",
            visualization: .sorting
        ),
    ]

    static let selectionQuestions: [Question] = [
        Question(
            subject: .arrays,
            text: "Selection sort runs on a reverse-sorted array [n, n−1, …, 2, 1]. How many swaps and comparisons?",
            hint: "Select 'Selection' with 'Reversed' and watch the comparison counter, then the swap counter.",
            options: [
                "Θ(n²) comparisons, n−1 swaps",
                "Θ(n²) comparisons, about n/2 swaps",
                "Θ(n) comparisons, n − 1 swaps",
                "Θ(n²) comparisons, Θ(n²) swaps"
            ],
            correctIndex: 1,
            explanation: "Comparisons are always Θ(n²). For swaps on a reversed array, each swap places both the minimum and (often) its mirror simultaneously, so only about n/2 swaps are needed, not n−1. A nice case where the swap count is even lower than the generic bound.",
            visualization: .sorting
        ),
        Question(
            subject: .arrays,
            text: "Selection sort runs on an already-sorted array. How many comparisons and how many swaps does it make?",
            hint: "Select 'Selection' and 'Sorted', then read both counters at the end.",
            options: [
                "Θ(n) comparisons, 0 swaps",
                "Θ(n²) comparisons, 0 swaps",
                "Θ(n) comparisons, n swaps",
                "Θ(n²) comparisons, n swaps"
            ],
            correctIndex: 1,
            explanation: "Selection sort always scans the whole unsorted part to find the minimum: Θ(n²) comparisons even on sorted input. But the minimum is always already in place, so 0 swaps. It never adapts to order the comparisons are unavoidable.",
            visualization: .sorting
        ),
        Question(
            subject: .arrays,
            text: "You want a sort that makes at most n−1 swaps no matter the input, because writing to memory is costly. Does selection sort guarantee this, and why?",
            hint: "Step selection sort and count how many swaps happen inside a single outer pass.",
            options: [
                "No, it can swap Θ(n²) times",
                "Yes: at most one swap per position, so n − 1 at most, whatever the input",
                "Only on sorted input",
                "Only if the array has no duplicates"
            ],
            correctIndex: 1,
            explanation: "Selection sort swaps the found minimum into place at most once per outer iteration, so at most n−1 swaps ever, regardless of order. That write-minimal guarantee is its main practical advantage over bubble or insertion sort.",
            visualization: .sorting
        ),
        Question(
            subject: .arrays,
            text: "An array is already sorted except the largest element sits at the front: [n, 1, 2, 3, …, n−1]. How many swaps does selection sort make?",
            hint: "Use the rotated shape with the largest value in front and step selection sort, counting the swaps.",
            options: [
                "1 swap",
                "About n−1 swaps as n gets dragged along",
                "0 swaps, it's nearly sorted",
                "n² swaps"
            ],
            correctIndex: 1,
            explanation: "The first swap puts 1 in front but throws n into position 1. Each subsequent pass then has to move n further right one slot at a time, costing a swap nearly every pass, about n−1 total. A single misplaced large value is surprisingly expensive in swaps for selection sort.",
            visualization: .sorting
        ),
    ]

    static let DPquestions: [Question] = [
        Question(
            subject: .arrays,
            text: "On the call tree of fib(6), how many times is fib(2) recomputed?",
            hint: "Set n = 6 in non-memoised mode and count the nodes labelled fib(2) in the tree.",
            options: ["3 times", "4 times", "5 times", "8 times"],
            correctIndex: 2,
            explanation: "The number of occurrences of fib(k) in the call tree of fib(n) follows Fibonacci itself: fib(2) appears fib(6−2+1) = fib(5) = 5 times. On the graph, the five nodes of this color stand out, and each recomputes the exact same subtree. This redundancy, not the size of the numbers, is what makes the algorithm exponential. For comparison, fib(1) is recomputed fib(6) = 8 times.",
            visualization: .dynamicProgramming
        ),
        Question(
            subject: .arrays,
            text: "With memoization, how many actual computations does fib(n) trigger (excluding simple cache lookups)?",
            hint: "Select 'Memoized' in the picker and count the nodes that stay coloured once the repeats are pruned.",
            options: [
                "n+1, one per distinct value",
                "n², one per pair of values",
                "Still exponential: the cache only saves a constant factor",
                "log n"
            ],
            correctIndex: 0,
            explanation: "There are exactly n+1 distinct values to produce: fib(0), fib(1), … , fib(n). The cache guarantees each one is computed only once; every other call becomes an O(1) lookup. On the graph, the exponential tree collapses into a thin column of n+1 nodes. We go from O(φⁿ) to O(n).",
            visualization: .dynamicProgramming
        ),
        Question(
            subject: .arrays,
            text: "A recursive fib(n) method without memoization takes exponential time. What is its space complexity (the maximum depth of the call stack)?",
            hint: "Scrub the reveal slider and follow one branch down: the stack only ever holds that single path.",
            options: [
                "O(2ⁿ)",
                "O(φⁿ)",
                "O(1)",
                "O(n)"
            ],
            correctIndex: 3,
            explanation: "We first recurse all the way down to a base case, so the depth of the call stack is approximately n.",
            visualization: .dynamicProgramming
        ),
        Question(
            subject: .arrays,
            text: "When computing fib(n) with memoization, how many times do we add the number 1?",
            hint: "In memoised mode, look at the leaves the tree keeps: those are the only places a 1 enters the sum.",
            options: ["n times", "log(fib(n)) times", "fib(n) times", "2ⁿ times"],
            correctIndex: 2,
            explanation: "All additions start from the leaf nodes, which return 1 (for fib(1)) or 0 (for fib(0)). The final result is nothing more than the sum of these 1's, and there are exactly fib(n) of them.",
            visualization: .dynamicProgramming
        ),
    ]
}
