//
//  FindSurface.swift
//  FindSurfaceRR-visionOS
//
//  Created by CurvSurf-SGKim on 7/17/24.
//

import Foundation
import simd
import SwiftUI

import FindSurface_visionOS

extension FindSurface {
    
    /// Determines whether to output a `cylinder` as a result when the target feature is set to `cone`.
    ///
    /// If set to `true`, `cylinder`s are considered as detected results; if set to `false`, they are discarded.
    var allowsCylinderInsteadOfCone: Bool {
        get {
            conversionOptions.contains(.coneToCylinder)
        }
        set {
            if newValue {
                conversionOptions.insert(.coneToCylinder)
            } else {
                conversionOptions.remove(.coneToCylinder)
            }
        }
    }
    
    /// Determines whether to output a `cylinder` as a result when the target feature is set to `torus`.
    ///
    /// If set to `true`, `cylinder`s are considered as detected results; if set to `false`, they are discarded.
    var allowsCylinderInsteadOfTorus: Bool {
        get { conversionOptions.contains(.torusToCylinder) }
        set {
            if newValue {
                conversionOptions.insert(.torusToCylinder)
            } else {
                conversionOptions.remove(.torusToCylinder)
            }
        }
    }
    
    /// Determines whether to output a `sphere` as a result when the target feature is set to `torus`.
    ///
    /// If set to `true`, `sphere`s are considered as detected results; if set to `false`, they are discarded.
    var allowsSphereInsteadOfTorus: Bool {
        get { conversionOptions.contains(.torusToSphere) }
        set {
            if newValue {
                conversionOptions.insert(.torusToSphere)
            } else {
                conversionOptions.remove(.torusToSphere)
            }
        }
    }
    
}

extension FindSurface.Result {
    
    mutating func alignGeometryAndTransformInliers(devicePosition: simd_float3,
                                                   _ enableFullConeConversion: Bool,
                                                   _ fullConeRadiiRatioThreshold: Float) {
        
        switch self {
            
        case let .foundPlane(plane, inliers, rmsError):
            let plane = plane.aligned(withCamera: devicePosition)
            let transform = plane.transform
            let inliers = inliers.map { simd_make_float3(transform * simd_float4($0, 1)) }
            self = .foundPlane(plane, inliers, rmsError)
            
        case let .foundSphere(sphere, inliers, rmsError):
            let transform = sphere.transform
            let inliers = inliers.map { simd_make_float3(transform * simd_float4($0, 1)) }
            self = .foundSphere(sphere, inliers, rmsError)
        
        case let .foundCylinder(cylinder, inliers, rmsError):
            let cylinder = cylinder.aligned()
            let transform = cylinder.transform
            let inliers = inliers.map { simd_make_float3(transform * simd_float4($0, 1)) }
            self = .foundCylinder(cylinder, inliers, rmsError)
        
        case let .foundCone(cone, inliers, rmsError):
            let cone = if enableFullConeConversion &&
                          (cone.topRadius / cone.bottomRadius) <= Float(fullConeRadiiRatioThreshold) {
                {
                    let slope = cone.height / (cone.bottomRadius - cone.topRadius)
                    let newHeight = cone.bottomRadius * slope
                    let displacement = abs(newHeight - cone.height)
                    let translate = -cone.axis * displacement * 0.5
                    let extrinsics = .extrinsics(position: translate) * cone.extrinsics
                    return Cone(height: newHeight, topRadius: 0, bottomRadius: cone.bottomRadius, extrinsics: extrinsics)
                }()
            } else {
                cone
            }
            let transform = cone.transform
            let inliers = inliers.map { simd_make_float3(transform * simd_float4($0, 1)) }
            self = .foundCone(cone, inliers, rmsError)
        
        case let .foundTorus(torus, inliers, rmsError):
            let torus = torus.aligned()
            let transform = torus.transform
            let inliers = inliers.map { simd_make_float3(transform * simd_float4($0, 1)) }
            self = .foundTorus(torus, inliers, rmsError)
        
        case .none(_): break
        }
    }
}
