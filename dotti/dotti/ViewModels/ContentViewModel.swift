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
    @Published var frameBuffer: CMSampleBuffer?
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
                if (buffer != nil) {
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
        frameBuffer = createSampleBufferFrom(pixelBuffer: pixelBuffer)
        return cgImage
    }
    
    func createSampleBufferFrom(pixelBuffer: CVPixelBuffer) -> CMSampleBuffer? {
        var sampleBuffer: CMSampleBuffer?
        
        var timimgInfo  = CMSampleTimingInfo()
        var formatDescription: CMFormatDescription? = nil
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer, formatDescriptionOut: &formatDescription)
        
        CMSampleBufferCreateReadyWithImageBuffer(
          allocator: kCFAllocatorDefault,
          imageBuffer: pixelBuffer,
          formatDescription: formatDescription!,
          sampleTiming: &timimgInfo,
          sampleBufferOut: &sampleBuffer
        )
        guard let buffer = sampleBuffer else {
            print("Cannot create sample buffer")
            return nil
        }
        return buffer
    }
}

