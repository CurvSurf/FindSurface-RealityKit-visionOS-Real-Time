//
//  FPSTimer.swift
//  FindSurfaceRR-visionOS
//
//  Created by CurvSurf-SGKim on 8/27/24.
//

import Foundation
import SwiftUI

@Observable
public final class FoundTimer {
    
    public struct EventRecord {
        let timestamp: UInt64 = DispatchTime.now().uptimeNanoseconds
        let found: Bool
    }
    private var eventRecords: Queue<EventRecord>
    public private(set) var fpsRecords: Queue<Double>
    
    var foundFps: Double = 0
    
    public init(eventsCount eventsCapacity: Int, fpsCount fpsCapacity: Int = 90) {
        self.eventRecords = .init(capacity: eventsCapacity)
        self.fpsRecords = .init(capacity: fpsCapacity)
    }
    
    public func resize(eventsCount: Int) {
        eventRecords.resize(capacity: eventsCount)
    }
    
    public func resize(fpsCount: Int) {
        fpsRecords.resize(capacity: fpsCount)
    }
    
    public func record(found: Bool) {
        eventRecords.enqueue(.init(found: found))
        
        let founds = eventRecords.filter { $0.found }
        
        guard founds.count > 1 else {
            foundFps = 0
            fpsRecords.enqueue(0)
            return
        }
        
        let sortedFounds = founds.sorted { lhs, rhs in
            lhs.timestamp > rhs.timestamp
        }
        
        let latest = sortedFounds[0]
        let previous = sortedFounds[1]
        
        guard latest.timestamp != previous.timestamp else {
            foundFps = 0
            fpsRecords.enqueue(0)
            return
        }
        
        let timeInterval = Double(latest.timestamp - previous.timestamp)
        
        let fps = 1_000_000_000 / timeInterval
        foundFps = fps
        fpsRecords.enqueue(fps)
    }
}
