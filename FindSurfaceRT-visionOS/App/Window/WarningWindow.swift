//
//  WarningWindow.swift
//  FindSurfaceRT-visionOS
//
//  Created by CurvSurf-SGKim on 11/4/24.
//

import RealityKit
import _RealityKit_SwiftUI
import Foundation

final class WarningWindow: Entity {
    static let maxCount: Int = 100_000
    static let maxCountLabel: String = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: maxCount)) ?? "\(maxCount)"
    }()
    static let maxCountShortLabel: String = {
        return "\(maxCount / 1_000)k"
    }()
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
        let opacity: Float = (count > Self.maxCount) ? 1.0 : (count > Self.maxCount - 5_000 && !dismissed) ? 0.5 : 0.0
        self.components.set(OpacityComponent(opacity: opacity))
    }
}
