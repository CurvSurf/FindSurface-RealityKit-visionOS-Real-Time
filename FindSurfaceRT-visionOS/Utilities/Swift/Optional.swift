//
//  Optional.swift
//  FindSurfaceRR-visionOS
//
//  Created by CurvSurf-SGKim on 8/29/24.
//

import Foundation

extension Optional {
    
    func map<T>(_ transform: (Wrapped) -> T) -> T? {
        guard case let .some(wrapped) = self else {
            return nil
        }
        return transform(wrapped)
    }
}
