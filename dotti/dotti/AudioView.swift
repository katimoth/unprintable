//
//  SwiftUIView.swift
//  dotti
//
//  Created by Evan Griffith on 4/8/22.
//

import SwiftUI

final class PlayerUIState: ObservableObject {

    var recHidden = false
    @Published var recDisabled = false
    @Published var recColor = Color(.systemBlue)
    @Published var recIcon = Image(systemName: "largecircle.fill.circle") // initial value

    @Published var playCtlDisabled = true

    @Published var playDisabled = true
    @Published var playIcon = Image(systemName: "play")

    @Published var doneDisabled = false
    @Published var doneIcon = Image(systemName: "square.and.arrow.up") // initial value
    
    private func playCtlEnabled(_ enabled: Bool) {
        playCtlDisabled = !enabled
    }
    
    private func playEnabled(_ enabled: Bool) {
        playIcon = Image(systemName: "play")
        playDisabled = !enabled
    }
    
    private func pauseEnabled(_ enabled: Bool) {
        playIcon = Image(systemName: "pause")
        playDisabled = !enabled
    }

    private func recEnabled() {
        recIcon = Image(systemName: "largecircle.fill.circle")
        recDisabled = false
        recColor = Color(.systemBlue)
    }

    func propagate(_ playerState: PlayerState) {
        switch (playerState) {
        case .start(.play):
            recHidden = true
            playEnabled(true)
            playCtlEnabled(false)
            doneIcon = Image(systemName: "xmark.square")
        case .start(.standby):
            if !recHidden { recEnabled() }
            playEnabled(true)
            playCtlEnabled(false)
            doneDisabled = false
        case .start(.record):
            // initial values already set up for record start mode.
            break
        case .recording:
            recIcon = Image(systemName: "stop.circle")
            recColor = Color(.systemRed)
            playEnabled(false)
            playCtlEnabled(false)
            doneDisabled = true
        case .paused:
            if !recHidden { recEnabled() }
            playIcon = Image(systemName: "play")
        case .playing:
            if !recHidden {
                recDisabled = true
                recColor = Color(.systemGray6)
            }
            pauseEnabled(true)
            playCtlEnabled(true)
        }
    }
}

struct AudioView: View {
    @ObservedObject var audioPlayer: AudioPlayer
    var autoPlay = false
    @StateObject var playerUIState = PlayerUIState()

    var body: some View {
        VStack {
            Spacer()
            HStack {
                StopButton(audioPlayer: audioPlayer, playerUIState: playerUIState)
                Spacer()
                RwndButton(audioPlayer: audioPlayer, playerUIState: playerUIState)
                Spacer()
                PlayButton(audioPlayer: audioPlayer, playerUIState: playerUIState)
                Spacer()
                FfwdButton(audioPlayer: audioPlayer, playerUIState: playerUIState)
                Spacer()
                DoneButton(audioPlayer: audioPlayer, playerUIState: playerUIState)
            }
            Spacer()
            RecButton(audioPlayer: audioPlayer, playerUIState: playerUIState)
        }
        .onAppear {
            playerUIState.propagate(audioPlayer.playerState)
            if autoPlay {
                audioPlayer.playTapped()
            }
        }
        .onChange(of: audioPlayer.playerState) {
            playerUIState.propagate($0)
        }
//        .onDisappear {
//            await audioPlayer.doneTapped(chord: "nil")
//        }
    }
}


struct RecButton: View {
    @ObservedObject var audioPlayer: AudioPlayer
    @ObservedObject var playerUIState: PlayerUIState
    
    var body: some View {
        if playerUIState.recHidden {
            // if not included hidden, SwiftUI will not leave empty space
            Button(action: { }) {
                playerUIState.recIcon
                    .scaleEffect(5.0)
                    .padding(.bottom, 80)
            }
            .hidden()
        } else {
            Button(action: {
                audioPlayer.recTapped()
            }) {
                playerUIState.recIcon
                    .scaleEffect(5.0)
                    .padding(.bottom, 80)
                    .foregroundColor(playerUIState.recColor)
            }
            .disabled(playerUIState.recDisabled)
        }
    }
}

struct DoneButton: View {
    @ObservedObject var audioPlayer: AudioPlayer
    @ObservedObject var playerUIState: PlayerUIState
    
    var body: some View {
        Button(action: {
            audioPlayer.doneTapped(chord: "nil")
        }) {
            playerUIState.doneIcon.scaleEffect(2.0).padding(.trailing, 40)
        }
        .disabled(playerUIState.doneDisabled)
    }
}

struct StopButton: View {
    @ObservedObject var audioPlayer: AudioPlayer
    @ObservedObject var playerUIState: PlayerUIState
    
    var body: some View {
        Button(action: {
            audioPlayer.stopTapped()
        }) {
            Image(systemName: "stop").scaleEffect(2.0).padding(.trailing, 40)
        }
        .disabled(playerUIState.playCtlDisabled)
    }
}

struct FfwdButton: View {
    @ObservedObject var audioPlayer: AudioPlayer
    @ObservedObject var playerUIState: PlayerUIState
    
    var body: some View {
        Button(action: {
            audioPlayer.ffwdTapped()
        }) {
            Image(systemName: "goforward.10").scaleEffect(2.0).padding(.trailing, 40)
        }
        .disabled(playerUIState.playCtlDisabled)
    }
}

struct RwndButton: View {
    @ObservedObject var audioPlayer: AudioPlayer
    @ObservedObject var playerUIState: PlayerUIState
    
    var body: some View {
        Button(action: {
            audioPlayer.rwndTapped()
        }) {
            Image(systemName: "gobackward.10").scaleEffect(2.0).padding(.trailing, 40)
        }
        .disabled(playerUIState.playCtlDisabled)
    }
}

struct PlayButton: View {
    @ObservedObject var audioPlayer: AudioPlayer
    @ObservedObject var playerUIState: PlayerUIState
    
    var body: some View {
        Button(action: {
            audioPlayer.playTapped()
        }) {
            playerUIState.playIcon.scaleEffect(2.0).padding(.trailing, 40)
        }
        .disabled(playerUIState.playDisabled)
    }
}
