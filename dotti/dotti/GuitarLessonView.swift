//
//  GuitarLessonView.swift
//  dotti
//
//  Created by Evan Griffith on 4/2/22.
//

import SwiftUI

struct GuitarLessonView: View {
    @State private var orientation = UIDeviceOrientation.unknown
    
    var body: some View {
        Group{
            if orientation.isLandscape {
                Text("Hello, World!")
            } else {
                Text("Please turn to landscape")
            }
        } 
        .onRotate { newOrientation in
            if self.orientation.isPortrait {
                changeOrientation(to: .landscapeLeft)
            }
            orientation = newOrientation
        }
        ///

        func changeOrientation(to orientation: UIInterfaceOrientation) {
            // tell the app to change the orientation
            UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
            print("Changing to", orientation.isPortrait ? "Portrait" : "Landscape")
        }
    }
}


// Our custom view modifier to track rotation and
// call our action
struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear(perform: {
                print("rotated")
            })
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) {_ in
                action(UIDevice.current.orientation)
                
            }
    }
}

// A View wrapper to make the modifier easier to use
extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}
