//
//  RestartGuideView.swift
//  FindSurfaceST-visionOS
//
//  Created by CurvSurf-SGKim on 6/17/24.
//

import Foundation
import SwiftUI

struct RestartGuideView: View {
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "questionmark.circle")
                    .imageScale(.large)
                Text("How to close the app completely")
                    .font(.title)
            }
            Divider()
            HStack(spacing: 10) {
                Image(systemName: "digitalcrown.horizontal.press")
                Image(systemName: "plus")
                Image(systemName: "button.horizontal.top.press")
                Text("(3 sec.)")
                    .font(.subheadline)
            }
            
            Text("You can open the `Force Quit Applications` dialog by pressing and holding the top button and the digital crown simultaneously for 3 seconds to force quit the app.")
                .font(.subheadline)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: 350)
        }
        .padding()
    }
}
