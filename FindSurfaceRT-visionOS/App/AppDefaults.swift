//
//  AppStorage.swift
//  FindSurfaceRR-visionOS
//
//  Created by CurvSurf-SGKim on 7/17/24.
//

import Foundation
import SwiftUI

import FindSurface_visionOS

extension FindSurface {
    
    enum DefaultKey: String, UserDefaults.Key {
        case measurementAccuracy = "measurement-accuracy"
        case meanDistance = "mean-distance"
        case seedRadius = "seed-radius"
        case lateralExtension = "lateral-extension"
        case radialExpansion = "radial-expansion"
        case allowsConeToCylinderConversion = "allows-cone-to-cylinder-conversion"
        case allowsTorusToSphereConversion = "allows-torus-to-sphere-conversion"
        case allowsTorusToCylinderConversion = "allows-torus-to-cylinder-conversion"
    }
    
    var defaultLoaded: Self {
        loadFromUserDefaults()
        return self
    }
    
    func loadFromUserDefaults() {
        let storage = UserDefaults.Adapter<DefaultKey>()
        measurementAccuracy = storage.float(forKey: .measurementAccuracy) ?? 0.015
        meanDistance = storage.float(forKey: .meanDistance) ?? 0.15
        seedRadius = storage.float(forKey: .seedRadius) ?? 0.15
        lateralExtension = storage.enum(forKey: .lateralExtension) ?? .lv10
        radialExpansion = storage.enum(forKey: .radialExpansion) ?? .lv5
        allowsCylinderInsteadOfCone = storage.bool(forKey: .allowsConeToCylinderConversion) ?? true
        allowsCylinderInsteadOfTorus = storage.bool(forKey: .allowsTorusToSphereConversion) ?? true
        allowsSphereInsteadOfTorus = storage.bool(forKey: .allowsTorusToCylinderConversion) ?? true
    }
    
    func saveToUserDefaults() {
        let storage = UserDefaults.Adapter<DefaultKey>()
        storage.set(measurementAccuracy, forKey: .measurementAccuracy)
        storage.set(meanDistance, forKey: .meanDistance)
        storage.set(seedRadius, forKey: .seedRadius)
        storage.set(lateralExtension, forKey: .lateralExtension)
        storage.set(radialExpansion, forKey: .radialExpansion)
        storage.set(allowsCylinderInsteadOfCone, forKey: .allowsConeToCylinderConversion)
        storage.set(allowsCylinderInsteadOfTorus, forKey: .allowsTorusToCylinderConversion)
        storage.set(allowsSphereInsteadOfTorus, forKey: .allowsTorusToSphereConversion)
    }
}
