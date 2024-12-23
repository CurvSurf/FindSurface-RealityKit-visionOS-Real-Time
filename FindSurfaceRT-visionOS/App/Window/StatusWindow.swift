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
    
    required init() {
        super.init()
        isVisible = false
    }
    
    func look(at deviceTransform: simd_float4x4,
              from hand: HandEntity) {
        
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
        look(at: devicePosition, from: position, relativeTo: nil, forward: .positiveZ)
    }
}
