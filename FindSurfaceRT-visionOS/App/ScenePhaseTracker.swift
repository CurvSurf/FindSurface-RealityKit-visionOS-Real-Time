//
//  ScenePhaseTracker.swift
//  FindSurfaceRR-visionOS
//
//  Created by CurvSurf-SGKim on 9/3/24.
//

import Foundation

@Observable
final class ScenePhaseTracker: ScenePhaseTrackerProtocol {
    var activeScene: Set<SceneID> = []
}
