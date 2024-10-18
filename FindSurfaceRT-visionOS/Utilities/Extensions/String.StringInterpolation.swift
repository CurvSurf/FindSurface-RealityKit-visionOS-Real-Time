//
//  String.StringInterpolation.swift
//  FindSurfaceRR-visionOS
//
//  Created by CurvSurf-SGKim on 8/19/24.
//

import Foundation
import simd

extension String.StringInterpolation {
    mutating func appendInterpolation(length value: Float) {
        appendLiteral(String(format: "%.1f", value * 100))
    }
    
    mutating func appendInterpolation(position value: simd_float3) {
        appendLiteral(String(format: "(%.1f, %.1f, %.1f)", value.x * 100, value.y * 100, value.z * 100))
    }
    
    mutating func appendInterpolation(direction value: simd_float3) {
        appendLiteral(String(format: "(%.3f, %.3f, %.3f)", value.x, value.y, value.z) )
    }
    
    mutating func appendInterpolation(angle radians: Float) {
        appendLiteral(String(format: "%.1f", Float.degree(fromRadian: radians)))
    }
    
    mutating func appendInterpolation(percentage value: Float) {
        appendLiteral(String(format: "%.1f%%", value * 100))
    }
}

