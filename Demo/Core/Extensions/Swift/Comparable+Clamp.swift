//
//  Comparable+Clamp.swift
//  Demo
//  Created by MuHa on 21/04/2026.

import Foundation

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
