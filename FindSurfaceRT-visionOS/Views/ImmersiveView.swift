//
//  ImmersiveView.swift
//  FindSurfaceRR-visionOS
//
//  Created by CurvSurf-SGKim on 6/12/24.
//

import ARKit
import SwiftUI
import RealityKit
import AVKit
import simd

import Combine

import FindSurface_visionOS

@MainActor
struct ImmersiveView: View {
    
    private enum AttachmentKey: Hashable, CaseIterable {
        case control
        case radius
        case status
        case confirm
    }
    
    @Environment(\.scenePhase) private var scenePhase
    
    @Environment(AppState.self) private var state
    @Environment(FindSurface.self) private var findSurface
    @Environment(SessionManager.self) private var sessionManager
    @Environment(ScenePhaseTracker.self) private var scenePhaseTracker
    @Environment(FoundTimer.self) private var timer
    
    init() {
        AnimationSystem.registerSystem()
        AnimationComponent.registerComponent()
        PersistentDataComponent.registerComponent()
    }
    
    var body: some View {
        
        RealityView { content, attachments in
            await make(&content, attachments)
        } attachments: {
            attachments()
        }
        .upperLimbVisibility(.automatic)
        .task {
            await sessionManager.monitorSessionEvents(onError: { _ in () })
        }
        .task {
            await state.processSceneReconstructionUpdates()
        }
        .task {
            await state.processWorldTrackingUpdates()
        }
        .task {
            await state.processDeviceTrackingUpdates()
        }
        .task {
            await state.processHandTrackingUpdates()
        }
        .task {
            await state.restartFindSurfaceLoop()
        }
        .onSpatialTapGesture(target: state.meshVertexManager.rootEntity, action: onTapGesture(_:_:))
        .gesture(state.magnifyGesture)
        .onAppear {
            onAppear()
        }
        .onDisappear {
            onDisappear()
        }
        .onChange(of: scenePhase) {
            if scenePhase != .active {
                onScenePhaseNotActive()
            }
        }
    }
    
    private func make(_ content: inout RealityViewContent, _ attachments: RealityViewAttachments) async {
        
        content.add(state.rootEntity)
        
        if let controlAttachment = attachments.entity(for: AttachmentKey.control) {
            state.controlWindow.controlView = controlAttachment
        }
        
        if let radiusAttachment = attachments.entity(for: AttachmentKey.radius) {
            state.seedRadiusIndicator.label = radiusAttachment
        }
        
        if let statusAttachment = attachments.entity(for: AttachmentKey.status) {
            state.statusWindow.statusView = statusAttachment
        }
        
        if let confirmAttachment = attachments.entity(for: AttachmentKey.confirm) {
            state.controlWindow.confirmView = confirmAttachment
        }
        
        Task {
            await sessionManager.run(with: state.dataProviders)
        }
    }
    
    @AttachmentContentBuilder
    private func attachments() -> some AttachmentContent {
        
        Attachment(id: AttachmentKey.control) {
            ControlView()
                .environment(scenePhaseTracker)
                .environment(sessionManager)
                .environment(state)
                .environment(timer)
                .environment(findSurface)
        }
        
        Attachment(id: AttachmentKey.radius) {
            RadiusLabel()
                .environment(findSurface)
        }
        
        Attachment(id: AttachmentKey.status) {
            StatusView()
                .environment(state)
                .environment(state.timer)
                .frame(width: 320)
        }
    }
    
    private func onTapGesture(_ location: simd_float3, _ entity: Entity) {
        if state.findSurfaceEnabled {
            state.shouldTakeNextPreviewAsResult = true
        }
    }
    
    private func onAppear() {
        FindSurface.instance.loadFromUserDefaults()
    }
    
    private func onDisappear() {
        FindSurface.instance.saveToUserDefaults()
    }
    
    private func onScenePhaseNotActive() {
        FindSurface.instance.saveToUserDefaults()
    }
}
