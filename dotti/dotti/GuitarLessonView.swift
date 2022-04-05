//
//  GuitarLessonView.swift
//  dotti
//
//  Created by Evan Griffith on 4/2/22.
//

import SwiftUI

/// - Invariant: UI orientation must always be landscape
struct GuitarLessonView: View {
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                Text("[insert camera feed here]")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                    .foregroundColor(Color.american_bronze)
                    .background(Color.deep_champagne)
                GroupBox {
                    Text("Next Chord")
                }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.ruber)
            }

        }
            // This view is landscape orientation only
            .onAppear { 
                AppDelegate.orientationMask = UIInterfaceOrientationMask.landscape
                setUIOrientation(to: UIInterfaceOrientation.landscapeLeft)
            }
            .onDisappear { 
                AppDelegate.orientationMask = UIInterfaceOrientationMask.all
            }
    }
}
