//
//  FPSGraphView.swift
//  FindSurfaceRR-visionOS
//
//  Created by CurvSurf-SGKim on 9/6/24.
//

import Foundation
import SwiftUI

struct FPSGraphView: View {
    
    let queue: Queue<Double>
    let lowerbound: Double
    let upperbound: Double
    let unlimited: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            ZStack {
                GeometryReader { geometry in
                    let viewWidth = geometry.size.width
                    let viewHeight = geometry.size.height
                    let count = queue.capacity
                    let boundHeight = upperbound - lowerbound
                    
                    let coordinates = queue.enumerated().map { (offset, fps) in
                        let hRatio = CGFloat(offset) / CGFloat(count)
                        let vRatio = 1.0 - CGFloat(fps - lowerbound) / CGFloat(boundHeight)
                        let x = viewWidth * hRatio
                        let y = viewHeight * vRatio
                        return CGPoint(x: x, y: y)
                    }
                    if let begin = coordinates.first,
                       let end = coordinates.last,
                       begin != end {
                        Path { path in
                            path.move(to: CGPoint(x: begin.x, y: 0.75 * viewHeight))
                            path.addLine(to: CGPoint(x: end.x, y: 0.75 * viewHeight))
                            path.move(to: CGPoint(x: begin.x, y: 0.50 * viewHeight))
                            path.addLine(to: CGPoint(x: end.x, y: 0.50 * viewHeight))
                            path.move(to: CGPoint(x: begin.x, y: 0.25 * viewHeight))
                            path.addLine(to: CGPoint(x: end.x, y: 0.25 * viewHeight))
                        }
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [2]))
                        .foregroundStyle(.gray.opacity(0.5))
                        
                        Path { path in
                            path.addLines(coordinates)
                        }
                        .stroke(.blue, lineWidth: 1)
                    }
                }
            }
            
            VStack {
                Text("\(unlimited ? 300 : 90) Hz")
                Text("\(unlimited ? 200 : 60) Hz")
                Text("\(unlimited ? 100 : 30) Hz")
            }
            .font(.footnote)
            .foregroundStyle(.blue)
            .padding(.trailing, 4)
        }
    }
}


