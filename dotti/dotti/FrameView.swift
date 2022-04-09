//
//  FrameView.swift
//  dotti
//
//  Created by Evan Griffith on 4/8/22.
//

import SwiftUI

struct FrameView: View {
    var image: CGImage?
    private let label = Text("Camera feed")
    @Binding var orientation:  UIInterfaceOrientation
    
    var imageOrientation: Image.Orientation = .upMirrored
    
    
    var body: some View {
        // 1
        
        if let image = image {
            GeometryReader { geometry in
                // 3
                Image(image, scale: 1.0, orientation: setOrientation(orientation: orientation), label: label)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height,
                        alignment: .center)
                    .clipped()
            }
        } else {
            // 4
            Text("Please allow access to your camera.")
                .frame(
                    alignment: .center
                )
        }
    }
    
    func setOrientation(orientation: UIInterfaceOrientation) -> Image.Orientation {
        switch orientation {
        // home button on the RIGHT
        case .landscapeLeft:
            return .downMirrored
        // home button on the LEFT
        case .landscapeRight:
            return .upMirrored
        default: break
        }
        
        return .upMirrored
        
    }
}

//struct FrameView_Previews: PreviewProvider {
//    static var previews: some View {
//        FrameView()
//    }
//}
