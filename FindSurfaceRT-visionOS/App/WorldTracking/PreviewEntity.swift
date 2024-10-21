//
//  PreviewEntity.swift
//  FindSurfaceRR-visionOS
//
//  Created by CurvSurf-SGKim on 8/7/24.
//

import Foundation
import RealityKit

import FindSurface_visionOS

final class PreviewEntity: Entity {
    
    private let plane: PlaneEntity
    private let sphere: SphereEntity
    private let cylinder: CylinderEntity
    private let cone: ConeEntity
    private let torus: TorusEntity
    
    required init() {
        
        let plane = PlaneEntity(preview: true)
        plane.name = "Preview Plane"
        
        let sphere = SphereEntity(preview: true)
        sphere.name = "Preview Sphere"
        
        let cylinder = CylinderEntity(preview: true)
        cylinder.name = "Preview Cylinder"
        
        let cone = ConeEntity(preview: true)
        cone.name = "Preview Cone"
        
        let torus = TorusEntity(preview: true)
        torus.name = "Preview Torus"
        
        self.plane = plane
        self.sphere = sphere
        self.cylinder = cylinder
        self.cone = cone
        self.torus = torus
        super.init()
        
        addChild(plane)
        addChild(sphere)
        addChild(cylinder)
        addChild(cone)
        addChild(torus)
        setPreviewVisibility()
    }
    
    func setPreviewVisibility(plane planeVisible: Bool = false,
                              sphere sphereVisible: Bool = false,
                              cylinder cylinderVisible: Bool = false,
                              cone coneVisible: Bool = false,
                              torus torusVisible: Bool = false) {
        plane.isVisible = planeVisible
        sphere.isVisible = sphereVisible
        cylinder.isVisible = cylinderVisible
        cone.isVisible = coneVisible
        torus.isVisible = torusVisible
    }
    
    func update(_ result: FindSurface.Result) async {
        
        switch result {
        case let .foundPlane(object, _, _):
            plane.update { intrinsics in
                intrinsics.width = object.width
                intrinsics.height = object.height
            }
            plane.transform = Transform(matrix: object.extrinsics)
            setPreviewVisibility(plane: true)
            
        case let .foundSphere(object, _, _):
            sphere.update { intrinsics in
                intrinsics.radius = object.radius
            }
            sphere.transform = Transform(matrix: object.extrinsics)
            setPreviewVisibility(sphere: true)
            
        case let .foundCylinder(object, _, _):
            cylinder.update { intrinsics in
                intrinsics.radius = object.radius
                intrinsics.length = object.height
            }
            cylinder.transform = Transform(matrix: object.extrinsics)
            setPreviewVisibility(cylinder: true)
            
        case let .foundCone(object, _, _):
            cone.update { intrinsics in
                intrinsics.topRadius = object.topRadius
                intrinsics.bottomRadius = object.bottomRadius
                intrinsics.length = object.height
            }
            cone.transform = Transform(matrix: object.extrinsics)
            setPreviewVisibility(cone: true)
            
        case let .foundTorus(object, inliers, _):
            torus.update { intrinsics in
                intrinsics.meanRadius = object.meanRadius
                intrinsics.tubeRadius = object.tubeRadius
                var (begin, delta) = object.calcAngleRange(from: inliers)
                if delta > 1.5 * .pi {
                    begin = 0.0
                    delta = 2.0 * .pi
                }
                intrinsics.tubeBegin = begin
                intrinsics.tubeAngle = delta
            }
            torus.transform = Transform(matrix: object.extrinsics)
            setPreviewVisibility(torus: true)
            
        case .none(_):
            setPreviewVisibility()
        }
    }
}
