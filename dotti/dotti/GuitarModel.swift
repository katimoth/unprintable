//
//  GuitarModel.swift
//  dotti
//
//  Created by Timothy Kao on 4/15/22.
//

import Foundation
import MLKit
import AVFoundation

class GuitarModel {
    var model: LocalModel?
    var options: CustomObjectDetectorOptions?
    
    init() {
        guard let modelPath = Bundle.main.path(forResource: "model", ofType: "tflite") else {
            print("unable to find model")
            return
        }
        model = LocalModel(path: modelPath)
        
        // Init model options
        options = CustomObjectDetectorOptions(localModel: model!)
        options?.detectorMode = .singleImage
        options?.shouldEnableClassification = true
        options?.shouldEnableMultipleObjects = true
        options?.classificationConfidenceThreshold = NSNumber(value: 0.1)
        options?.maxPerObjectLabelCount = 3
        
    }
    
    func detectGuitarFromFrame(frame: UIImage) -> Any? {
        let image = VisionImage(image: frame)
        image.orientation = frame.imageOrientation
        let objectDetector = ObjectDetector.objectDetector(options: options!)
        var boundingBox: Any?
        objectDetector.process(image) { objects, error in
            guard error == nil, let objects = objects, !objects.isEmpty else {
                // Handle the error.
                print("detection error")
                return
            }
            // Show results.
            print("detected object")
            print(objects)
            boundingBox = objects
        }
        return boundingBox
    }
    
    func detectGuitarFromFrame(buffer: CMSampleBuffer) -> Any? {
        let image = VisionImage(buffer: buffer)
        image.orientation = imageOrientation(
          deviceOrientation: UIDevice.current.orientation,
          cameraPosition: .front)
        
        let objectDetector = ObjectDetector.objectDetector(options: options!)
        var boundingBox: Any?
        objectDetector.process(image) { objects, error in
            guard error == nil, let objects = objects, !objects.isEmpty else {
                // Handle the error.
                print("detection error")
                return
            }
            // Show results.
            print("detected object")
            print(objects)
            boundingBox = objects
        }
        return boundingBox
    }
    
    func imageOrientation(
      deviceOrientation: UIDeviceOrientation,
      cameraPosition: AVCaptureDevice.Position
    ) -> UIImage.Orientation {
      switch deviceOrientation {
      case .portrait:
          return cameraPosition == .front ? .leftMirrored : .right
      case .landscapeLeft:
          return cameraPosition == .front ? .downMirrored : .up
      case .portraitUpsideDown:
          return cameraPosition == .front ? .rightMirrored : .left
      case .landscapeRight:
          return cameraPosition == .front ? .upMirrored : .down
      case .faceDown, .faceUp, .unknown:
          return .up
      @unknown default:
          return .up
      }
    }
}
