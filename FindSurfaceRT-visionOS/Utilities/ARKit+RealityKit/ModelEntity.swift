//
//  ModelEntity.swift
//  FindSurfaceST-visionOS
//
//  Created by CurvSurf-SGKim on 6/17/24.
//

import Foundation
import RealityKit
import ARKit

extension MeshResource {
    
    class func generate(from anchor: MeshAnchor) throws -> MeshResource {
        
        let positions = anchor.positions
        let normals = anchor.normals
        let indices = anchor.indices
        
        var descriptor = MeshDescriptor(name: anchor.id.uuidString)
        descriptor.positions = .init(positions)
        descriptor.normals = .init(normals)
        descriptor.primitives = .triangles(indices)
        
        return try .generate(from: [descriptor])
    }
}

extension ModelEntity {
    
    class func generateWireframe(from meshAnchor: MeshAnchor) async -> ModelEntity? {
        guard let shape = try? await ShapeResource.generateStaticMesh(from: meshAnchor),
              let mesh = try? MeshResource.generate(from: meshAnchor) else { return nil }
        
        let entity = ModelEntity(mesh: mesh, materials: .mesh)
        entity.name = meshAnchor.id.uuidString
        entity.transform = Transform(matrix: meshAnchor.originFromAnchorTransform)
        entity.collision = CollisionComponent(shapes: [shape], isStatic: true)
        entity.components.set(InputTargetComponent())
        entity.physicsBody = PhysicsBodyComponent(mode: .static)
        return entity
    }
}
