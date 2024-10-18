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
        
    }
    
    func look(at devicePosition: simd_float3,
              from hand: HandEntity) {
        
        guard hand.isTracked,
              let wristTransform = hand.jointTransform(.forearmWrist)else {
            isVisible = false
            return
        }
        
        isVisible = true
        
        let wristPosition = wristTransform.position
        let wristUp = -wristTransform.basisY
        
        var position = (wristPosition + 0.35 * wristUp)/* * 0.1 + self.position * 0.9*/
        position = mix(position, self.position, t: 0.90)
//        position = position * 0.10 + self.position * 0.90
        look(at: devicePosition, from: position, relativeTo: nil, forward: .positiveZ)
    }
}
