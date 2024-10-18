//
//  AnimationSystem.swift
//  FindSurfaceRR-visionOS
//
//  Created by CurvSurf-SGKim on 8/6/24.
//

import Foundation
import RealityKit

class AnimationSystem: System {
    
    private static let query = EntityQuery(where: .has(AnimationComponent.self))
    required init(scene: RealityKit.Scene) {}
    
    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let component = entity.components[AnimationComponent.self] else { continue }
            component.onUpdate(entity)
        }
    }
}
