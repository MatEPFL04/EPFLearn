//
//  MathCoordinateSpace.swift
//  EPFLearn
//
//  Created by Mat on 08.04.2026.
//

import SwiftUI

struct MathCoordinateSpace {
    
    let rect: CGRect
    
    let scale: Double
 
    /// Convenience init for square views where you know the side length
    init(size: CGFloat, scale: Double) {
        self.rect  = CGRect(origin: .zero, size: CGSize(width: size, height: size))
        self.scale = scale
    }
 
    init(rect: CGRect, scale: Double) {
        self.rect  = rect
        self.scale = scale
    }
 
    // MARK: - Math → Screen
 
    func toScreen(x xMath: Double) -> CGFloat {
        CGFloat(xMath * scale) + rect.midX
    }
 
    func toScreen(y yMath: Double) -> CGFloat {
        CGFloat(-yMath * scale) + rect.midY
    }
 
    func toScreen(x xMath: Double, y yMath: Double) -> CGPoint {
        CGPoint(x: toScreen(x: xMath), y: toScreen(y: yMath))
    }
 
    // MARK: - Screen → Math
 
    func toMath(x xScreen: CGFloat) -> Double {
        (xScreen - rect.midX) / scale
    }
 
    func toMath(y yScreen: CGFloat) -> Double {
        -(yScreen - rect.midY) / scale
    }
}

