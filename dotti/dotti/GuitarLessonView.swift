//
//  GuitarLessonView.swift
//  dotti
//
//  Created by Evan Griffith on 4/2/22.
//

import SwiftUI

/// - Invariant: UI orientation must always be landscape
/// If for some reason it becomes portrait, immediately correct it
struct GuitarLessonView: View {
    /// Tracks previous UI landscape orientation (landscape left by default)
    ///
    /// Whenever the user reorients the device to
    /// `UIDeviceOrientation.landscapeLeft` or
    /// `UIDeviceOrientation.landscapeRight`, this variable will be updated.
    /// Other device orientation changes do not affect this variable.
    ///
    /// - Remark: `UIInterfaceOrientation` is different from `UIDeviceOrientation`
    ///
    /// - Invariant
    /// Value will always be either `UIInterfaceOrientation.landscapeLeft` or
    /// `UIInterfaceOrientation.landscapeRight`
    @State private var prevLandscapeOrientation = UIInterfaceOrientation.landscapeLeft

    var body: some View {
        Group{
            Text("Hello, world!")
        }
        .onAppear { setUIOrientation(to: prevLandscapeOrientation) }
        .onRotate { newOrientation in
            switch prevLandscapeOrientation {
            case UIInterfaceOrientation.landscapeLeft:
                print("landscapeLeft")
            case UIInterfaceOrientation.landscapeRight:
                print("landscapeRight")
            default: break
            }

            switch newOrientation {
            case UIDeviceOrientation.landscapeLeft:
                prevLandscapeOrientation = UIInterfaceOrientation.landscapeLeft
            case UIDeviceOrientation.landscapeRight:
                prevLandscapeOrientation = UIInterfaceOrientation.landscapeRight

            // UI must be displayed in landscape. Force it into landscape
            case UIDeviceOrientation.portrait, UIDeviceOrientation.portraitUpsideDown:
                setUIOrientation(to: prevLandscapeOrientation)

            default: break
            }
        }
    }
}
