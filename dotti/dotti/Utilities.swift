//
//  Utilities.swift
//  dotti
//
//  Created by Tohei Ichikawa. on 3/19/22.
//

import SwiftUI

extension URL {
    static let serverIP = "35.243.195.141"
}

#if DEBUG
extension UIDeviceOrientation: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown: return "unknown"
        case .portrait: return "portrait"
        case .portraitUpsideDown: return "portraitUpsideDown"
        case .landscapeLeft: return "landscapeLeft"
        case .landscapeRight: return "landscapeRight"
        case .faceUp: return "faceUp"
        case .faceDown: return "faceDown"
        default: return "this is here to silence a compiler warning"
        }
    }
}
#endif

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
    func setUIOrientation(to orientation: UIInterfaceOrientation) {
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
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
