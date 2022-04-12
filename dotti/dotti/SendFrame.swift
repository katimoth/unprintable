//
//  SendFrame.swift
//  dotti
//
//  Created by Mary Keta on 4/11/22.
//

import Foundation
import SwiftUI

class SendFrame: ObservableObject {
    
    @Published var frame: String?
    struct FrameStruct: Codable {
        var frame: String
    }

    func sendFrame(frame: CGImage, chord: String) {
        guard let apiUrl =  URL(string: "https://35.227.89.255/getoverlay/") else {
            print("Bad URL")
            return
        }
        let frame_uiimage = UIImage(cgImage: frame)
        let png_data = frame_uiimage.jpegData(compressionQuality: 0)
        let imageBase64String = png_data?.base64EncodedString()
        let jsonObj = ["frame": imageBase64String, "chord": chord]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
            print("postAudio: jsonData serialization error")
            return
        }
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                print("postAudio: NETWORKING ERROR")
                return
            }

            if let httpStatus = response as? HTTPURLResponse {
                if httpStatus.statusCode != 200 {
                    print("postAudio: HTTP STATUS: \(httpStatus.statusCode)")
                    return
                }
            }
            let decoder = JSONDecoder()
            
            
            if let data = data, let dataString = String(data: data, encoding: .utf8)?.data(using: .utf8)! {
                print("Response data string:\n \(dataString)")
                do {
                    print(dataString)
                    let dataFrame = try decoder.decode(FrameStruct.self, from: dataString)
                    print(dataFrame.frame)
                } catch {
                    print("decode error")
                    return
                }
            }
            
        }.resume()
    }

}
