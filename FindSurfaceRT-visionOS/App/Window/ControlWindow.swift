//
//  ControlWindow.swift
//  FindSurfaceRT-visionOS
//
//  Created by CurvSurf-SGKim on 10/8/24.
//

import ARKit
import RealityKit

import _RealityKit_SwiftUI

final class ControlWindow: Entity {
    
    var controlView: ViewAttachmentEntity? = nil {
        didSet {
            if let oldValue {
                oldValue.removeFromParent()
            }
            if let controlView {
                addChild(controlView)
            }
        }
    }
    
    var confirmView: ViewAttachmentEntity? = nil {
        didSet {
            if let oldValue {
                oldValue.removeFromParent()
            }
            if let confirmView {
                addChild(confirmView)
                confirmView.isVisible = false
                confirmView.setPosition(.init(0, 0, 0.10), relativeTo: self)
            }
        }
    }
        
    required init() {
        
    }
    
    private var contactCount: Int = 0
    
    func look(at deviceTransform: simd_float4x4, from hand: HandEntity) {
        
        guard hand.isTracked,
              let thumbPosition = hand.jointPosition(.thumbTip),
              let middleFingerPosition = hand.jointPosition(.middleFingerTip),
              distance_squared(thumbPosition, middleFingerPosition) < 0.0001,
              let wristPosition = hand.jointPosition(.wrist) else {
            
            return
        }
        
        let devicePosition = deviceTransform.position
        let deviceRight = deviceTransform.basisX
        
        let contactPosition = (thumbPosition + middleFingerPosition) / 2
        let contactDirection = normalize(contactPosition - wristPosition)
        let outwardDirection = normalize(.init(-contactDirection.z, 0, contactDirection.x))
        
        var position = wristPosition + normalize(outwardDirection + contactDirection) * 0.3 + .init(0, 0.2, 0) - deviceRight * 0.30
        position = mix(position, self.position, t: 0.80)
        
        look(at: devicePosition, from: position, relativeTo: nil, forward: .positiveZ)
    }
    
    
    func locate(from hand: HandEntity, andDeviceTransform deviceTransform: simd_float4x4) {
        
        guard hand.isTracked else {
            contactCount = max(contactCount - 1, 0)
            return
        }
        
        let devicePosition = deviceTransform.position
        let deviceRight = deviceTransform.basisX
        
        guard let thumbPosition = hand.jointPosition(.thumbTip),
              let middleFingerPosition = hand.jointPosition(.middleFingerTip),
              let wristPosition = hand.jointPosition(.wrist) else {
            contactCount = max(contactCount - 1, 0)
            return
        }
        
        if distance_squared(thumbPosition, middleFingerPosition) < 0.0001 {
            contactCount = min(contactCount + 1, 5)
        } else {
            contactCount = max(contactCount - 1, 0)
        }
        
        guard contactCount > 3 else { return }
        
        let contactPosition = (thumbPosition + middleFingerPosition) * 0.5
        let direction = normalize(contactPosition - wristPosition)
        let outward = normalize(.init(-direction.z, 0, direction.x))
        
        let windowPosition = wristPosition + normalize(outward + direction) * 0.3 + .init(0, 0.2, 0) - deviceRight * 0.30
        
        look(at: devicePosition, from: windowPosition, relativeTo: nil, forward: .positiveZ)
    }
}
