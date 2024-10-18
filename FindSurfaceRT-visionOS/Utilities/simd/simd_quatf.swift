//
//  simd_quatf.swift
//  FindSurfaceRR-visionOS
//
//  Created by CurvSurf-SGKim on 8/6/24.
//

import Foundation
import simd

extension simd_quatf {
    var eulerAngles: SIMD3<Float> {
        let ysqr = self.imag.y * self.imag.y
        
        let t0 = 2.0 * (self.real * self.imag.x + self.imag.y * self.imag.z)
        let t1 = 1.0 - 2.0 * (self.imag.x * self.imag.x + ysqr)
        let roll = atan2(t0, t1)
        
        let t2 = 2.0 * (self.real * self.imag.y - self.imag.z * self.imag.x)
        let pitch: Float
        if t2 > 1.0 {
            pitch = .pi / 2.0 // clamp to 90 degrees
        } else if t2 < -1.0 {
            pitch = -.pi / 2.0 // clamp to -90 degrees
        } else {
            pitch = asin(t2)
        }
        
        let t3 = 2.0 * (self.real * self.imag.z + self.imag.x * self.imag.y)
        let t4 = 1.0 - 2.0 * (ysqr + self.imag.z * self.imag.z)
        let yaw = atan2(t3, t4)
        
        return SIMD3<Float>(roll, pitch, yaw)
    }
}
