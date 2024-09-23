//
//  FindSurfaceRT_visionOSApp.swift
//  FindSurfaceRT-visionOS
//
//  Created by CurvSurf-SGKim on 9/23/24.
//

import SwiftUI

@main
struct FindSurfaceRT_visionOSApp: App {

    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
     }
}
