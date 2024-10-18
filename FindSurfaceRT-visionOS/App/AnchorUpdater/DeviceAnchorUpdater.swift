//
//  DeviceTracker.swift
//  FindSurfaceRT-visionOS
//
//  Created by CurvSurf-SGKim on 10/8/24.
//

import ARKit
import simd
import AVKit

@Observable
final class DeviceAnchorUpdater {
    
    private let worldTracking: WorldTrackingProvider
    
    init(_ dataProvider: WorldTrackingProvider) {
        self.worldTracking = dataProvider
    }
    
    private(set) var transform = simd_float4x4(1.0)
    
    @MainActor
    func updateAnchor(updated: @escaping (simd_float4x4) async -> Void) async {
        await run(withFrequency: 90) { [self] in
            guard worldTracking.state == .running,
                  let anchor = worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()),
                  anchor.isTracked else { return }
            
            var transform = anchor.originFromAnchorTransform
            let rotation = simd_quatf(angle: .pi / 18, axis: -transform.basisX)
            transform.basisY = rotation.act(transform.basisY)
            transform.basisZ = rotation.act(transform.basisZ)
            self.transform = transform
            
            await updated(transform)
        }
    }
}
