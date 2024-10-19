//
//  Entity.swift
//  FindSurfaceST-visionOS
//
//  Created by CurvSurf-SGKim on 6/25/24.
//

import Foundation
import RealityKit

struct PersistentDataComponent: Component {
    var data: PersistentObject
}

protocol HasPersistentDataComponent {
    
    var data: PersistentObject? { get set }
}

extension HasPersistentDataComponent where Self: Entity {
    var data: PersistentObject? {
        get { self.components[PersistentDataComponent.self]?.data }
        set {
            if let newValue {
                self.components.set(PersistentDataComponent(data: newValue))
            }
        }
    }
}

protocol HasOpacityComponent {
    
    var isVisible: Bool { get set }
}

extension HasOpacityComponent where Self: Entity {
    var isVisible: Bool {
        get {
            return (self.components[OpacityComponent.self]?.opacity ?? 1) == 1
        }
        set {
            self.components.set(OpacityComponent(opacity: newValue ? 1 : 0))
        }
    }
}

extension Entity: HasOpacityComponent {}

@MainActor
class GeometryEntity: Entity, HasPersistentDataComponent {
    
    required init() {
        super.init()
        self.components.set(OpacityComponent(opacity: 1))
    }
    
    func enableOutline(_ visible: Bool) {
        fatalError()
    }
}

extension GeometryEntity {
    
    class func generate(from object: PersistentObject) async -> GeometryEntity {
        let entity: GeometryEntity = switch object.geometry {
        case let .plane(plane):
            PlaneEntity(width: plane.width, height: plane.height) as GeometryEntity
            
        case let .sphere(sphere):
            SphereEntity(radius: sphere.radius) as GeometryEntity
            
        case let .cylinder(cylinder):
            CylinderEntity(radius: cylinder.radius,
                           length: cylinder.height,
                           shape: .surface) as GeometryEntity
            
        case let .cone(cone):
            ConeEntity(topRadius: cone.topRadius,
                       bottomRadius: cone.bottomRadius,
                       length: cone.height,
                       shape: .surface) as GeometryEntity
            
        case let .torus(torus, beginAngle, deltaAngle):
            TorusEntity(meanRadius: torus.meanRadius,
                        tubeRadius: torus.tubeRadius,
                        tubeBegin: deltaAngle > 1.5 * .pi ? .zero : beginAngle,
                        tubeAngle: deltaAngle > 1.5 * .pi ? .twoPi : deltaAngle) as GeometryEntity
        }
        
        entity.name = object.name
        entity.transform = Transform(matrix: object.extrinsics)
        entity.data = object
        return entity
    }
}

extension Array where Element == (any Material) {
    
    static var mesh: [any Material] {
        return [UnlitMaterial(color: .blue).wireframe]
    }
    
    static var plane: [any Material] {
        return [UnlitMaterial(color: .red)]
    }
    
    static var sphere: [any Material] {
        return [UnlitMaterial(color: .green)]
    }
    
    static var cylinder: [any Material] {
        return [UnlitMaterial(color: .purple)]
    }
    
    static var cone: [any Material] {
        return [UnlitMaterial(color: .cyan)]
    }
    
    static var torus: [any Material] {
        return [UnlitMaterial(color: .yellow)]
    }
}

extension ModelEntity {
    
    class func generatePointcloudEntity(name: String, 
                                        points: [simd_float3],
                                        size: Float = 0.01,
                                        materials: [any Material],
                                        opacity: Float = 1.0,
                                        transform: Transform = .identity
    ) async -> ModelEntity? {
        
        guard let mesh = try? await MeshResource.generatePointcloud(name: name, points: points, size: size) else {
            return nil
        }
        
        let entity = ModelEntity(mesh: mesh, materials: materials)
        entity.name = name
        entity.components.set(OpacityComponent(opacity: opacity))
        entity.transform = transform
        return entity
    }
    
    class func generatePointcloudEntity(from object: PersistentObject) async -> ModelEntity? {
        
        let name = "\(object.name) (inliers)"
        let materials: [any Material] = switch object.geometry {
        case .plane:    .plane
        case .sphere:   .sphere
        case .cylinder: .cylinder
        case .cone:     .cone
        case .torus:    .torus
        }
        return await generatePointcloudEntity(name: name,
                                              points: [],
//                                              points: object.inliers,
                                              materials: materials,
                                              opacity: 0.5,
                                              transform: Transform(matrix: object.extrinsics))
    }
}
