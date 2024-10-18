//
//  HandAnchorUpdater.swift
//  FindSurfaceRT-visionOS
//
//  Created by CurvSurf-SGKim on 10/11/24.
//

import ARKit
import RealityKit

@Observable
final class HandAnchorUpdater {
    
    private let dataProvider: HandTrackingProvider
    
    let rootEntity: Entity
    
    let rightHand: HandEntity
    let leftHand: HandEntity
    
    init(_ dataProvider: HandTrackingProvider) {
        
        let rootEntity = Entity()
        
        let rightHand = HandEntity()
        rootEntity.addChild(rightHand)
        
        let leftHand = HandEntity()
        rootEntity.addChild(leftHand)
        
        self.dataProvider = dataProvider
        
        self.rootEntity = rootEntity
        self.rightHand = rightHand
        self.leftHand = leftHand
    }
    
    @MainActor
    func updateAnchors(updated anchorUpdated: @MainActor (AnchorUpdate<HandAnchor>.Event, HandAnchor.Chirality, HandEntity) async -> Void) async {
        for await update in dataProvider.anchorUpdates {
            let anchor = update.anchor
            switch anchor.chirality {
            case .left:     leftHand.update(anchor)
            case .right:    rightHand.update(anchor)
            }
            await anchorUpdated(update.event, anchor.chirality, anchor.chirality == .left ? leftHand : rightHand)
        }
    }
}
