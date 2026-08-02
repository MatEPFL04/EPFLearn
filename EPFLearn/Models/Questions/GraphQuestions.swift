//
//  GraphQuestions.swift
//  EPFLearn
//
//  Created by Mat on 06.07.2026.
//

extension Question {
    
    
    static let dfsQuestions: [Question] = [
        Question(
            subject: .graphs,
            text: "Which statement about DFS is false?",
            hint: "",
            options: [
                "A back edge (an edge going toward an ancestor) is never used",
                "The first node to finish (i.e. with the smallest finishing time) is always the deepest one in the forest",
                "The node with the highest finishing time is always the one that got the first start time in a connected graph",
                "DFS always runs in Θ(V + E)"
            ],
            correctIndex: 1,
            explanation: "The node with the smallest finishing time isn't always the deepest, it can simply be a leaf found early, even in a shallow branch.",
            visualization: .DFS
        ),
        Question(
            subject: .graphs,
            text: "When running DFS on an undirected graph, how do we detect that the graph has a cycle?",
            hint: "What happens if you see a node that's already visited, but it's not the node you just came from?",
            options: [
                "When DFS finishes exploring all nodes and returns to the root",
                "When we follow an edge to an already-visited vertex that is not the immediate parent of the current vertex",
                "When the stack becomes completely empty before all nodes are visited",
                "Undirected graphs cannot contain cycles by definition"
            ],
            correctIndex: 1,
            explanation: "In an undirected graph, if you follow an edge and reach a vertex that's already visited, and that vertex is not the parent that just called the current DFS recursion, there must be an alternate path to that same node. That confirms a cycle.",
            visualization: .DFS
        ),
        Question(
            subject: .graphs,
            text: "In a DFS run you observe d[u] < d[v] < f[v] < f[u] (d = discovery time, f = finish time). What is the relationship between u and v?",
            hint: "Try it in the tool, and look for the pattern in the question",
            options: [
                "v is a descendant of u in the DFS forest",
                "u is a descendant of v",
                "u and v are in different DFS trees",
                "u and v are siblings, neither is an ancestor of the other"
            ],
            correctIndex: 0,
            explanation: "By the parenthesis theorem, the intervals [d, f] are either disjoint or nested. Here [d[v], f[v]] sits strictly inside [d[u], f[u]], meaning v was fully discovered and finished while u was still on the stack, so v is a descendant of u.",
            visualization: .DFS
        ),
        Question(
            subject: .graphs,
            text: "If a graph has several disconnected components, how does a standard full DFS traversal make sure every node gets visited?",
            hint: "What does the algorithm do once the recursive call from the starting node fully finishes?",
            options: [
                "It automatically teleports to random nodes",
                "A loop in the main function goes through all vertices and restarts DFS from any vertex still unvisited",
                "DFS cannot handle disconnected components and crashes",
                "The algorithm increases its search radius until it reaches the disconnected part"
            ],
            correctIndex: 1,
            explanation: "A full DFS wrapper has a main loop that iterates over all vertices. If it finds a vertex not yet visited by earlier runs, it launches a new DFS from that vertex, creating a new tree in the DFS forest.",
            visualization: .DFS
        )
    ]
    
    static let bfsQuestions: [Question] = [
        Question(
            subject: .graphs,
            text: "For which type of graph does BFS run in Ω(V + E)?",
            hint: "",
            options: [
                "Graphs with no cycles",
                "Connected graphs",
                "Only for directed acyclic graphs (DAGs)",
                "For every type of graph"
            ],
            correctIndex: 1,
            explanation: "If the graph is connected, we're guaranteed to visit every vertex and go through every edge, giving a running time proportional to V + E.",
            visualization: .BFS
        ),
        Question(
            subject: .graphs,
            text: "Run BFS on an undirected graph and label each vertex with its level (distance from s). What's true of every non-tree edge (u, v)?",
            hint: "Look at the values for non-tree edges in the vizualization. ",
            options: [
                "It can connect levels that differ by any amount",
                "Their levels differ by at most 1 (same level or adjacent levels)",
                "It always connects two vertices at the same level",
                "It always connects a vertex to its direct parent"
            ],
            correctIndex: 1,
            explanation: "If level(v) ≥ level(u) + 2, then when u was dequeued, v would still be undiscovered and would be reached through u, making it a tree edge at level(u)+1, a contradiction. So in an undirected BFS, non-tree edges only link vertices at equal or adjacent levels.",
            visualization: .BFS
        ),
        Question(
            subject: .graphs,
            text: "During BFS, at any moment, the queue contains vertices from how many distinct levels?",
            hint: "Think about what's in the queue right when you finish one level and start the next.",
            options: [
                "Exactly one level",
                "At most two consecutive levels (k and k+1)",
                "Any number of levels",
                "All levels from 0 up to the current one"
            ],
            correctIndex: 1,
            explanation: "The queue is always a block of level-k vertices followed by the level-(k+1) vertices they just discovered. Dequeuing a level-k vertex can only enqueue level-(k+1) ones, so at most two consecutive levels ever coexist in the queue.",
            visualization: .BFS
        ),
        Question(
            subject: .graphs,
            text: "On a connected graph, let m(s) be the deepest BFS level when starting from s. You sweep the slider over every possible source. Which statement about the values m(s) is always true, no matter the graph?",
            hint: "Pick two sources that are neighbors and run both. By how much can m(s) differ between them?",
            options: [
                "Two adjacent sources can have m-values differing by at most 1",
                "The source with the most neighbors always gives the smallest m(s)",
                "Every source gives a distinct m(s)",
                "m(s) is smallest exactly for the source with the tallest BFS tree (most tree edges)"
            ],
            correctIndex: 0,
            explanation: "Moving the source to an adjacent vertex shifts every distance by at most 1 (triangle inequality), so the deepest level can change by at most 1 between neighbors; check it by running two adjacent sources. The degree-based and 'all distinct' claims are false: a hub can still be far from one branch, and many sources often share the same m(s).",
            visualization: .BFS
        )
    ]
    
    static let primQuestions: [Question] = [
        Question(
            subject: .graphs,
            text: "At each step Prim adds the cheapest edge crossing the cut (tree vs non-tree). Why is that edge guaranteed to be safe (part of some MST)?",
            hint: "Think about any cut and the lightest edge crossing it.",
            options: [
                "Because it's the smallest edge remaining in the whole graph",
                "By the cut property: the minimum-weight edge crossing any cut belongs to some MST",
                "Because it always touches the start vertex",
                "Because Prim sorts all edges first, like Kruskal"
            ],
            correctIndex: 1,
            explanation: "The cut property states that for any partition of the vertices, the lightest edge crossing it is in some MST. Prim's cut is {tree} vs {rest}, and it always grabs the lightest crossing edge, hence always a safe edge. Note it need not be the globally smallest remaining edge, only the smallest crossing this cut.",
            visualization: .prim
        ),
        Question(
            subject: .graphs,
            text: "Let G be a connected graph with unique edge weights, and G' any other connected weighted graph. What can we say about the edges added by Prim starting from different vertices?",
            hint: "Try running Prim on a graph with G'-like properties in the playground.",
            options: [
                "G: the set of edges doesn't change. G': the edges can vary, but the total weight is always the same.",
                "G: the set of edges can vary, but the total weight is the same. G': the edges can vary, but the total weight is always the same.",
                "G: the set of edges doesn't change. G': the set of edges doesn't change either.",
                "In both cases the set of edges doesn't change."
            ],
            correctIndex: 0,
            explanation: "When edge weights are strictly unique, the graph has exactly one unique Minimum Spanning Tree. Since Prim always finds an MST, every start vertex converges to the exact same final edge set. Only the order in which edges are added differs.",
            visualization: .prim
        ),
        Question(
            subject: .graphs,
            text: "Unlike Kruskal, the set of vertices already in Prim's tree is always…",
            hint: "How many separate pieces does Prim's partial result have at any moment?",
            options: [
                "Possibly several disconnected fragments",
                "Always a single connected subtree that grows by one vertex per step",
                "Always exactly half the vertices",
                "The same as Kruskal's intermediate state"
            ],
            correctIndex: 1,
            explanation: "Prim grows ONE connected tree from the source, adding one new vertex per step via a crossing edge. Kruskal instead maintains many fragments that merge over time. That's the core structural difference: Prim = one growing blob, Kruskal = merging forest.",
            visualization: .prim
        ),
        Question(
            subject: .graphs,
            text: "Let e be the edge with the absolute maximum weight in a connected graph. Under what condition is Prim's algorithm guaranteed to accept and add e to the tree?",
            hint: "Think about what happens if removing e completely disconnects the graph.",
            options: [
                "Never; Prim greedily minimizes weights, so the heaviest edge is always rejected",
                "If e is a bridge edge (cut-edge) whose removal splits the graph into two isolated components",
                "Only if Prim starts directly from one of the two endpoints of e",
                "If e belongs to a cycle where every other edge is even heavier"
            ],
            correctIndex: 1,
            explanation: "If e is a bridge edge, it's the only connection between two parts of the graph. Once Prim's growing tree covers one part, e becomes the ONLY crossing edge available to reach the rest. Since Prim must connect all vertices, it's forced to accept e, no matter how large its weight.",
            visualization: .prim
        ),
    ]
    
    static let kruskalQuestions: [Question] = [
        Question(
            subject: .graphs,
            text: "You add 1 completely isolated vertex (no connected edges) to an initially connected graph with V vertices, then run Kruskal. What's the total number of accepted edges when it finishes?",
            hint: "Can an edge ever connect to a vertex that has no edges attached to it?",
            options: [
                "Exactly V edges, since the total number of vertices increased by 1",
                "Exactly V − 1 edges, since the isolated vertex can't absorb any edges",
                "Exactly V − 2 edges, since the structure becomes fragmented",
                "0 edges, since Kruskal fails immediately on disconnected graphs"
            ],
            correctIndex: 1,
            explanation: "The updated graph has V + 1 vertices but 2 connected components (the original connected block and the isolated vertex). Kruskal builds an MST on the connected block using V − 1 edges. It can never add an edge to the isolated vertex, giving a spanning forest of 2 components with a total of (V + 1) − 2 = V − 1 edges.",
            visualization: .kruskal
        ),
        Question(
            subject: .graphs,
            text: "During a Kruskal run on a connected graph with V vertices, after how many accepted edges does the algorithm stop adding new ones?",
            hint: "Try tracking the numbers on small examples.",
            options: [
                "After E accepted edges",
                "After exactly V − 1 accepted edges",
                "After V accepted edges",
                "It depends on the edge weights"
            ],
            correctIndex: 1,
            explanation: "The result is a spanning tree, which always has exactly V − 1 edges regardless of weights. Once V − 1 edges are accepted, every later edge would connect two vertices already in the same component and gets rejected. Count the green edges in any connected run: always V − 1.",
            visualization: .kruskal
        ),
        Question(
            subject: .graphs,
            text: "You toggle the graph to non-connected and run Kruskal, but stop it just before it adds its very last valid edge. What does it produce?",
            hint: "Each valid edge added by Kruskal merges two separate components together. Missing the last edge means one fewer merge happens.",
            options: [
                "A minimum spanning forest with exactly V − (number of original components) edges",
                "A disjoint forest containing exactly (number of original components + 1) trees",
                "Nothing: stopping early triggers an error",
                "A single tree with exactly V − 1 edges anyway"
            ],
            correctIndex: 1,
            explanation: "In a non-connected graph with c components, Kruskal normally adds V − c edges to form c trees. Stopping just before the last valid edge skips the final merge. This leaves V − c − 1 edges, resulting in a forest of c + 1 disjoint trees.",
            visualization: .kruskal
        ),
        Question(
            subject: .graphs,
            text: "You take a connected graph with V vertices and attach a separate, independent chain of 3 new vertices linked by 2 edges, completely disconnected from the main graph. When you run Kruskal, what's the total number of ACCEPTED edges?",
            hint: "How many total vertices and how many total components does this new configuration have?",
            options: [
                "Exactly V − 1 accepted edges",
                "Exactly V + 1 accepted edges",
                "Exactly V + 2 accepted edges",
                "Exactly V + 3 accepted edges"
            ],
            correctIndex: 1,
            explanation: "The new configuration has V + 3 vertices total, in 2 components: the original connected graph and the new 3-vertex chain. By the forest formula, accepted edges = (Total Vertices) − (Total Components) = (V + 3) − 2 = V + 1 (V − 1 from the main block, plus 2 from the chain).",
            visualization: .kruskal
        ),
    ]
    
    static let djikistraQuestion: [Question] = [
        Question(
            subject: .graphs,
            text: "Why does Dijkstra fail on graphs with negative edge weights, even without any negative cycle?",
            hint: "Once a vertex is settled (green), Dijkstra never revisits it. What could a later negative edge do?",
            options: [
                "It loops forever",
                "A vertex can be settled with a non-final distance, since a later negative edge could still lower it",
                "It always returns distance 0 everywhere",
                "It works fine; only negative cycles break it"
            ],
            correctIndex: 1,
            explanation: "Dijkstra's correctness relies on the assumption that extracting the minimum-tentative-distance vertex makes that distance final, which is true only with non-negative weights. A negative edge discovered later could shorten an already-settled vertex, but Dijkstra never reopens it, so the answer can be wrong even without a negative cycle. Bellman-Ford handles this correctly.",
            visualization: .djikistra
        ),
        Question(
            subject: .graphs,
            text: "At the moment Dijkstra settles (turns green) a vertex u, what is guaranteed about dist[u]?",
            hint: "It's pulled from the frontier as the current minimum. Could a shorter path to u still appear later?",
            options: [
                "It is final, no future relaxation can lower it",
                "It's only an upper bound that may still decrease",
                "It equals the number of edges on the path",
                "It's final only if u is adjacent to the source"
            ],
            correctIndex: 0,
            explanation: "With non-negative weights, when u is extracted as the vertex with minimum tentative distance, that distance is already optimal: any other path to u would have to pass through a not-yet-settled vertex whose distance is ≥ dist[u], plus a non-negative tail, so it can't be shorter. That's exactly why settled vertices are never reopened.",
            visualization: .djikistra
        ),
        Question(
            subject: .graphs,
            text: "On a fixed graph you move the source slider and rerun Dijkstra. The shortest-path tree that lights up green…",
            hint: "Distances are from the source. Is the tree a property of the graph or of the source?",
            options: [
                "Stays the same regardless of the source",
                "Generally changes, since it is rooted at the chosen source",
                "Always has the same edges as the MST",
                "Always has height 1"
            ],
            correctIndex: 1,
            explanation: "The shortest-path tree is rooted at the source, so changing the source generally changes both distances and tree edges. It's also distinct from the MST: the MST minimizes total weight, while the shortest-path tree minimizes each vertex's distance from the source, usually a different tree.",
            visualization: .djikistra
        ),
        Question(
            subject: .graphs,
            text: "Using a binary-heap priority queue, what is Dijkstra's running time on a graph with V vertices and E edges?",
            hint: "Each edge might trigger a decrease-key; each vertex is extracted once.",
            options: [
                "O(V + E)",
                "O((V + E) log V)",
                "O(V²·E)",
                "O(E log E), but only if the graph is dense"
            ],
            correctIndex: 1,
            explanation: "Each of the V extract-min operations costs O(log V), and each of the E edges may cause a decrease-key costing O(log V), giving O((V + E) log V). (A simple-array implementation is O(V² + E); a Fibonacci heap improves this to O(E + V log V).)",
            visualization: .djikistra
        ),
    ]
    
    static let bellmanQuestion: [Question] = [
        Question(
            subject: .graphs,
            text: "Why does Bellman-Ford run exactly V − 1 relaxation passes over all edges?",
            hint: "How many edges can a shortest path have, at most?",
            options: [
                "Because there are V − 1 edges in the graph",
                "Because a shortest path has at most V − 1 edges, and each pass extends correct distances by one more edge",
                "Because it sorts the edges V − 1 times",
                "It's arbitrary; any number of passes works"
            ],
            correctIndex: 1,
            explanation: "A shortest path with no repeated vertices uses at most V − 1 edges. After pass k, every shortest path using ≤ k edges is correct, so V − 1 passes settle all shortest paths. The extra V-th pass is only there to detect negative cycles.",
            visualization: .bellmanford
        ),
        Question(
            subject: .graphs,
            text: "After V − 1 passes, Bellman-Ford does one more pass. If some edge (u, v) can STILL be relaxed, what does that mean?",
            hint: "Distances shouldn't improve anymore if everything were finite and cycle-free.",
            options: [
                "The graph is disconnected",
                "There is a negative-weight cycle reachable from the source",
                "The source was chosen incorrectly",
                "There are parallel edges"
            ],
            correctIndex: 1,
            explanation: "If no negative cycle is reachable, V − 1 passes make all distances final, so nothing can improve on pass V. A further improvement means some reachable cycle has negative total weight: going around it keeps lowering the distance, so no finite shortest path exists. That's exactly the cycle highlighted in red in the animation.",
            visualization: .bellmanford
        ),
        Question(
            subject: .graphs,
            text: "You run Bellman-Ford with all NON-negative weights. Compared to Dijkstra on the same graph, the final distances are…",
            hint: "Both are correct here. What differs is the cost, not the answer.",
            options: [
                "Different, Bellman-Ford is less accurate",
                "Identical, both compute true shortest distances; only the running time differs",
                "Identical only on trees",
                "Different, because Bellman-Ford ignores edge weights"
            ],
            correctIndex: 1,
            explanation: "On non-negative weights, both algorithms are correct and give the same distances. The difference is efficiency: Bellman-Ford is O(V·E), Dijkstra is O((V+E) log V). Bellman-Ford's real value is handling negative edges (and detecting negative cycles), which Dijkstra cannot do.",
            visualization: .bellmanford
        ),
        Question(
            subject: .graphs,
            text: "During Bellman-Ford, edges are relaxed in a fixed order each pass. Does that order affect the final distances?",
            hint: "Could a lucky order finish in fewer passes? Could it change the final numbers?",
            options: [
                "Yes: a bad order gives wrong distances",
                "No: the final distances are always the same; only how many passes are actually needed can differ",
                "Yes: the order changes which vertices are reachable",
                "Only if the graph has negative weights"
            ],
            correctIndex: 1,
            explanation: "After V − 1 full passes the distances are correct regardless of edge order; order never changes the final answer. A favorable order may let distances converge in fewer passes (early exit when a pass makes no change), but the converged values are identical.",
            visualization: .bellmanford
        ),
    ]
    

    static let topoQuestions: [Question] = [
        Question(
            subject: .graphs,
            text: "Run a graph and look at the layout. Find two vertices sitting in the same vertical layer (no arrow between them). What does that tell you about the ordering?",
            hint: "Two vertices with no path linking them, could you swap them and still have a valid order?",
            options: [
                "Nothing; the order is still unique",
                "They could be swapped, so this graph has more than one valid topological order",
                "It means the graph has a cycle",
                "It means one of them is the source"
            ],
            correctIndex: 1,
            explanation: "Two vertices in the same layer have no edge constraining their relative order, so swapping them yields another valid topological order. Spotting any such pair on the layout proves the order isn't unique, with no need to regenerate the graph.",
            visualization: .topologicalorder
        ),
        Question(
            subject: .graphs,
            text: "Find the very first vertex of the ordering. What's special about it?",
            hint: "How many edges point into the first vertex of a valid order?",
            options: [
                "It has the most outgoing edges",
                "It has no incoming edge",
                "It is always vertex 0",
                "It has exactly one incoming edge"
            ],
            correctIndex: 1,
            explanation: "The first vertex of any topological order can have nothing before it. Regenerate a few graphs: the leftmost vertex always has only outgoing arrows. It doesn't have to be vertex 0, and a high out-degree is irrelevant.",
            visualization: .topologicalorder
        ),
        Question(
            subject: .graphs,
            text: "Increase the vertices slider and run several graphs. When does a graph have only one valid ordering?",
            hint: "Look at the layout. When is there exactly one vertex per layer, chained left to right?",
            options: [
                "Whenever the graph is connected",
                "When the vertices form a single chain v₁→v₂→…→vₙ (a directed path through all of them)",
                "Whenever there are more edges than vertices",
                "It's always forced"
            ],
            correctIndex: 1,
            explanation: "The order is unique only when a directed edge links every consecutive pair. Any graph with two independent vertices in the same layer allows a swap, hence multiple orders.",
            visualization: .topologicalorder
        ),
        Question(
            subject: .graphs,
            text: "Which statement about topological ordering is false?",
            hint: "",
            options: [
                "It arranges the vertices so that for every edge (u,v), u comes before v in the ordering",
                "A topological sort only makes sense in a directed graph",
                "A topological sort can be found in a cyclic graph",
                "A topological sort can be found in O(V + E)"
            ],
            correctIndex: 2,
            explanation: "The rule 'for every edge (u,v), u comes before v' can never be satisfied in a cyclic graph.",
            visualization: .topologicalorder
        ),
    ]
    
}
