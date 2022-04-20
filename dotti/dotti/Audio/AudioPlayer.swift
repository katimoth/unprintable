//
//  AudioPlayer.swift
//  dotti
// Using tutorial from Mohammad Yasir on Medium
//  Created by Evan Griffith on 4/8/22.
//
import AVFoundation
import SwiftUI


struct songDetails {
    var name: String?
    var artist: String?
    var audio: String?
}
enum StartMode {
    case record, play, standby
}

enum PlayerState: Equatable {
    case start(StartMode)
    case recording
    case paused(StartMode)
    case playing(StartMode)
    mutating func transition(_ event: TransEvent) {
            if (event == .doneTapped) {
                self = .start(.standby)
                return
            }
            switch self {
            case .start(.record) where event == .recTapped:
                self = .recording
            case .start(.play) where event == .playTapped:
                self = .playing(.play)
            case .start(.standby):
                switch event {
                case .recTapped:
                    self = .recording
                case .playTapped:
                    self = .playing(.standby)
                default:
                    break
                }
            case .recording:
                switch event {
                case .stopTapped:
                    fallthrough
                case .recTapped:
                    self = .start(.standby)
                case .failed:
                    self = .start(.record)
                default:
                    break
                }
            case .playing(let parent):
                switch event {
                case .playTapped:
                    self = .paused(parent)
                case .stopTapped, .failed:
                    self = .start(parent)
                default:
                    break
                }
            case .paused(let grand):
                switch event {
                case .recTapped:
                    self = .recording
                case .playTapped:
                    self = .playing(grand)
                case .stopTapped:
                    self = .start(.standby)
                default:
                    break
                }
            default:
                break
            }
        }
}

enum TransEvent {
    case recTapped, playTapped, stopTapped, doneTapped, failed
}

final class AudioPlayer: NSObject, ObservableObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    @Published var playerState = PlayerState.start(.standby)
    @Published var correctChordsPlayed = 0
    @Published var borderColor: Color = Color.clear
    var audio: Data!
    private let audioFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("guitaraudio.m4a")
    
    private let audioSession = AVAudioSession.sharedInstance()
    private var audioRecorder: AVAudioRecorder!
    private var audioPlayer: AVAudioPlayer!

    /// Notes whether each chord has been played correctly or incorrectly
    ///
    /// e.g. If `GuitarLessonView.chords[5]` was played right,
    ///      `self.chordsPlayedCorrectly[5]` is true
    ///
    /// At the moment, no memory is reserved upfront. Expensive copying of
    /// memory can occur every now and then
    @Published var chordsPlayedCorrectly: [Bool] = []

    override init() {
        super.init()
        setupRecorder()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("AudioPlayer: failed to setup AVAudioSession")
        }
    }
    
    
    
    func setupRecorder() {
        playerState = .start(.record)
        audio = nil
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        audioRecorder = try? AVAudioRecorder(url: audioFilePath, settings: settings)
        guard let _ = audioRecorder else {
            print("setupRecorder: failed")
            return
        }
        audioRecorder.delegate = self
    }
        
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Error encoding audio: \(error!.localizedDescription)")
        audioRecorder.stop()
        playerState.transition(.failed)
    }

    func setupPlayer(_ audioStr: String) {
        playerState = .start(.play)
        audio = Data(base64Encoded: audioStr, options: .ignoreUnknownCharacters)
        preparePlayer()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Error decoding audio \(error?.localizedDescription ?? "on playback")")
        // don't dismiss, in case user wants to record
        playerState.transition(.failed)
    }

    private func preparePlayer() {
        audioPlayer = try? AVAudioPlayer(data: audio)
        guard let _ = audioPlayer else {
            print("preparePlayer: incompatible audio encoding, not m4a?")
            return
        }
        audioPlayer.volume = 10.0
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playerState.transition(.stopTapped)
    }
    
    
    func playTapped() {
        guard let _ = audioPlayer else {
            print("playTapped: no audioPlayer!")
            return
        }
        playerState.transition(.playTapped)
        if audioPlayer.isPlaying {
            audioPlayer.pause()
        } else {
            audioPlayer.play()
        }
    }

    func stopTapped() {
        audioPlayer.stop()
        audioPlayer.currentTime = 0
        
        playerState.transition(.stopTapped)
    }

    func rwndTapped() {
        audioPlayer.currentTime = max(0, audioPlayer.currentTime - 10.0) // seconds
    }

    func ffwdTapped() {
        audioPlayer.currentTime = min(audioPlayer.duration, audioPlayer.currentTime + 10.0) // seconds
    }
    
    func recTapped() {
        if playerState == .recording {
            audioRecorder.stop()
            audio = try? Data(contentsOf: audioFilePath)
            preparePlayer()
        } else {
            audioRecorder.record()
        }
        playerState.transition(.recTapped)
    }
    
    func doneTapped(chord: String?) {
        @Binding var correctChordsPlayed: Int
        defer {
            playerState.transition(.doneTapped)
        }
                
        if let _ = audioPlayer {
            stopTapped()
        }
        
        guard let _ = audioRecorder else {
            return
        }
        if playerState == .recording {
            recTapped()
        }
        if chord != nil {
            sendToML(chord: chord!)
        }
        audioRecorder.deleteRecording()

    }
    
    struct ChordStruct: Codable {
        var chords: [String] = []
    }
    func sendToML(chord: String){
        ///audioFilePath <- path to file ->
        ///
        guard let apiUrl =  URL(string: "https://35.227.89.255/extractchord/") else {
            print("Bad URL")
            return
        }

        let name = "peepee"
        let artist = "poopoo"
        let jsonObj = ["name": name, "artist": artist, "audio": audio.base64EncodedString() ?? ""]

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
                    let dataChords = try decoder.decode(ChordStruct.self, from: dataString)
                    print(dataChords.chords)
                    if dataChords.chords.contains(chord) {
                        print("correct")
                        DispatchQueue.main.async {
                            self.correctChordsPlayed += 1
                            self.borderColor = Color.green
                            self.chordsPlayedCorrectly.append(true)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.borderColor = Color.red
                            self.chordsPlayedCorrectly.append(false)
                        }
                    }
                } catch {
                    print("decode error")
                    return
                }
            }
            
        }.resume()
    }
}

