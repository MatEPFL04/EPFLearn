//
//  BFS_view.swift
//  EPFLearn
//
//  Created by Mat on 26.06.2026.
//


import SwiftUI

enum Graph {
        
    static func bfs(from start: Int, adjacency: [[Int]]) -> (order: [Int], dist: [Int]) {
        let inf = Int.max
        var d = Array(repeating: inf, count: adjacency.count)
        var order: [Int] = []
        var queue = [start]
        d[start] = 0

        while !queue.isEmpty {
            let u = queue.removeFirst()
            order.append(u)
            for v in adjacency[u] where d[v] == inf {
                d[v] = d[u] + 1
                queue.append(v)
            }
        }
        return (order, d)
    }
}
