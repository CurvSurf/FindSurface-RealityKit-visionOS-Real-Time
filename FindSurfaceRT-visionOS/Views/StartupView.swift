//
//  StartupView.swift
//  FindSurfaceRR-visionOS
//
//  Created by CurvSurf-SGKim on 6/12/24.
//

import SwiftUI
import RealityKit

struct StartupView: View {

    @Environment(SessionManager.self) private var sessionManager
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack {
            AppTitle()
            IntroductionText()
            Proclaimer()
            
            if !sessionManager.canEnterImmersiveSpace {
                PermissionOverlayView()
            }
            
            HStack {
                OpenUserGuideButton()
                EnterImmersiveSpaceButton(immersiveSpaceAvailable: sessionManager.canEnterImmersiveSpace)
            }
            .padding(.top, 10)
        }
        .padding(.vertical, 24)
        .fixedSize()
        .onChange(of: scenePhase, initial: true) {
            if scenePhase == .active {
                Task {
                    await sessionManager.queryRequiredAuthorizations()
                }
            }
        }
        .task {
            if sessionManager.allRequiredProvidersAreSupported {
                await sessionManager.requestRequiredAuthorizations()
            }
        }
        .task {
            await sessionManager.monitorSessionEvents { error in
//                openWindow(sceneID: SceneID.error, value: ErrorCode.sessionErrorOccurred(.init(from: error)))
            }
        }
    }
}

fileprivate struct PermissionOverlayView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    
    @Environment(SessionManager.self) private var sessionManager
    
    var body: some View {
        VStack {
            
            Text("⚠️ Permissions Not Granted ⚠️")
                .foregroundStyle(.red)
                .padding(.top, 8)
                .padding(.bottom, 2)
            
            Text("Please tap **Go to Settings** button below to open the Settings app and enable the following permissions:")
                .font(.footnote)
                .fontWeight(.light)
                .padding(.horizontal, 30)
                .fixedSize(horizontal: false, vertical: true)
            
            VStack(alignment: .leading) {
                
                if sessionManager.handTrackingAuthorizationStatus != .allowed {
                    Label {
                        Text("Hand Structure And Movements")
                    } icon: {
                        Image(systemName: "hand.point.up.fill")
                            .imageScale(.small)
                            .rotationEffect(.degrees(-15))
                            .padding(6)
                            .background(
                                LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .top, endPoint: .bottom)
                            )
                            .clipShape(.circle)
                            .padding(.leading, 2.1)
                            .padding(.trailing, 2)
                    }
                }
                
                if sessionManager.worldSensingAuthorizationStatus != .allowed {
                    Label {
                        Text("Surroundings")
                    } icon: {
                        Image(systemName: "camera.metering.multispot")
                            .imageScale(.small)
                            .padding(6)
                            .background(
                                LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .top, endPoint: .bottom)
                            )
                            .clipShape(.circle)
                    }
                }
            }
            
            Button("Go to Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        }
        .padding(.vertical, 8)
        .frame(width: 360)
    }
}

fileprivate struct AppTitle: View {
    var body: some View {
        Text("FindSurfaceRT for visionOS")
            .font(.title)
            .padding(.bottom, 10)
    }
}

fileprivate struct IntroductionText: View {
    var body: some View {
        
        Text("Find and measure 3D surface geometries in your physical environment with continuous preview.")
            .font(.subheadline)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 30)
            .frame(width: 400)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 16)
    }
}

fileprivate struct Proclaimer: View {
    var body: some View {
        
        Text("PROCLAIMER")
            .font(.footnote.bold())
        
        Text("This app uses the vertex data extracted from MeshAnchor, so it may not detect or accurately detect objects with a size (approximate diameter or width) less than 1 meter.")
            .font(.caption)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 30)
            .frame(width: 400)
            .fixedSize(horizontal: false, vertical: true)
    }
}

fileprivate struct OpenUserGuideButton: View {
    
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        Button("User Guide") {
            openWindow(sceneID: SceneID.userGuide, value: SceneID.userGuide)
        }
    }
}

fileprivate struct EnterImmersiveSpaceButton: View {
    
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) private var dismiss
    
    let immersiveSpaceAvailable: Bool
    
    var body: some View {
        Button(immersiveSpaceAvailable ? "Enter" : "Not Available") {
            Task { await tryEnterImmersiveSpace() }
        }
        .disabled(immersiveSpaceAvailable == false)
    }
    
    @MainActor
    private func tryEnterImmersiveSpace() async {
        switch await openImmersiveSpace(sceneID: SceneID.immersiveSpace) {
        case .opened: dismiss()
        case .error:
            await dismissImmersiveSpace()
//            openWindow(sceneID: SceneID.error, value: ErrorCode.openImmersiveSpaceFailed)
        // TODO: leave a log
        case .userCancelled: fallthrough
        @unknown default:
            await dismissImmersiveSpace()
        }
    }
}

#Preview(windowStyle: .plain) {
    StartupView()
        .environment(SessionManager())
        .glassBackgroundEffect()
}
