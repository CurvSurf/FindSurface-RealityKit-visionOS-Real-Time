//
//  TriangleHighlighter.swift
//  FindSurfaceRR-visionOS
//
//  Created by CurvSurf-SGKim on 9/27/24.
//

import RealityKit

final class TriangleHighlighter: Entity {
    
    private let lowLevelMesh: LowLevelMesh
    private let model: ModelEntity
    
    required init() {
        
        let attributes: [LowLevelMesh.Attribute] = [
            .init(semantic: .position, format: .float3, offset: 0),
            .init(semantic: .normal, format: .float3, offset: MemoryLayout<simd_float3>.stride)
        ]
        
        let layouts: [LowLevelMesh.Layout] = [
            .init(bufferIndex: 0, bufferOffset: 0, bufferStride: MemoryLayout<simd_float3>.stride * 2)
        ]
        
        let meshDescriptor = LowLevelMesh.Descriptor(vertexCapacity: 6,
                                                     vertexAttributes: attributes,
                                                     vertexLayouts: layouts,
                                                     indexCapacity: 6,
                                                     indexType: .uint32)
        
        let lowLevelMesh = try! LowLevelMesh(descriptor: meshDescriptor)
        
        lowLevelMesh.withUnsafeMutableIndices { rawIndices in
            let indices = rawIndices.bindMemory(to: UInt32.self)
            indices[0] = 0
            indices[1] = 1
            indices[2] = 2
            indices[3] = 3
            indices[4] = 4
            indices[5] = 5
        }
        
        let mesh = try! MeshResource(from: lowLevelMesh)
        let material = UnlitMaterial(color: .green)
        let model = ModelEntity(mesh: mesh, materials: [material])
        model.components.set(OpacityComponent(opacity: 0.3))
        
        self.lowLevelMesh = lowLevelMesh
        self.model = model
        super.init()
        addChild(model)
    }
    
    func updateTriangle(_ point0: simd_float3,
                        _ point1: simd_float3,
                        _ point2: simd_float3) {
        lowLevelMesh.withUnsafeMutableBytes(bufferIndex: 0) { rawVertex in
            let vertices = rawVertex.bindMemory(to: simd_float3.self)
            let normal = normalize(cross(normalize(point1 - point0), normalize(point2 - point0)))
            vertices[0] = point0
            vertices[1] = normal
            vertices[2] = point1
            vertices[3] = normal
            vertices[4] = point2
            vertices[5] = normal
            vertices[6] = point0
            vertices[7] = -normal
            vertices[8] = point2
            vertices[9] = -normal
            vertices[10] = point1
            vertices[11] = -normal
        }
        
        var bounds = BoundingBox()
        bounds.formUnion(point0)
        bounds.formUnion(point1)
        bounds.formUnion(point2)
        
        lowLevelMesh.parts.replaceAll([
            LowLevelMesh.Part(indexCount: 3,
                              topology: .triangle,
                              bounds: bounds)
        ])
    }
}
