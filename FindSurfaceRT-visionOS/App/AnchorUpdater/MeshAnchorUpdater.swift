//
//  MeshAnchorUpdater.swift
//  FindSurfaceRT-visionOS
//
//  Created by CurvSurf-SGKim on 10/11/24.
//

import ARKit

@Observable
final class MeshAnchorUpdater {
    
    private let dataProvider: SceneReconstructionProvider
    
    init(_ dataProvider: SceneReconstructionProvider) {
        self.dataProvider = dataProvider
    }
    
    @MainActor
    func updateAnchors(
        added anchorAdded: @MainActor (MeshAnchor) async -> Void,
        updated anchorUpdated: @MainActor (MeshAnchor) async -> Void,
        removed anchorRemoved: @MainActor (MeshAnchor) async -> Void
    ) async {
        for await update in dataProvider.anchorUpdates {
            let anchor = update.anchor
            switch update.event {
            case .added:    await anchorAdded(anchor)
            case .updated:  await anchorUpdated(anchor)
            case .removed:  await anchorRemoved(anchor)
            }
        }
    }
}
