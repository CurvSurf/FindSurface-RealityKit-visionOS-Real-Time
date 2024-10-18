//
//  ControlView.swift
//  FindSurfaceRR-visionOS
//
//  Created by CurvSurf-SGKim on 7/16/24.
//

import Foundation
import SwiftUI

import FindSurface_visionOS

struct ControlView: View {
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    @Environment(ScenePhaseTracker.self) private var scenePhaseTracker
    @Environment(AppState.self) private var state
    @Environment(FindSurface.self) private var findSurface
    
    @AppStorage("allow-feature-type-any")
    private var allowFeatureTypeAny: Bool = false
    
    var body: some View {
        @Bindable var findSurface = findSurface
                
        VStack {
            Section {
                VStack(alignment: .leading) {
                    FeatureTypePicker(type: $findSurface.targetFeature,
                                      allowAny: allowFeatureTypeAny)
                        .onChange(of: allowFeatureTypeAny) {
                            if !allowFeatureTypeAny && findSurface.targetFeature == .any {
                                findSurface.targetFeature = .plane
                            }
                        }
                    
                    ControlViewTextField(label: "     Accuracy [cm]",
                                         value: $findSurface.measurementAccuracy.mapMeterToCentimeter(),
                                         lowerbound: 0.3,
                                         upperbound: 10.0)
                    ControlViewTextField(label: "Mean Distance [cm]",
                                         value: $findSurface.meanDistance.mapMeterToCentimeter(),
                                         lowerbound: 1.0,
                                         upperbound: 50.0)
                    ControlViewTextField(label: "  Seed Radius [cm]",
                                         value: $findSurface.seedRadius.mapMeterToCentimeter(),
                                         lowerbound: 5.0,
                                         upperbound: 1000.0)
                    
                    ControlViewLevelPicker(label: "Lateral Extension", level: $findSurface.lateralExtension)
                    
                    ControlViewLevelPicker(label: " Radial Expansion", level: $findSurface.radialExpansion)
                    
                    PreviewToggleButton()
                    
                    ClearButton()
                }
                .makeWidthMinMaxGroup(name: "ControlViewTextField")
                .makeWidthMinMaxGroup(name: "ControlViewLevelPicker")
            } header: {
                HStack {
                    Text("Controls")
                        .font(.title.monospaced())
                    Spacer()
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 8).stroke(.white, lineWidth: 1))
        .frame(width: allowFeatureTypeAny ? 380 : 320)
    }
}

extension SearchLevel {
    
    var label: String {
        switch self {
        case .off: return "Off"
        case .lv1: return "Level 1"
        case .lv2: return "Level 2"
        case .lv3: return "Level 3"
        case .lv4: return "Level 4"
        case .lv5: return "Level 5"
        case .lv6: return "Level 6"
        case .lv7: return "Level 7"
        case .lv8: return "Level 8"
        case .lv9: return "Level 9"
        case .lv10: return "Level 10"
        }
    }
}

#Preview("ControlView", windowStyle: .plain) {
    ControlView()
        .environment(ScenePhaseTracker())
        .environment(AppState())
        .environment(FoundTimer(eventsCount: 5))
        .environment(FindSurface.instance.defaultLoaded)
}

fileprivate struct ControlViewMonospacedLabel: View {
    let text: String
    let groupName: String
    var body: some View {
        Text(text)
            .font(.subheadline.monospaced())
            .multilineTextAlignment(.trailing)
            .fixedSize(horizontal: true, vertical: false)
            .lineLimit(1)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            .joinWidthMinMaxGroup(name: groupName)
    }
}

fileprivate struct ControlViewTextField: View {
    
    let label: String
    @Binding var value: Float
    let lowerbound: Float
    let upperbound: Float
    
    var body: some View {
        HStack {
            ControlViewMonospacedLabel(text: label, groupName: "ControlViewTextField")
            TextField("", value: $value, formatter: .decimal(1)) { finished in
                if finished {
                    value = min(max(value, lowerbound), upperbound)
                }
            }
            .multilineTextAlignment(.trailing)
            .textFieldStyle(.plain)
            .keyboardType(.decimalPad)
            .font(.caption.monospaced())
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .cornerRadius(4)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
            .padding(.vertical, 2)
        }
    }
}

fileprivate struct ControlViewLevelPicker: View {
    
    let label: String
    @Binding var level: SearchLevel
    
    var body: some View {
        HStack {
            ZStack {
                ControlViewMonospacedLabel(text: "\(label): \(SearchLevel.lv10)", groupName: "ControlViewLevelPicker")
                    .hidden()
                
                ControlViewMonospacedLabel(text: "\(label): \(level)", groupName: "ControlViewLevelPicker")
            }
            let rawBinding = $level.wrap { level in
                level.rawValue
            } unwrap: { rawValue in
                SearchLevel(rawValue: rawValue)!
            }

            Stepper("", value: rawBinding, in: 0...10)
                .controlSize(.mini)
        }
    }
}
