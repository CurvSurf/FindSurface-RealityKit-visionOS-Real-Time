//
//  PersistentObject.swift
//  FindSurfaceST-visionOS
//
//  Created by CurvSurf-SGKim on 6/18/24.
//

import Foundation
import simd
import RealityKit
import SwiftUI

import SwiftData

import FindSurface_visionOS

actor PersistentDataModel {
    
    let container: ModelContainer
    private let context: ModelContext
    
    static let shared = PersistentDataModel()
    private init() {
        do {
            let container = try ModelContainer(for: PersistentObject2.self)
            let context = ModelContext(container)
            
            self.container = container
            self.context = context
        } catch {
            fatalError("Failed to create the model container: \(error)")
        }
    }
    
    var count: Int {
        let descriptor = FetchDescriptor<PersistentObject2>(predicate: .true)
        do {
            return try context.fetchCount(descriptor)
        } catch {
            fatalError("Failed to count objects: \(error)")
        }
    }
    
    func register(_ object: PersistentObject2) {
        context.insert(object)
    }
    
    func find(forID uuid: UUID) -> PersistentObject2? {
        let descriptor = FetchDescriptor<PersistentObject2>(predicate: #Predicate { $0.uuid == uuid })
        do {
            return try context.fetch(descriptor).first
        } catch {
            fatalError("Failed to fetch object: \(error)")
        }
    }
    
    @discardableResult
    func deregister(forID uuid: UUID) -> PersistentObject2? {
        if let object = find(forID: uuid) {
            context.delete(object)
            return object
        }
        return nil
    }
    
    func deregister(_ object: PersistentObject2) {
        context.delete(object)
    }
    
    var objects: [PersistentObject2] {
        let descriptor = FetchDescriptor<PersistentObject2>(predicate: .true)
        do {
            return try context.fetch(descriptor)
        } catch {
            fatalError("Failed to fetch objects: \(error)")
        }
    }
    
    func save() {
        try! context.save()
    }
}

enum Geometry: Hashable, Codable {
    case plane(Plane)
    case sphere(Sphere)
    case cylinder(Cylinder)
    case cone(Cone)
    case torus(Torus, Float, Float)
    
    var extrinsics: simd_float4x4 {
        get {
            switch self {
            case let .plane(plane):         return plane.extrinsics
            case let .sphere(sphere):       return sphere.extrinsics
            case let .cylinder(cylinder):   return cylinder.extrinsics
            case let .cone(cone):           return cone.extrinsics
            case let .torus(torus, _, _):   return torus.extrinsics
            }
        }
        set {
            switch self {
            case var .plane(plane):
                plane.extrinsics = newValue
                self = .plane(plane)
                
            case var .sphere(sphere):
                sphere.extrinsics = newValue
                self = .sphere(sphere)
                
            case var .cylinder(cylinder):
                cylinder.extrinsics = newValue
                self = .cylinder(cylinder)
                
            case var .cone(cone):
                cone.extrinsics = newValue
                self = .cone(cone)
                
            case .torus(var torus, let beginAngle, let deltaAngle):
                torus.extrinsics = newValue
                self = .torus(torus, beginAngle, deltaAngle)
            }
        }
    }
}

struct PendingObject {
    let name: String
    let geometry: Geometry
    let inliers: [simd_float3]
    let rmsError: Float
    let creationDate: Date
}

@Model
final class PersistentObject2 {

    private(set) var uuid: UUID
    @Attribute(.unique) private(set) var name: String
    var geometry: Geometry
    var inliers: [simd_float3]
    private(set) var rmsError: Float
    private(set) var creationDate: Date
    
    init(uuid: UUID, name: String, geometry: Geometry,
         inliers: [simd_float3],
         rmsError: Float, createdAt creationDate: Date = .now) {
        self.uuid = uuid
        self.name = name
        self.geometry = geometry
        self.inliers = inliers
        self.rmsError = rmsError
        self.creationDate = creationDate
    }
    
    var extrinsics: simd_float4x4 {
        get { geometry.extrinsics }
        set { geometry.extrinsics = newValue }
    }
}

protocol PersistentProtocol {
    var name: String { get }
    var inliers: [simd_float3] { get set }
    var rmsError: Float { get }
    
    var extrinsics: simd_float4x4 { get set }
}

extension PersistentObject2 {
    
    convenience init(from object: PendingObject, forID id: UUID) {
        self.init(uuid: id,
                  name: object.name,
                  geometry: object.geometry,
                  inliers: object.inliers,
                  rmsError: object.rmsError,
                  createdAt: object.creationDate)
    }
}
