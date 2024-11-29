//
//  StatusView.swift
//  FindSurfaceRR-visionOS
//
//  Created by CurvSurf-SGKim on 9/2/24.
//

import Foundation
import SwiftUI

struct StatusView: View {
    
    @Environment(FoundTimer.self) private var timer
    @Environment(AppState.self) private var state
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                let fps = String(format: "%3d fps", Int(timer.foundFps.rounded()))
                Label(fps, systemImage: "f.square.fill")
                    .imageScale(.large)
                    .font(.body.bold().monospaced())
                
                let rmsError = String(format: "%.2f cm", state.latestRMSerror * 100)
                Label(rmsError, systemImage: "space")
                    .imageScale(.medium)
                    .font(.body.bold().monospaced())
            }
            let points = "\(state.meshVertexManager.vertexCount) pts."
            Label(points, systemImage: "p.square.fill")
                .imageScale(.large)
                .font(.body.bold().monospaced())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            FPSGraphView(queue: timer.fpsRecords,
                         lowerbound:    0.0,
                         upperbound: 400,
                         unlimited: true)
            .padding(1)
        )
        .background(RoundedRectangle(cornerRadius: 8).stroke(.white, lineWidth: 1))
        .padding(.top)
    }
}

fileprivate let timer = FoundTimer(eventsCount: 5)

#Preview {
    
    StatusView()
        .environment(timer)
        .environment(AppState())
        .task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            timer.record(found: true)
            for _ in 0...180 {
                try? await Task.sleep(nanoseconds: UInt64(Double.random(in: 0.002...0.008) * 1_000_000_000))
                timer.record(found: true)
            }
        }
        .frame(width: 380)
}
