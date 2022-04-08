//
//  ContentViewModel.swift
//  dotti
//
//  Created by Evan Griffith on 4/8/22.
//

import CoreImage
import VideoToolbox

class ContentViewModel: ObservableObject {
  // 1
  @Published var frame: CGImage?
  // 2
  private let frameManager = FrameManager.shared

  init() {
    setupSubscriptions()
  }
  // 3
  func setupSubscriptions() {
      // 1
      frameManager.$current
        // 2
        .receive(on: RunLoop.main)
        // 3
        .compactMap { buffer in
            if (buffer != nil){
                return self.createImage(from: buffer!)
            }
            return nil
        }
        // 4
        .assign(to: &$frame)
  }
    
    func createImage(from pixelBuffer: CVPixelBuffer) -> CGImage? {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        return cgImage
    }
}

