//
//  WarningWindow.swift
//  FindSurfaceRT-visionOS
//
//  Created by CurvSurf-SGKim on 11/4/24.
//

import RealityKit
import _RealityKit_SwiftUI

final class WarningWindow: Entity {
    
    var warningView: ViewAttachmentEntity? = nil {
        didSet {
            if let oldValue {
                oldValue.removeFromParent()
            }
            if let warningView {
                addChild(warningView)
            }
        }
    }
    
    required init() {
        super.init()
    }
    
    func look(at devicePosition: simd_float3, and deviceDirection: simd_float3) {
        
        let position = mix(devicePosition + 1.0 * deviceDirection, self.position, t: 0.80)
        look(at: devicePosition, from: position, relativeTo: nil, forward: .positiveZ)
    }
    
    private var dismissed: Bool = false
    func dismiss() {
        dismissed = true
    }
    
    func checkCount(_ count: Int) {
        let opacity: Float = (count > 50_000) ? 1.0 : (count > 45_000 && !dismissed) ? 0.5 : 0.0
        self.components.set(OpacityComponent(opacity: opacity))
    }
}
