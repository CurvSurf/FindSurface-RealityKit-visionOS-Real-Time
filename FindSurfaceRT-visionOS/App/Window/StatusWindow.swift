//
//  StatusWindow.swift
//  FindSurfaceRT-visionOS
//
//  Created by CurvSurf-SGKim on 10/17/24.
//

import ARKit
import RealityKit
import _RealityKit_SwiftUI

final class StatusWindow: Entity {
    
    var statusView: ViewAttachmentEntity? = nil {
        didSet {
            if let oldValue {
                oldValue.removeFromParent()
            }
            if let statusView {
                addChild(statusView)
            }
        }
    }
    
//    private let thumb: ModelEntity
//    private let middleFinger: ModelEntity
    
    required init() {
//        let sphere = MeshResource.generateSphere(radius: 0.0075)
//        let thumbMaterial = UnlitMaterial(color: .red)
//        let middleFingerMaterial = UnlitMaterial(color: .blue)
//        let thumb = ModelEntity(mesh: sphere, materials: [thumbMaterial])
//        let middleFinger = ModelEntity(mesh: sphere, materials: [middleFingerMaterial])
//        self.thumb = thumb
//        self.middleFinger = middleFinger
        super.init()
//        addChild(thumb, preservingWorldTransform: true)
//        addChild(middleFinger, preservingWorldTransform: true)
        isVisible = false
    }
    
    private var contactCount: Int = 0
//    private var tracking: Bool = true
    
    func look(at deviceTransform: simd_float4x4,
              from hand: HandEntity) {
        
//        guard hand.isTracked else {
//            print("hand is not tracked")
//            return
//        }
//        
//        guard let thumbPosition = hand.jointPosition(.thumbTip) else {
//            print("thumb is not tracked")
//            return
//        }
//        thumb.setPosition(thumbPosition, relativeTo: nil)
//        
//        guard let middleFingerPosition = hand.jointPosition(.middleFingerTip) else {
//            print("middle finger is not tracked")
//            return
//        }
//        middleFinger.setPosition(middleFingerPosition, relativeTo: nil)
//        
//        guard distance_squared(thumbPosition, middleFingerPosition) < (0.015 * 0.015) else {
//            print("distance is not satisfied")
//            return
//        }
//        
//        guard let wristPosition = hand.jointPosition(.wrist) else {
//            print("wrist is not tracked")
//            return
//        }
        
        guard hand.isTracked,
              let thumbPosition = hand.jointPosition(.thumbTip),
              let middleFingerPosition = hand.jointPosition(.middleFingerTip),
              distance_squared(thumbPosition, middleFingerPosition) < (0.015 * 0.015),
              let wristPosition = hand.jointPosition(.wrist) else {
            return
        }
        
        if isVisible == false {
            isVisible = true
        }

        let devicePosition = deviceTransform.position
        let deviceRight = deviceTransform.basisX
        
        let contactPosition = (thumbPosition + middleFingerPosition) / 2
        let contactDirection = normalize(contactPosition - wristPosition)
        let outwardDirection = normalize(.init(contactDirection.z, 0, -contactDirection.x))
        
        var position = wristPosition + normalize(outwardDirection + contactDirection) * 0.3 + .init(0, 0.2, 0) /*- deviceRight * 0.30*/
        position = mix(position, self.position, t: 0.80)
//        let wristPosition = wristTransform.position
//        let wristUp = -wristTransform.basisY
//        
//        var position = (wristPosition + 0.35 * wristUp)/* * 0.1 + self.position * 0.9*/
//        position = mix(position, self.position, t: 0.90)
////        position = position * 0.10 + self.position * 0.90
        look(at: devicePosition, from: position, relativeTo: nil, forward: .positiveZ)
    }
}
