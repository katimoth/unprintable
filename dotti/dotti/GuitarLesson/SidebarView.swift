//
//  SidebarView.swift
//  dotti
//
//  Created by Timothy Kao on 4/13/22.
//

import SwiftUI

struct SidebarView: View {
    enum TextSize: CGFloat {
        case xs = 20
        case s = 30
        case m = 50
        case l = 70
        case xl = 100

        func callAsFunction() -> CGFloat {
            return self.rawValue
        }
    }
    
    let sidebarWidth: CGFloat = 150
    
    // A bunch of variables passed down from `GuitarLessonView`
    @Binding var currentView: AppViews
    var chords: [String]
    @Binding var nextChords: ArraySlice<String>?
    @Binding var startBtnHidden: Bool
    @Binding var countdown: Double?
    @Binding var timerGoing: Bool
    @ObservedObject var audioPlayer: AudioPlayer
    
    var body: some View {
        VStack(alignment: .trailing) {
            HStack {
                Text("\(countdown ?? 0, specifier: "%.2f")")

                
                Spacer()
                
                Text("\(audioPlayer.correctChordsPlayed)")
                
                Spacer()
                ///Done button - sends the recording to the chord analyzer that tim made, just returns a json back that means essentially nothing (Tim implementing it rn)
                Image(systemName: "xmark")
                    .onTapGesture {
                        if startBtnHidden {
                            audioPlayer.doneTapped(chord: "nil")
                        }
                        startBtnHidden = true
                        timerGoing = false
                        currentView = .libraryView
                        
                    }
            }
                .font(.system(size: TextSize.s()))
                .padding(.top, 5)
                .foregroundColor(Color.pearl_aqua)

            Text("Current Chord")
                .padding(.top, 15)
            ZStack {
                Circle()
                    .stroke(Color.ruber, lineWidth: 4)
                    .frame(width: TextSize.l() * 1.5, height: TextSize.l() * 1.5)
                if let nextChords = nextChords, !nextChords.isEmpty {
                    Text(chords[nextChords.startIndex])
                        .font(.system(size: TextSize.m(), weight: .heavy))
                        .foregroundColor(Color.ruber)
                }
            }
                .frame(maxWidth: .infinity)

            HStack {
                Text("Next")
                Spacer()
                // if let nextChords = nextChords, nextChords.count > 1 {
                    Text(
                        // If there is no immediate next chord, use a
                        // blankspace instead of removing this `Text`
                        // view or else UI will change and become ugly
                        nextChords != nil && nextChords!.count > 1 ?
                            chords[nextChords!.startIndex + 1] :
                            " "
                    )
                        .font(.system(size: TextSize.s(), weight: .heavy))
                        .underline()
                        .foregroundColor(Color.deep_champagne)
                // }
            }
                .padding(.top, -5)
                .padding(.bottom, 1) // surprisingly makes a huge difference

            // Display next few chords
            if let nextChords = nextChords, nextChords.count > 2 {
                // Reason for this extra `VStack`:
                // The font is not monospaced, so alinging chord names
                // to the trailing edge looks ugly.
                // Center aligning chord names within a VStack aligned
                // to the trailing edge of the sidebar looks better
                VStack {
                    ForEach(2..<nextChords.count, id: \.self) { i in
                        Text(nextChords[nextChords.startIndex + i])
                            .font(.system(size: TextSize.s()))
                            .foregroundColor(.gray)
                    }
                }
                    .padding(.bottom, 0)
            }

            // Top-aligns VStack contents
            Spacer()
            
            // AudioView(audioPlayer: audioPlayer)
        }
            .font(.system(size: TextSize.xs()))
            .padding(10)
            .frame(maxHeight: .infinity)
            .frame(width: sidebarWidth)
            .foregroundColor(Color.floral_white)
            .background(.black)
    }
}
