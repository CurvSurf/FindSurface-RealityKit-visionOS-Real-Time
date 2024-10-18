//
//  FindSurfaceRT_visionOSApp.swift
//  FindSurfaceRT-visionOS
//
//  Created by CurvSurf-SGKim on 9/23/24.
//

import SwiftUI

import FindSurface_visionOS

@main
@MainActor
struct FindSurfaceRT_visionOSApp: App {
    
    @State private var sessionManager = SessionManager()
    @State private var appState = AppState()
    @State private var findSurface = FindSurface.instance
    @State private var scenePhaseTracker = ScenePhaseTracker()
    @State private var timer = FoundTimer(eventsCount: 150)
    
    init() {}
    
    var body: some Scene {
        
        WindowGroup(sceneID: SceneID.startup, for: SceneID.self) { _ in
            StartupView()
                .environment(sessionManager)
                .trackingScenePhase(by: scenePhaseTracker, sceneID: .startup)
                .glassBackgroundEffect()
        }
        .windowResizability(.contentSize)
        .windowStyle(.plain)
        
        ImmersiveSpace(sceneID: SceneID.immersiveSpace) {
            ImmersiveView()
                .environment(appState)
                .environment(findSurface)
                .environment(sessionManager)
                .environment(scenePhaseTracker)
                .environment(timer)
                .trackingScenePhase(by: scenePhaseTracker, sceneID: .immersiveSpace)
        }
        
        WindowGroup(sceneID: SceneID.userGuide, for: SceneID.self) { _ in
            UserGuideView()
                .environment(scenePhaseTracker)
                .trackingScenePhase(by: scenePhaseTracker, sceneID: .userGuide)
                .glassBackgroundEffect()
        }
        .windowResizability(.contentSize)
        .windowStyle(.plain)

    }
}
