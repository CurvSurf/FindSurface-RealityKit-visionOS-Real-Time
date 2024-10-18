//
//  simd_float2.swift
//  FindSurfaceRR-visionOS
//
//  Created by CurvSurf-SGKim on 8/6/24.
//

import Foundation
import simd

extension simd_float2 {
    
    init(angle: Float, radius: Float = 1.0) {
        self.init(x: radius * cos(angle), y: radius * sin(angle))
    }
}

extension LazySequenceProtocol where Element == simd_float2 {
    
    func translated(_ offset: simd_float2) -> LazyMapSequence<Elements, simd_float2> {
        return map { $0 + offset }
    }
    
    func translated(x: Float, y: Float = 0.0) -> LazyMapSequence<Elements, simd_float2> {
        return translated(.init(x, y))
    }
    
    func translated(y: Float) -> LazyMapSequence<Elements, simd_float2> {
        return translated(x: 0, y: y)
    }
    
    func scaled(_ factors: simd_float2) -> LazyMapSequence<Elements, simd_float2> {
        return map { $0 * factors }
    }
    
    func scaled(_ factor: Float) -> LazyMapSequence<Elements, simd_float2> {
        return scaled(.init(repeating: factor))
    }
    
    func scaled(x: Float, y: Float = 1.0) -> LazyMapSequence<Elements, simd_float2> {
        return scaled(.init(x, y))
    }
    
    func scaled(y: Float) -> LazyMapSequence<Elements, simd_float2> {
        return scaled(x: 1, y: y)
    }
    
    func rotated(angle: Float) -> LazyMapSequence<Elements, simd_float2> {
        let c = cos(angle)
        let s = sin(angle)
        let rotation = simd_float2x2(.init(c, s), .init(-s, c))
        return map { rotation * $0 }
    }
}

extension Array where Element == simd_float2 {
    
    mutating func translate(_ offset: simd_float2) {
        self = map { $0 + offset }
    }
    
    func translated(_ offset: simd_float2) -> Self {
        var this = self
        this.translate(offset)
        return this
    }
    
    mutating func translate(x: Float, y: Float = 0.0) {
        translate(.init(x, y))
    }
    
    func translated(x: Float, y: Float = 0.0) -> Self {
        return translated(.init(x, y))
    }
    
    mutating func translate(y: Float) {
        translate(x: 0, y: y)
    }
    
    func translated(y: Float) -> Self {
        return translated(x: 0, y: y)
    }
    
    mutating func scale(_ factors: simd_float2) {
        self = map { $0 * factors }
    }
    
    func scaled(_ factors: simd_float2) -> Self {
        var this = self
        this.scale(factors)
        return this
    }
    
    mutating func scale(_ factor: Float) {
        scale(.init(repeating: factor))
    }
    
    func scaled(_ factor: Float) -> Self {
        return scaled(.init(repeating: factor))
    }
    
    mutating func scale(x: Float, y: Float = 1.0) {
        scale(.init(x, y))
    }
    
    func scaled(x: Float, y: Float = 1.0) -> Self {
        return scaled(.init(x, y))
    }
    
    mutating func scale(y: Float) {
        scale(x: 1, y: y)
    }
    
    func scaled(y: Float) -> Self {
        return scaled(x: 1, y: y)
    }
    
    mutating func rotate(angle: Float) {
        let c = cos(angle)
        let s = sin(angle)
        let rotation = simd_float2x2(.init(c, s), .init(-s, c))
        self = map { rotation * $0 }
    }
    
    func rotated(angle: Float) -> Self {
        var this = self
        this.rotate(angle: angle)
        return this
    }
}
