//
//  MeshAnchor.swift
//  FindSurfaceST-visionOS
//
//  Created by CurvSurf-SGKim on 6/17/24.
//

import Foundation
import ARKit
import simd
import Algorithms

extension GeometrySource {
    
    fileprivate func asSimdFloat3() -> [simd_float3] {
        precondition(componentsPerVector == 3)
        let floatCount = count * 3
        let pointer = buffer.contents().bindMemory(to: Float.self, capacity: floatCount)
        let buffer = UnsafeBufferPointer(start: pointer, count: floatCount)
            .chunks(ofCount: 3)
            .map { values in
                simd_float3(values[values.startIndex],
                            values[values.startIndex + 1],
                            values[values.startIndex + 2])
            }
        return Array(buffer)
    }
}

extension MeshAnchor {
    
    var positions: [simd_float3] {
        return geometry.vertices.asSimdFloat3()
    }
    
    var worldPositions: [simd_float3] {
        let transform = originFromAnchorTransform
        return positions.map {
            simd_make_float3(transform * simd_float4($0, 1))
        }
    }
    
    var normals: [simd_float3] {
        return geometry.normals.asSimdFloat3()
    }
    
    var worldNormals: [simd_float3] {
        let transform = originFromAnchorTransform
        return normals.map {
            simd_make_float3(transform * simd_float4($0, 0))
        }
    }
    
    var faces: [(Int, Int, Int)] {
        let faceBuffer = geometry.faces.buffer
        let faceCount = geometry.faces.count
        let bytesPerIndex = geometry.faces.bytesPerIndex
        return (0..<faceCount).map { faceIndex in
            let index = faceIndex * 3
            let pointer = faceBuffer.contents()
                .advanced(by: index * bytesPerIndex)
                .assumingMemoryBound(to: UInt32.self)
            
            return (Int(pointer[0]), Int(pointer[1]), Int(pointer[2]))
        }
    }
    
    var indices: [UInt32] {
        let faceBuffer = geometry.faces.buffer
        let faceCount = geometry.faces.count
        let bytesPerIndex = geometry.faces.bytesPerIndex
        return (0..<faceCount * 3).map { index in
            let pointer = faceBuffer.contents()
                .advanced(by: index * bytesPerIndex)
                .assumingMemoryBound(to: UInt32.self)
            return pointer.pointee
        }
    }
}
