//
//  simd_float3.swift
//  FindSurfaceRR-visionOS
//
//  Created by CurvSurf-SGKim on 8/6/24.
//

import Foundation
import simd

extension simd_float3 {
    
    enum Axis {
        case x
        case y
        case z
    }
    
    init(theta: Float, phi: Float, radius: Float = 1.0, polarAxis: Axis = .y) {
        
        let x = radius * sin(theta) * cos(phi)
        let y = radius * cos(theta)
        let z = radius * sin(theta) * sin(phi)
        
        switch polarAxis {
        case .x: self.init(y, z, x)
        case .y: self.init(x, y, z)
        case .z: self.init(z, x, y)
        }
    }
    
    init(angle: Float, radius: Float = 1.0, height: Float = 0.0, axis: Axis) {
        
        let x = radius * cos(angle)
        let z = radius * sin(angle)
        
        switch axis {
        case .x: self.init(height, z, x)
        case .y: self.init(x, height, z)
        case .z: self.init(z, x, height)
        }
    }
}

extension LazySequenceProtocol where Element == simd_float3 {
    
    func translated(_ offset: simd_float3) -> LazyMapSequence<Elements, simd_float3> {
        return map { $0 + offset }
    }
    
    func translated(x: Float, y: Float = 0.0, z: Float = 0.0) -> LazyMapSequence<Elements, simd_float3> {
        return translated(.init(x, y, z))
    }
    
    func translated(y: Float, z: Float = 0.0) -> LazyMapSequence<Elements, simd_float3> {
        return translated(x: 0, y: y, z: z)
    }
    
    func translated(z: Float) -> LazyMapSequence<Elements, simd_float3> {
        return translated(x: 0, y: 0, z: z)
    }
    
    func scaled(_ factors: simd_float3) -> LazyMapSequence<Elements, simd_float3> {
        return map { $0 * factors }
    }
    
    func scaled(_ factor: Float) -> LazyMapSequence<Elements, simd_float3> {
        return scaled(.init(repeating: factor))
    }
    
    func scaled(x: Float, y: Float = 1.0, z: Float = 1.0) -> LazyMapSequence<Elements, simd_float3> {
        return scaled(.init(x, y, z))
    }
    
    func scaled(y: Float, z: Float = 1.0) -> LazyMapSequence<Elements, simd_float3> {
        return scaled(x: 1, y: y, z: z)
    }
    
    func scaled(z: Float) -> LazyMapSequence<Elements, simd_float3> {
        return scaled(x: 1, y: 1, z: z)
    }
    
    func rotated(_ rotation: simd_quatf) -> LazyMapSequence<Elements, simd_float3> {
        return map { rotation.act($0) }
    }
    
    func rotated(angle: Float, axis: simd_float3) -> LazyMapSequence<Elements, simd_float3> {
        return rotated(.init(angle: angle, axis: axis))
    }
    
    func rotated(from: simd_float3, to: simd_float3) -> LazyMapSequence<Elements, simd_float3> {
        return rotated(.init(from: from, to: to))
    }
}

extension Array where Element == simd_float3 {
    
    mutating func translate(_ offset: simd_float3) {
        self = map { $0 + offset }
    }
    
    func translated(_ offset: simd_float3) -> Self {
        var this = self
        this.translate(offset)
        return this
    }
    
    mutating func translate(x: Float, y: Float = 0.0, z: Float = 0.0) {
        translate(.init(x, y, z))
    }
    
    func translated(x: Float, y: Float = 0.0, z: Float = 0.0) -> Self {
        return translated(.init(x, y, z))
    }
    
    mutating func translate(y: Float, z: Float = 0.0) {
        translate(x: 0, y: y, z: z)
    }
    
    func translated(y: Float, z: Float = 0.0) -> Self {
        return translated(x: 0, y: y, z: z)
    }
    
    mutating func translate(z: Float) {
        translate(x: 0, y: 0, z: z)
    }
    
    func translated(z: Float) -> Self {
        return translated(x: 0, y: 0, z: z)
    }
    
    mutating func scale(_ factors: simd_float3) {
        self = map { $0 * factors }
    }
    
    func scaled(_ factors: simd_float3) -> Self {
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
    
    mutating func scale(x: Float, y: Float = 1.0, z: Float = 1.0) {
        scale(.init(x, y, z))
    }
    
    func scaled(x: Float, y: Float = 1.0, z: Float = 1.0) -> Self {
        return scaled(.init(x, y, z))
    }
    
    mutating func scale(y: Float, z: Float = 1.0) {
        scale(x: 1, y: y, z: z)
    }
    
    func scaled(y: Float, z: Float = 1.0) -> Self {
        return scaled(x: 1, y: y, z: z)
    }
    
    mutating func scale(z: Float) {
        scale(x: 1, y: 1, z: z)
    }
    
    func scaled(z: Float) -> Self {
        return scaled(x: 1, y: 1, z: z)
    }
    
    mutating func rotate(_ rotation: simd_quatf) {
        self = map { rotation.act($0) }
    }
    
    func rotated(_ rotation: simd_quatf) -> Self {
        var this = self
        this.rotate(rotation)
        return this
    }
    
    mutating func rotate(angle: Float, axis: simd_float3) {
        rotate(.init(angle: angle, axis: axis))
    }
    
    func rotated(angle: Float, axis: simd_float3) -> Self {
        return rotated(.init(angle: angle, axis: axis))
    }
    
    mutating func rotate(from: simd_float3, to: simd_float3) {
        rotate(.init(from: from, to: to))
    }
    
    func rotated(from: simd_float3, to: simd_float3) -> Self {
        return rotated(.init(from: from, to: to))
    }
}
