//
//  MeshResource.swift
//  FindSurfaceST-visionOS
//
//  Created by CurvSurf-SGKim on 6/17/24.
//

import Foundation
import RealityKit
import simd
import Algorithms
import ARKit

extension MeshResource {
    
    static func generate(name: String = "", from submesh: Submesh) throws -> MeshResource {
        
        var descriptor = name.isEmpty ? MeshDescriptor() : MeshDescriptor(name: name)
        descriptor.positions = MeshBuffer(submesh.positions)
        if !submesh.normals.allSatisfy({ normal in
            normal == .zero
        }) {
            descriptor.normals = MeshBuffer(submesh.normals)
        }
        if !submesh.texcoords.allSatisfy({ texcoord in
            texcoord == .zero
        }) {
            descriptor.textureCoordinates = MeshBuffer(submesh.texcoords)
        }
        descriptor.primitives = .triangles(submesh.triangleIndices)
        
        return try MeshResource.generate(from: [descriptor])
    }
}

// Plane
extension MeshResource {
    static func generateCube(name: String = "",
                             width: Float, height: Float, depth: Float,
                             insideOut: Bool = false) -> MeshResource {
        
        let submesh = Submesh.generateCube(width: width, height: height, depth: depth)
        
        return try! .generate(name: name, from: insideOut ? submesh.inverted : submesh)
    }
}

// Sphere
extension MeshResource {
    
    static func generateSphere(name: String = "",
                               radius: Float,
                               subdivision: SphereSubdivision = .sphericalCoordinates,
                               insideOut: Bool = false) -> MeshResource {
        let submesh = Submesh.generateSphere(radius: radius, subdivision: subdivision)
        return try! .generate(name: name, from: insideOut ? submesh.inverted : submesh)
    }
}

// Cylinder
extension MeshResource {
    
    static func generateCylinder(name: String = "",
                                 radius: Float,
                                 length: Float,
                                 subdivision: CylinderSubdivision = .both(36, 3),
                                 insideOut: Bool = false) -> MeshResource {
        
        let submesh = Submesh.generateCylinder(radius: radius,
                                               length: length,
                                               subdivision: subdivision)
        return try! .generate(name: name, from: insideOut ? submesh.inverted : submesh)
    }
    
    static func generateCylindricalSurface(name: String = "",
                                           radius: Float,
                                           length: Float,
                                           subdivision: CylinderSubdivision = .both(36, 3),
                                           insideOut: Bool = false) -> MeshResource {
        
        let submesh = Submesh.generateCylindricalSurface(radius: radius,
                                                         length: length,
                                                         subdivision: subdivision)
        return try! .generate(name: name, from: insideOut ? submesh.inverted : submesh)
    }
    
    static func generateVolumetricCylindricalSurface(
        name: String = "",
        radius: Float,
        length: Float,
        padding: Float,
        subdivision: CylinderSubdivision = .both(36, 3),
        insideOut: Bool = false
    ) -> MeshResource {
        
        let submesh = Submesh.generateVolumetricCylindricalSurface(
            radius: radius,
            length: length,
            padding: padding,
            subdivision: subdivision)
        return try! .generate(name: name, from: insideOut ? submesh.inverted : submesh)
    }
}

// Cone
extension MeshResource {
    
    static func generateCone(name: String = "",
                             topRadius: Float,
                             bottomRadius: Float,
                             length: Float,
                             padding: Float = 0.0,
                             subdivision: ConeSubdivision = .both(36, 2),
                             insideOut: Bool = false) -> MeshResource {
    
        let submesh = Submesh.generateCone(topRadius: topRadius,
                                           bottomRadius: bottomRadius,
                                           length: length,
                                           padding: padding,
                                           subdivision: subdivision)
        return try! .generate(name: name, from: insideOut ? submesh.inverted : submesh)
    }
    
    static func generateConicalSurface(name: String = "",
                                       topRadius: Float,
                                       bottomRadius: Float,
                                       length: Float,
                                       subdivision: ConeSubdivision = .both(36, 2),
                                       insideOut: Bool = false) -> MeshResource {
        let submesh = Submesh.generateConicalSurface(topRadius: topRadius,
                                                     bottomRadius: bottomRadius,
                                                     length: length,
                                                     subdivision: subdivision)
        return try! .generate(name: name, from: insideOut ? submesh.inverted : submesh)
    }
    
    static func generateVolumetricConicalSurface(name: String = "",
                                                 topRadius: Float,
                                                 bottomRadius: Float,
                                                 length: Float,
                                                 padding: Float,
                                                 subdivision: ConeSubdivision = .both(36, 2),
                                                 insideOut: Bool = false) -> MeshResource {
        let submesh = Submesh.generateVolumetricConicalSurface(topRadius: topRadius,
                                                               bottomRadius: bottomRadius,
                                                               length: length,
                                                               padding: padding,
                                                               subdivision: subdivision)
        return try! .generate(name: name, from: insideOut ? submesh.inverted : submesh)
    }
}

// Torus
extension MeshResource {
    
    static func generateTorus(name: String = "",
                              meanRadius: Float,
                              tubeRadius: Float,
                              tubeBegin: Float = .zero,
                              tubeAngle: Float = .twoPi,
                              padding: Float = 0.0,
                              subdivision: TorusSubdivision = .both(36, 36),
                              insideOut: Bool = false) -> MeshResource {
        
        let submesh = Submesh.generateTorus(meanRadius: meanRadius,
                                            tubeRadius: tubeRadius,
                                            tubeBegin: tubeBegin,
                                            tubeAngle: tubeAngle,
                                            padding: padding,
                                            subdivision: subdivision)
        return try! .generate(name: name, from: insideOut ? submesh.inverted : submesh)
    }
    
    static func generateToricSurface(name: String = "",
                                     meanRadius: Float,
                                     tubeRadius: Float,
                                     tubeBegin: Float = .zero,
                                     tubeAngle: Float = .twoPi,
                                     subdivision: TorusSubdivision = .both(36, 36),
                                     insideOut: Bool = false) -> MeshResource {
        
        let submesh = Submesh.generateToricSurface(meanRadius: meanRadius,
                                                   tubeRadius: tubeRadius,
                                                   tubeBegin: tubeBegin,
                                                   tubeAngle: tubeAngle,
                                                   subdivision: subdivision)
        return try! .generate(name: name, from: insideOut ? submesh.inverted : submesh)
    }
    
    static func generateVolumetricToricSurface(name: String = "",
                                               meanRadius: Float,
                                               tubeRadius: Float,
                                               tubeBegin: Float = .zero,
                                               tubeAngle: Float = .twoPi,
                                               padding: Float,
                                               subdivision: TorusSubdivision = .both(36, 36),
                                               insideOut: Bool = false) -> MeshResource {
        
        let submesh = Submesh.generateVolumetricToricSurface(meanRadius: meanRadius,
                                                             tubeRadius: tubeRadius,
                                                             tubeBegin: tubeBegin,
                                                             tubeAngle: tubeAngle,
                                                             padding: padding,
                                                             subdivision: subdivision)
        return try! .generate(name: name, from: insideOut ? submesh.inverted : submesh)
    }
}

// Pointcloud
extension MeshResource {
    
    static func generatePointcloud(name: String = "", points: [simd_float3], size: Float = 0.01) async throws -> MeshResource {
        
        let _submesh = Submesh.generateCube(width: size, height: size, depth: size)
        let _positions = _submesh.positions
        let _normals = _submesh.normals
        let _texcoords = _submesh.texcoords
        let _triangleIndices = _submesh.triangleIndices
        
        var positions = [simd_float3](); positions.reserveCapacity(_positions.count * points.count)
        var normals = [simd_float3](); normals.reserveCapacity(_normals.count * points.count)
        var texcoords = [simd_float2](); texcoords.reserveCapacity(_texcoords.count * points.count)
        var triangleIndices = [UInt32](); triangleIndices.reserveCapacity(_triangleIndices.count * points.count)
        var cubeVertexCount = UInt32(_positions.count)
        
        for point in points {
            positions.append(contentsOf: _positions.map { $0 + point })
            normals.append(contentsOf: _normals)
            texcoords.append(contentsOf: _texcoords)
            triangleIndices.append(contentsOf: _triangleIndices.map { $0 + cubeVertexCount })
        }
        let submesh = Submesh(positions: positions,
                              normals: normals,
                              texcoords: texcoords,
                              triangleIndices: triangleIndices)
        
        return try MeshResource.generate(from: submesh)
//        let model0 = mesh.contents.instances["MeshModel-0"]
//        let modelName = model0!.model
//        
//        let instances: [MeshResource.Instance] = points.enumerated().map { index, point in
//            let transform = Transform(translation: point).matrix
//            return MeshResource.Instance(id: "MeshModel-\(index + 1)",
//                                         model: modelName,
//                                         at: transform)
//        }
//        
//        var contents = MeshResource.Contents()
//        contents.models = mesh.contents.models
//        contents.instances = MeshInstanceCollection(instances)
        
//        return try await MeshResource(from: contents)
    }
}
