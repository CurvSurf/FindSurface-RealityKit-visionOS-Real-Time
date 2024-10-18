//
//  GeometryManager.swift
//  FindSurfaceRT-visionOS
//
//  Created by CurvSurf-SGKim on 10/8/24.
//

import ARKit
import RealityKit
import _RealityKit_SwiftUI

import FindSurface_visionOS


@Observable
final class GeometryManager {
    
    let rootEntity: Entity
    
    private var pendingObjects: [UUID: PendingObject] = [:]
    private let geometryEntity: Entity
    private(set) var geometryEntityMap: [UUID: GeometryEntity] = [:]
    
    init() {
        
        let rootEntity = Entity()
        
        let geometryEntity = Entity()
        rootEntity.addChild(geometryEntity)

        self.rootEntity = rootEntity
        self.geometryEntity = geometryEntity
    }

    func addPendingObject(_ result: FindSurface.Result) async -> WorldAnchor {
        
        let count = await pendingObjects.count + PersistentDataModel.shared.count
        let pendingObject: PendingObject = switch result {
        case let .foundPlane(plane, inliers, rmsError):
            .init(name: "Plane\(count)",
                  geometry: .plane(plane),
                  inliers: inliers,
                  rmsError: rmsError,
                  creationDate: .now)
        case let .foundSphere(sphere, inliers, rmsError):
            .init(name: "Sphere\(count)",
                  geometry: .sphere(sphere),
                  inliers: inliers,
                  rmsError: rmsError,
                  creationDate: .now)
        case let .foundCylinder(cylinder, inliers, rmsError):
            .init(name: "Cylinder\(count)",
                  geometry: .cylinder(cylinder),
                  inliers: inliers,
                  rmsError: rmsError,
                  creationDate: .now)
        case let .foundCone(cone, inliers, rmsError):
            .init(name: "Cone\(count)",
                  geometry: .cone(cone),
                  inliers: inliers,
                  rmsError: rmsError,
                  creationDate: .now)
        case let .foundTorus(torus, inliers, rmsError): {
            var (beginAngle, deltaAngle) = torus.calcAngleRange(from: inliers)
            if deltaAngle > 1.5 * .pi {
                beginAngle = .zero
                deltaAngle = .twoPi
            }
            return .init(name: "Torus\(count)",
                         geometry: .torus(torus, beginAngle, deltaAngle),
                         inliers: inliers,
                         rmsError: rmsError,
                         creationDate: .now)
        }()
        default: fatalError("Should never reach here (\(result)).")
        }
        
        let anchor = WorldAnchor(originFromAnchorTransform: pendingObject.geometry.extrinsics)
        pendingObjects[anchor.id] = pendingObject
        return anchor
    }
    
    func removePendingObject(forKey key: UUID) {
        pendingObjects.removeValue(forKey: key)
    }
    
    @MainActor
    func anchorAdded(_ anchor: WorldAnchor) async -> Bool {
        
        var persistentObject: PersistentObject2? = nil
        if let pendingObject = pendingObjects.removeValue(forKey: anchor.id) {
            let object = PersistentObject2(from: pendingObject, forID: anchor.id)
            await PersistentDataModel.shared.register(object)
            persistentObject = object
        } else {
            persistentObject = await PersistentDataModel.shared.find(forID: anchor.id)
        }
        
        guard let persistentObject else {
            return false
        }
        
        let geometry = await GeometryEntity.generate(from: persistentObject)
        geometry.enableOutline(true)
        
        geometryEntity.addChild(geometry)
        geometryEntityMap[anchor.id] = geometry
        
        return true
    }
    
    @MainActor
    func anchorUpdated(_ anchor: WorldAnchor) async {
        
        let transform = Transform(matrix: anchor.originFromAnchorTransform)
        
        if let entity = geometryEntityMap[anchor.id] {
            entity.transform = transform
            entity.data?.extrinsics = transform.matrix
        }
    }
    
    @MainActor
    func anchorRemoved(_ anchor: WorldAnchor) async {
        await anchorRemoved(forID: anchor.id)
    }
    
    @MainActor
    func anchorRemoved(forID id: UUID) async {
        geometryEntityMap.removeValue(forKey: id)?.removeFromParent()
        
        await PersistentDataModel.shared.deregister(forID: id)
    }
}

fileprivate func angle(_ a: simd_float3, _ b: simd_float3, _ c: simd_float3 = .init(0, -1, 0)) -> Float {
    let angle = acos(dot(a, b))
    if dot(c, cross(a, b)) < 0 {
        return -angle
    } else {
        return angle
    }
}

extension Torus {
    func calcAngleRange(from inliers: [simd_float3]) -> (begin: Float, delta: Float) {
        
        let projected = inliers.map { point in
            normalize(simd_float3(point.x, 0, point.z))
        }
        var projectedCenter = projected.reduce(.zero, +) / Float(projected.count)
        
        if length(projectedCenter) < 0.1 {
            return (begin: .zero, delta: .twoPi)
        }
        projectedCenter = normalize(projectedCenter)
        
        let baseAngle = angle(.init(1, 0, 0), projectedCenter)
        
        let angles = projected.map {
            return angle(projectedCenter, $0)
        }
        
        guard let (beginAngle, endAngle) = angles.minAndMax() else {
            return (begin: .zero, delta: .twoPi)
        }
        
        let begin = beginAngle + baseAngle
        let end = endAngle + baseAngle
        let delta = end - begin
        
        return (begin: begin, delta: delta)
    }
}
