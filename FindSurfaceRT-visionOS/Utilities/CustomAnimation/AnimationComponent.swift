//
//  AnimationComponent.swift
//  FindSurfaceRR-visionOS
//
//  Created by CurvSurf-SGKim on 8/6/24.
//

import Foundation
import RealityKit

struct AnimationComponent: Component {
    let identifier: String
    let onUpdate: (Entity) -> Void
    
    init(identifier: String, onUpdate: @escaping (Entity) -> Void) {
        self.identifier = identifier
        self.onUpdate = onUpdate
    }
}

import Combine

extension ModelEntity {
    
    func playAnimation<T: AnimatableData & BindableData>(
        name: String = "",
        from beginValue: T,
        to endValue: T,
        by stepValue: T? = nil,
        duration: TimeInterval = 1.0,
        timing: AnimationTimingFunction = .linear,
        isAdditive: Bool = false,
        blendLayer: Int32 = 0,
        repeatMode: AnimationRepeatMode = .none,
        fillMode: AnimationFillMode = [],
        trimStart: TimeInterval? = nil,
        trimEnd: TimeInterval? = nil,
        trimDuration: TimeInterval? = nil,
        offset: TimeInterval = 0,
        delay: TimeInterval = 0,
        speed: Float = 1.0,
        onUpdate: @escaping (ModelEntity, T) -> Void,
        onCompletion completionHandler: @escaping () -> Void
    ) -> AnyCancellable? {
        
        parameters[name] = BindableValue(beginValue)
        let component = AnimationComponent(identifier: name) { [weak self] _ in
            guard let self,
                  let value = self.bindableValues[.parameter(name), T.self]?.value else { return }
            onUpdate(self, value)
        }
        components.set(component)
        
        let animation = FromToByAnimation(name: name,
                                          from: beginValue,
                                          to: endValue,
                                          by: stepValue,
                                          duration: duration,
                                          timing: timing,
                                          isAdditive: isAdditive,
                                          bindTarget: .parameter(name),
                                          blendLayer: blendLayer,
                                          repeatMode: repeatMode,
                                          fillMode: fillMode,
                                          trimStart: trimStart,
                                          trimEnd: trimEnd,
                                          trimDuration: trimDuration,
                                          offset: offset,
                                          delay: delay,
                                          speed: speed)
        let resource = try! AnimationResource.generate(with: animation)
        let controller = playAnimation(resource)
        
        return scene?.publisher(for: AnimationEvents.PlaybackCompleted.self)
            .filter { $0.playbackController == controller }
            .sink { _ in completionHandler() }
    }
}
