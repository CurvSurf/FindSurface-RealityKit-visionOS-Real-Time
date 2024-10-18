//
//  MeshManager.swift
//  FindSurfaceRT-visionOS
//
//  Created by CurvSurf-SGKim on 10/8/24.
//

import ARKit
import RealityKit


@Observable
final class MeshVertexManager {
    
    let rootEntity = Entity()
    
    private var entityMap: [UUID: ModelEntity] = [:]
    
    private var vertexMap: [UUID: [simd_float3]] = [:]
    private var faceMap: [UUID: [(Int, Int, Int)]] = [:]
    private(set) var vertexCount: Int = 0
    
    var vertices: [simd_float3] {
        return vertexMap.values.flatMap { $0 }
    }
    
    var shouldShowMesh: Bool {
        get {
            access(keyPath: \.shouldShowMesh)
            return rootEntity.isVisible
        }
        set {
            withMutation(keyPath: \.shouldShowMesh) {
                rootEntity.isVisible = newValue
            }
        }
    }
    
    @MainActor
    func anchorAdded(_ anchor: MeshAnchor) async {
        
        guard let entity = await ModelEntity.generateWireframe(from: anchor) else {
            return
        }
        
        entity.transform = Transform(matrix: anchor.originFromAnchorTransform)
        rootEntity.addChild(entity)
        entityMap[anchor.id] = entity
        updateVerticesAndFaces(anchor.worldPositions, anchor.faces, forKey: anchor.id)
    }
    
    @MainActor
    func anchorUpdated(_ anchor: MeshAnchor) async {
        
        guard let entity = entityMap[anchor.id],
              let materials = entity.model?.materials,
              let mesh = try? MeshResource.generate(from: anchor),
              let shape = try? await ShapeResource.generateStaticMesh(from: anchor) else {
            return
        }
        
        entity.model = ModelComponent(mesh: mesh, materials: materials)
        entity.transform = Transform(matrix: anchor.originFromAnchorTransform)
        entity.collision?.shapes = [shape]
        updateVerticesAndFaces(anchor.worldPositions, anchor.faces, forKey: anchor.id)
    }
    
    @MainActor
    func anchorRemoved(_ anchor: MeshAnchor) async {
        
        entityMap.removeValue(forKey: anchor.id)?.removeFromParent()
        updateVerticesAndFaces(nil, nil, forKey: anchor.id)
    }
    
    private func updateVerticesAndFaces(_ vertices: [simd_float3]?,
                                        _ faces: [(Int, Int, Int)]?,
                                        forKey key: UUID) {
        guard let vertices,
              let faces else {
            vertexCount -= vertexMap.removeValue(forKey: key)?.count ?? 0
            faceMap.removeValue(forKey: key)
            return
        }
        
        let removedVertexCount = vertexMap.updateValue(vertices, forKey: key)?.count ?? 0
        vertexCount += vertices.count - removedVertexCount
        faceMap.updateValue(faces, forKey: key)
    }
    
    func raycast(origin: simd_float3, direction: simd_float3) async -> CollisionCastHit? {
        return await rootEntity.scene?.raycast(origin: origin, direction: direction, query: .nearest).first
    }
    
    func nearestTriangleVertices(_ hit: CollisionCastHit) async -> (simd_float3, simd_float3, simd_float3)? {
        guard let triangleHit = hit.triangleHit else {
            return nil
        }
        
        guard let id = await UUID(uuidString: hit.entity.name),
              let vertices = vertexMap[id],
              let faces = faceMap[id] else { return nil }
        
        let face = faces[triangleHit.faceIndex]
        let triangleVertices = [vertices[face.0], vertices[face.1], vertices[face.2]]
        
        let location = hit.position
        
        let result = zip(triangleVertices, triangleVertices.map {
            distance_squared($0, location)
        }).sorted { lhs, rhs in
            lhs.1 < rhs.1
        }.map { $0.0 }
        
        return (result[0], result[1], result[2])
    }
}
//
//@Observable
//final class MeshManager {
//    
//    private let sceneReconstruction: SceneReconstructionProvider
//    
//    let rootEntity: Entity
//    
//    private var entityMap: [UUID: ModelEntity] = [:]
//    
//    private var pointMap: [UUID: [simd_float3]] = [:]
//    private var faceMap: [UUID: [(Int, Int, Int)]] = [:]
//    private(set) var pointCount: Int = 0
//    
//    init(_ dataProvider: SceneReconstructionProvider) {
//        let rootEntity = Entity()
//        rootEntity.name = "Mesh Entity"
//        
//        self.sceneReconstruction = dataProvider
//        self.rootEntity = rootEntity
//    }
//    
//    var shouldShowMesh: Bool {
//        get {
//            access(keyPath: \.shouldShowMesh)
//            return rootEntity.isEnabled
//        }
//        set {
//            withMutation(keyPath: \.shouldShowMesh) {
//                rootEntity.isEnabled = newValue
//            }
//        }
//    }
//    
//    @MainActor
//    func updateAnchors() async {
//        for await update in sceneReconstruction.anchorUpdates {
//            switch update.event {
//            case .added:    await anchorAdded(update.anchor)
//            case .updated:  await anchorUpdated(update.anchor)
//            case .removed:  await anchorRemoved(update.anchor)
//            }
//        }
//    }
//    
//    @MainActor
//    private func anchorAdded(_ anchor: MeshAnchor) async {
//        
//        guard let entity = await ModelEntity.generateWireframe(from: anchor) else {
//            return
//        }
//        
//        entity.transform = Transform(matrix: anchor.originFromAnchorTransform)
//        rootEntity.addChild(entity)
//        entityMap[anchor.id] = entity
//        updateVerticesAndFaces(anchor.worldPositions, anchor.faces, forKey: anchor.id)
//    }
//    
//    @MainActor
//    private func anchorUpdated(_ anchor: MeshAnchor) async {
//        
//        guard let entity = entityMap[anchor.id],
//              let materials = entity.model?.materials,
//              let mesh = try? MeshResource.generate(from: anchor),
//              let shape = try? await ShapeResource.generateStaticMesh(from: anchor) else {
//            return
//        }
//        
//        entity.model = ModelComponent(mesh: mesh, materials: materials)
//        entity.transform = Transform(matrix: anchor.originFromAnchorTransform)
//        entity.collision?.shapes = [shape]
//        updateVerticesAndFaces(anchor.worldPositions, anchor.faces, forKey: anchor.id)
//    }
//    
//    @MainActor
//    private func anchorRemoved(_ anchor: MeshAnchor) async {
//        
//        guard let entity = entityMap.removeValue(forKey: anchor.id) else {
//            return
//        }
//        
//        entity.removeFromParent()
//        updateVerticesAndFaces(nil, nil, forKey: anchor.id)
//    }
//    
//    private func updateVerticesAndFaces(_ vertices: [simd_float3]?,
//                                        _ faces: [(Int, Int, Int)]?,
//                                        forKey key: UUID) {
//        guard let vertices,
//              let faces else {
//            pointCount -= pointMap.removeValue(forKey: key)?.count ?? 0
//            faceMap.removeValue(forKey: key)
//            return
//        }
//        
//        let removedVertexCount = pointMap.updateValue(vertices, forKey: key)?.count ?? 0
//        pointCount += vertices.count - removedVertexCount
//        faceMap.updateValue(faces, forKey: key)
//    }
//}
//
//extension MeshAnchor: @retroactive Hashable {
//    
//    public func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//    
//    public static func == (lhs: MeshAnchor, rhs: MeshAnchor) -> Bool {
//        return lhs.id == rhs.id
//    }
//}
