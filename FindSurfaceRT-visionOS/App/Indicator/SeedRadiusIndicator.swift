//
//  SeedRadiusIndicator.swift
//  FindSurfaceST-visionOS
//
//  Created by CurvSurf-SGKim on 7/2/24.
//

import Foundation
import RealityKit
import SwiftUI
import Combine
import _RealityKit_SwiftUI

import FindSurface_visionOS

struct RadiusLabel: View {
    @Environment(FindSurface.self) private var findSurface
    var body: some View {
        let radius = String(format: "%.1f", findSurface.seedRadius * 100)
        Text("\(radius) cm")
            .padding()
            .glassBackgroundEffect()
    }
}

final class SeedRadiusIndicator: Entity {
    
    var radius: Float = 1.0 {
        didSet {
            guard oldValue != radius else { return }
            guard radius > 0 else {
                self.isVisible = false
                return
            }
            if oldValue < 0 && radius > 0 {
                self.isVisible = true
            }
            line.transform.scale = .init(radius, 1, 1)
            line.transform.translation = .init(radius * 0.5, 0, 0)
            ring.model?.mesh = .generateTorus(meanRadius: radius, tubeRadius: 0.005)
            plate.transform.scale = .init(radius, 1, radius)
            label?.position = .init(radius * 0.5, 0, 0.05)
        }
    }
    
    private let line: ModelEntity
    private let center: ModelEntity
    private let ring: ModelEntity
    private let plate: ModelEntity
    var label: ViewAttachmentEntity? = nil {
        didSet {
            if let oldValue {
                removeChild(oldValue)
            }
            if let label {
                addChild(label)
                label.position = .init(radius * 0.5, 0, 0.05)
            }
        }
    }
    
    required init() {
        
        let lineMesh = MeshResource.generateBox(width: 1.0, height: 0.004, depth: 0.004)
        let lineMaterial = UnlitMaterial(color: .black)
        let line = ModelEntity(mesh: lineMesh, materials: [lineMaterial])
        line.transform.translation = .init(0.5, 0, 0)
        
        let centerMesh = MeshResource.generateSphere(name: "", radius: 0.005)
        let centerMaterial = UnlitMaterial(color: .black)
        let center = ModelEntity(mesh: centerMesh, materials: [centerMaterial])
        
        let rotation = simd_quatf(from: .init(0, 1, 0), to: .init(0, 0, 1))
        
        let ringMesh = MeshResource.generateTorus(meanRadius: 1.0, tubeRadius: 0.005)
        let ringMaterial = UnlitMaterial(color: .black)
        let ring = ModelEntity(mesh: ringMesh, materials: [ringMaterial])
        ring.transform = .init(rotation: rotation)
        
        let plateMesh = MeshResource.generateCylinder(height: 0.001, radius: 1.0)
        let plateMaterial = UnlitMaterial(color: .blue.withAlphaComponent(0.2))
        let plate = ModelEntity(mesh: plateMesh, materials: [plateMaterial])
        plate.transform = .init(rotation: rotation)
        
        self.line = line
        self.center = center
        self.ring = ring
        self.plate = plate
        super.init()
        isVisible = false
        addChild(line)
        addChild(center)
        addChild(ring)
        addChild(plate)
    }
    
    private var gestureBeingProcessed: Bool = false
    private var initialRadius: Float = 0
    
    func locate(from leftHand: HandEntity,
                _ rightHand: HandEntity,
                _ magnification: Float,
                and deviceTransform: simd_float4x4) {
        
        guard leftHand.isTracked && rightHand.isTracked else {
            isVisible = false
            return
        }
        
        let devicePosition = deviceTransform.position
        
        if !gestureBeingProcessed {
            gestureBeingProcessed = true
            initialRadius = FindSurface.instance.seedRadius
            
            if let leftIndexFingerPosition = leftHand.jointPosition(.indexFingerTip),
               let rightIndexFingerPosition = rightHand.jointPosition(.indexFingerTip) {
                let centerPosition = (leftIndexFingerPosition + rightIndexFingerPosition) / 2
                position = centerPosition + 0.50 * normalize(centerPosition - devicePosition)
            }
        }
        
        isVisible = true
        look(at: devicePosition, from: self.position, relativeTo: nil, forward: .positiveZ)
        
        let radius = min(max(initialRadius * magnification, 0.05), 10)
        FindSurface.instance.seedRadius = radius
        self.radius = radius
    }
    
    func updateFinished() {
        gestureBeingProcessed = false
        isVisible = false
    }
}
