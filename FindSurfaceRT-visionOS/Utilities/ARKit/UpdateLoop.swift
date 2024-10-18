//
//  UpdateLoop.swift
//  FindSurfaceRR-visionOS
//
//  Created by CurvSurf-SGKim on 8/19/24.
//

import Foundation

@MainActor
func run(withFrequency hz: UInt64, function: @escaping () async -> Void) async {
    while true {
        if Task.isCancelled {
            return
        }
        
        let nanosecondsToSleep: UInt64 = NSEC_PER_SEC / hz
        
        do {
            try await Task.sleep(nanoseconds: nanosecondsToSleep)
        } catch {
            return
        }
        
        Task {
            await function()
        }
    }
}
