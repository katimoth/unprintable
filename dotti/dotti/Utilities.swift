//
//  Utilities.swift
//  dotti
//
//  Created by Tohei Ichikawa. on 3/19/22.
//

import SwiftUI

// Our custom view modifier to track rotation and call our action
struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(
                for: UIDevice.orientationDidChangeNotification
            )) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
			#selector(UIResponder.resignFirstResponder),
			to: nil,
			from: nil,
			for: nil
		)
    }

    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }

    /// Change UI's orientation
    /// - Parameter orientation: Desired UI orientation
    ///
    /// - Warning
    /// This function has not been tested with anything other than `landscapeLeft` and
    /// `landscapeRight`
    func setUIOrientation(to orientation: UIInterfaceOrientation) {
        // For some strange reason, if you want to set the orientation to
        // landscape left, you must use `landscapeRight.rawValue` and vice versa
        switch orientation {
        case UIInterfaceOrientation.landscapeLeft:
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        case UIInterfaceOrientation.landscapeRight:
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
        default: break
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    /// Controls what UI orientations are allowed. By default, all orientations are allowed
    static var orientationMask = UIInterfaceOrientationMask.all

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationMask
    }
}

//struct Song {
//    private var songName = "All too Well"
//    private var songBPM: CGFloat
//    private var songDifficulty = "Easy"
//    
//}
