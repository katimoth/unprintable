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
        Group{
            Text("Hello, world!")
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
