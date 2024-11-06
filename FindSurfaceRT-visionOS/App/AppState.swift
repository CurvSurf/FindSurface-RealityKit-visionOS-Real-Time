//
//  AppState.swift
//  FindSurfaceRT-visionOS
//
//  Created by CurvSurf-SGKim on 10/2/24.
//

import SwiftUI
import ARKit
import RealityKit
import AVKit
import simd
import Combine
import SwiftData

import FindSurface_visionOS

let resultPreservationTime: ContinuousClock.Duration = .milliseconds(200)

@Observable
final class AppState {
    
    private let findSurface = FindSurface.instance
    
    private let sceneReconstruction: SceneReconstructionProvider
    private let worldTracking: WorldTrackingProvider
    private let handTracking: HandTrackingProvider
    var dataProviders: [DataProvider] { [sceneReconstruction, worldTracking, handTracking] }
    
    private let meshAnchorUpdater: MeshAnchorUpdater
    let worldAnchorUpdater: WorldAnchorUpdater
    private let deviceAnchorUpdater: DeviceAnchorUpdater
    private let handAnchorUpdater: HandAnchorUpdater
    
    let rootEntity: Entity
    
    var meshVertexManager: MeshVertexManager
    var geometryManager: GeometryManager
    let previewEntity: PreviewEntity
    
    let controlWindow: ControlWindow
    private var shouldInitializeControlWindowPosition: Bool = true
    
    var showConfirmWindow: Bool {
        get {
            access(keyPath: \.showConfirmWindow)
            return controlWindow.confirmView?.isVisible ?? false
        }
        set {
            withMutation(keyPath: \.showConfirmWindow) {
                controlWindow.confirmView?.isVisible = newValue
            }
        }
    }
    
    private let triangleHighlighter: TriangleHighlighter
    
    let seedRadiusIndicator: SeedRadiusIndicator
    let pickingIndicator: ModelEntity
    
    let statusWindow: StatusWindow
    
    let timer = FoundTimer(eventsCount: 180)

    let warningWindow: WarningWindow
    
    private var _latestResult: (FindSurface.Result, simd_float3, Double)? = nil
    
    private func getLatestResult(_ location: simd_float3) -> FindSurface.Result? {
        guard let _latestResult else { return nil }
        let (result, latestLocation, timestamp) = _latestResult
        
        if case .none(_) = result { return nil }
        
        let current = Double(DispatchTime.now().uptimeNanoseconds) / 1_000_000
        guard current - timestamp < 200.0 else { return nil }
        
        guard distance_squared(location, latestLocation) < 0.01 else { return nil }
        
        return result
    }
    
    private func setLatestResult(_ result: FindSurface.Result?, _ location: simd_float3) {
        if let result {
            let timestamp = Double(DispatchTime.now().uptimeNanoseconds) / 1_000_000
            _latestResult = (result, location, timestamp)
        } else {
            _latestResult = nil
        }
    }
    
    init() {
        
        let sceneReconstruction = SceneReconstructionProvider()
        let worldTracking = WorldTrackingProvider()
        let handTracking = HandTrackingProvider()
    
        let meshAnchorUpdater = MeshAnchorUpdater(sceneReconstruction)
        let worldAnchorUpdater = WorldAnchorUpdater(worldTracking)
        let deviceAnchorUpdater = DeviceAnchorUpdater(worldTracking)
        let handAnchorUpdater = HandAnchorUpdater(handTracking)
        
        let rootEntity = Entity()
        
        let meshVertexManager = MeshVertexManager()
        rootEntity.addChild(meshVertexManager.rootEntity)
        
        let geometryManager = GeometryManager()
        rootEntity.addChild(geometryManager.rootEntity)
        
        let previewEntity = PreviewEntity()
        rootEntity.addChild(previewEntity)
        
        let controlWindow = ControlWindow()
        rootEntity.addChild(controlWindow)
        
        let triangleHighlighter = TriangleHighlighter()
        rootEntity.addChild(triangleHighlighter)
        
        let seedRadiusIndicator = SeedRadiusIndicator()
        rootEntity.addChild(seedRadiusIndicator)
        
        let pickingIndicator = ModelEntity(mesh: .generateSphere(radius: 0.01),
                                           materials: [UnlitMaterial(color: .black)])
        pickingIndicator.components.set(OpacityComponent(opacity: 0.5))
        rootEntity.addChild(pickingIndicator)
        
        let statusWindow = StatusWindow()
        rootEntity.addChild(statusWindow)
        
        let warningWindow = WarningWindow()
        rootEntity.addChild(warningWindow)
        
        self.sceneReconstruction = sceneReconstruction
        self.worldTracking = worldTracking
        self.handTracking = handTracking
        
        self.meshAnchorUpdater = meshAnchorUpdater
        self.worldAnchorUpdater = worldAnchorUpdater
        self.deviceAnchorUpdater = deviceAnchorUpdater
        self.handAnchorUpdater = handAnchorUpdater
        
        self.rootEntity = rootEntity
        
        self.meshVertexManager = meshVertexManager
        self.geometryManager = geometryManager
        self.previewEntity = previewEntity
        self.controlWindow = controlWindow
        self.triangleHighlighter = triangleHighlighter
        self.seedRadiusIndicator = seedRadiusIndicator
        self.pickingIndicator = pickingIndicator
        self.statusWindow = statusWindow
        self.warningWindow = warningWindow
    }
    
    private var findSurfaceSemaphore = DispatchSemaphore(value: 1)
    private var loopTask: Task<(), Never>? = nil
    var findSurfaceEnabled: Bool = false {
        didSet {
            previewEntity.isVisible = findSurfaceEnabled
        }
    }
    var shouldTakeNextPreviewAsResult: Bool = false
    
    @MainActor
    func processSceneReconstructionUpdates() async {
        await meshAnchorUpdater.updateAnchors(added: meshVertexManager.anchorAdded(_:),
                                              updated: meshVertexManager.anchorUpdated(_:),
                                              removed: meshVertexManager.anchorRemoved(_:))
    }
    
    @MainActor
    func processWorldTrackingUpdates() async {
        await worldAnchorUpdater.updateAnchors { anchor in
            if (await geometryManager.anchorAdded(anchor)) == false {
                try? await worldAnchorUpdater.removeAnchor(anchor)
            }
        } updated: { anchor in
            await geometryManager.anchorUpdated(anchor)
        } removed: { anchor in
            await geometryManager.anchorRemoved(anchor)
        }
    }
    
    @MainActor
    func processDeviceTrackingUpdates() async {
        await deviceAnchorUpdater.updateAnchor { transform in
            if self.shouldInitializeControlWindowPosition {
                self.shouldInitializeControlWindowPosition = false
                self.locateControlWindowAroundDevice(transform)
            }
            
            self.warningWindow.look(at: transform.position, and: -transform.basisZ)
            self.warningWindow.checkCount(self.meshVertexManager.vertexCount)
        }
    }
    
    @MainActor
    func processHandTrackingUpdates() async {
        await handAnchorUpdater.updateAnchors { event, chirality, hand in
            let deviceTransform = deviceAnchorUpdater.transform
            switch chirality {
            case .right:
                controlWindow.look(at: deviceTransform, from: hand)
            case .left:
                statusWindow.look(at: deviceTransform.position, from: hand)
            }
        }
    }
    
    @MainActor
    var magnifyGesture: some Gesture {
        MagnifyGesture()
            .targetedToAnyEntity()
            .onChanged { [self] value in
                seedRadiusIndicator.locate(from: handAnchorUpdater.leftHand,
                                       handAnchorUpdater.rightHand,
                                       Float(value.magnification),
                                       and: deviceAnchorUpdater.transform)
            }
            .onEnded { [self] value in
                seedRadiusIndicator.updateFinished()
            }
    }
    
    @MainActor
    func restartFindSurfaceLoop() async {
        if let loopTask {
            loopTask.cancel()
        }
        loopTask = Task.detached {
            while Task.isCancelled == false {
                await self.performFindSurface()
            }
        }
    }
      
    private func performFindSurface() async {
        
        guard Task.isCancelled == false else { return }
        
        let deviceTransform = deviceAnchorUpdater.transform
        let devicePosition = deviceTransform.position
        let deviceDirection = -deviceTransform.basisZ
        
        let targetFeature = findSurface.targetFeature
        
        var result: FindSurface.Result? = nil
    
        guard let hit = await meshVertexManager.raycast(origin: devicePosition, direction: deviceDirection),
              let points = await meshVertexManager.nearestTriangleVertices(hit) else {
            
            timer.record(found: false)
            await previewEntity.setPreviewVisibility()
            await pickingIndicator.setPosition(devicePosition + deviceDirection, relativeTo: nil)
            return
        }
        
        await triangleHighlighter.updateTriangle(points.0, points.1, points.2)
        
        let location = hit.position
        await pickingIndicator.setPosition(location, relativeTo: nil)
        
        guard findSurfaceEnabled else {
            return
        }
        
        await criticalSection {        
            do {
                let _result = try await findSurface.perform {
                    let meshPoints = meshVertexManager.vertices
                    guard let index = meshPoints.firstIndex(of: points.0) else { return nil }
                    return (meshPoints, index)
                }
                
                guard let _result else { return }
                
                result = _result
                return
            } catch {
                return
            }
        }
                         
        guard let result else {
            timer.record(found: false)
            await previewEntity.setPreviewVisibility()
            return
        }
        
        guard Task.isCancelled == false else { return }
        
        Task {
            await processFindSurfaceResult(result, devicePosition, targetFeature, location)
        }
    }
    
    private func criticalSection(_ block: () async -> Void) async {
        await findSurfaceSemaphore.wait()
        
        defer { findSurfaceSemaphore.signal() }
        
        return await block()
    }
    
    private func processFindSurfaceResult(_ result: FindSurface.Result,
                                          _ devicePosition: simd_float3,
                                          _ targetFeature: FeatureType,
                                          _ location: simd_float3) async {
        
        var result = result
        
        result.alignGeometryAndTransformInliers(devicePosition: devicePosition, true, 0.10)
        
        if case .none(_) = result {
            timer.record(found: false)
        } else {
            timer.record(found: true)
            setLatestResult(result, location)
        }
        
        if shouldTakeNextPreviewAsResult {
            shouldTakeNextPreviewAsResult = false
            
            if case .none = result {
                if let latestResult = getLatestResult(location) {
                    setLatestResult(nil, .zero)
                    result = latestResult
                } else {
                    AudioServicesPlaySystemSound(1053)
                    return
                }
            }
            
            AudioServicesPlaySystemSound(1100)
            
            let worldAnchor = await geometryManager.addPendingObject(result)
            do {
                try await worldAnchorUpdater.addAnchor(worldAnchor)
            } catch {
                geometryManager.removePendingObject(forKey: worldAnchor.id)
            }
        } else {
            await previewEntity.update(result)
        }
    }
    
    private func locateControlWindowAroundDevice(_ deviceTransform: simd_float4x4) {
        let devicePosition = deviceTransform.position
        let deviceForward = -deviceTransform.basisZ
        let deviceRight = deviceTransform.basisX
        
        let location = devicePosition + 0.7 * normalize(deviceForward * 2.0 + deviceRight)
        controlWindow.look(at: devicePosition, from: location, relativeTo: nil, forward: .positiveZ)
    }
    
}

extension DispatchSemaphore {
    
    func wait() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                self.wait()
                continuation.resume()
            }
        }
    }
}
