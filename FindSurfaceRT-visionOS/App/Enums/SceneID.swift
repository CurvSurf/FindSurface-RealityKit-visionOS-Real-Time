//
//  SceneID.swift
//  FindSurfaceRR-visionOS
//
//  Created by CurvSurf-SGKim on 7/16/24.
//

import Foundation
import SwiftUI

enum SceneID: String, Codable, SceneIDProtocol {
    case startup = "StartupView"
    case immersiveSpace = "ImmersiveView"
    case inspector = "InspectorView"
    case userGuide = "UserGuideView"
    case restartGuide = "RestartGuideView"
}
