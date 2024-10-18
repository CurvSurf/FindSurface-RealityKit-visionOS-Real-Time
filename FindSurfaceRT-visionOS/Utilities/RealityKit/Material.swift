//
//  Material.swift
//  FindSurfaceST-visionOS
//
//  Created by CurvSurf-SGKim on 6/17/24.
//

import Foundation
import RealityKit

protocol HasTriangleFillMode: Material {
    
    typealias TriangleFillMode = MaterialParameterTypes.TriangleFillMode
    
    var triangleFillMode: TriangleFillMode { get set }
}

extension HasTriangleFillMode {
    
    var wireframe: Self {
        var material = self
        material.triangleFillMode = .lines
        return material
    }
}

extension UnlitMaterial: HasTriangleFillMode {}
extension SimpleMaterial: HasTriangleFillMode {}
extension VideoMaterial: HasTriangleFillMode {}
extension PortalMaterial: HasTriangleFillMode {}
extension ShaderGraphMaterial: HasTriangleFillMode {}
extension PhysicallyBasedMaterial: HasTriangleFillMode {}
