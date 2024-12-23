//
//  WarningView.swift
//  FindSurfaceRT-visionOS
//
//  Created by CurvSurf-SGKim on 11/4/24.
//

import SwiftUI

struct WarningView: View {
    
    @Environment(AppState.self) private var state
    
    @State private var expanded: Bool = false
    
    var body: some View {
        let exceeded = state.meshVertexManager.vertexCount >= WarningWindow.maxCount
        VStack {
            Text("⚠️ Warning ⚠️")
                .foregroundStyle(exceeded ? .red : .primary)
                .font(.title)
            
            Text("Maximum points limit \(exceeded ? "exceeded" : "approaching")")
                .font(.title3)
                .padding(.bottom)
            
            Text(exceeded ? "The number of point cloud has been exceeded the operational limit. FindSurface will cease the detection. Please restart the app by following the instruction below." : "The number of point cloud is approaching the operational limit, defined at approximately \(WarningWindow.maxCountLabel) points. Exceeding the limit will cause FindSurface to cease the detection. Try not to scan too broad areas.")
                .font(.body)
                .frame(width: 400)
                .padding(.horizontal)
            VStack(alignment: .leading) {
                Section(isExpanded: $expanded) {
                    Text("`FindSurfaceFramework` (including `FindSurface-visionOS` package) provides its functionality for non-commercial purposes within Apple Vision Pro devices. It is internally limited to process input point clouds of **\(WarningWindow.maxCountShortLabel) points or less**. For commercial uses or use cases that require more than \(WarningWindow.maxCountShortLabel) points, please contact to support@curvsurf.com.")
                        .font(.caption)
                } header: {
                    Button {
                        withAnimation {
                            expanded.toggle()
                        }
                    } label: {
                        Label {
                            Text("Why is there a limit on the number of points?")
                        } icon: {
                            Image(systemName: expanded ? "chevron.down" : "chevron.right")
                        }
                        .font(.caption)
                    }
                    .buttonStyle(.plain)
                }
                .frame(width: 400)
                .padding(.horizontal)
            }
            
            if exceeded {
                RestartGuideView()
            } else {
                Button(role: .cancel) {
                    state.warningWindow.dismiss()
                } label: {
                    Text("Dismiss")
                        .padding()
                }
                .font(.body.bold())
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical)
        .frame(width: 450)
        .padding()
    }
}
