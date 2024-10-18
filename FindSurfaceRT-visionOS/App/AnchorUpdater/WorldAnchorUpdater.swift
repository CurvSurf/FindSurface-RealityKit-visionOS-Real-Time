//
//  WorldAnchorUpdater.swift
//  FindSurfaceRT-visionOS
//
//  Created by CurvSurf-SGKim on 10/11/24.
//

import ARKit

@Observable
final class WorldAnchorUpdater {
    
    private let dataProvider: WorldTrackingProvider
    
    init(_ dataProvider: WorldTrackingProvider) {
        self.dataProvider = dataProvider
    }
    
    private(set) var activeAnchorIDs: Set<UUID> = []
    
    @MainActor
    func updateAnchors(
        added anchorAdded: @MainActor (WorldAnchor) async -> Void,
        updated anchorUpdated: @MainActor (WorldAnchor) async -> Void,
        removed anchorRemoved: @MainActor (WorldAnchor) async -> Void
    ) async {
        for await update in dataProvider.anchorUpdates {
            let anchor = update.anchor
            switch update.event {
            case .added:
                activeAnchorIDs.insert(anchor.id)
                await anchorAdded(anchor)
            case .updated:
                await anchorUpdated(update.anchor)
            case .removed:
                activeAnchorIDs.remove(anchor.id)
                await anchorRemoved(update.anchor)
            }
        }
    }
    
    func addAnchor(_ anchor: WorldAnchor) async throws {
        try await dataProvider.addAnchor(anchor)
    }
    
    func removeAnchor(_ anchor: WorldAnchor) async throws {
        try await dataProvider.removeAnchor(anchor)
    }
    
    func removeActiveAnchors() async throws {
        for anchorID in activeAnchorIDs {
            try await dataProvider.removeAnchor(forID: anchorID)
        }
    }
    
    func removeAllAnchors() async throws {
        guard let allAnchors = await dataProvider.allAnchors else { return }
        for anchor in allAnchors {
            try await dataProvider.removeAnchor(anchor)
        }
    }
}

