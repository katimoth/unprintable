//
//  GuitarLessonView.swift
//  dotti
//
//  Created by Evan Griffith on 4/2/22.
//

import SwiftUI

/// - Invariant: UI orientation must always be landscape
struct GuitarLessonView: View {
    @State var currentChord: Chord?
    @State var nextChords: [Chord] = []

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                // Camera Feed
                Text("[insert camera feed here]")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                    .foregroundColor(Color.american_bronze)
                    .background(Color.deep_champagne)

                // Sidebar
                GroupBox {
                    Text("Current Chord")
                    if let currentChord = currentChord {
                        Text(currentChord.root.rawValue)
                    }
                    Text("Next")
                }
                    .padding(5)
                    .frame(maxHeight: .infinity)
                    .frame(width: 150)
                    .background(Color.ruber)
            }
        }
            .onAppear {
                // This view is landscape orientation only
                AppDelegate.orientationMask = UIInterfaceOrientationMask.landscape
                setUIOrientation(to: UIInterfaceOrientation.landscapeRight)

                currentChord = Chord(root: Note.g_sharp, quality: Chord.Quality.maj)
                nextChords = [
                    Chord(root: Note.e_sharp, quality: Chord.Quality.min),
                    Chord(root: Note.c_sharp, quality: Chord.Quality.maj),
                    Chord(root: Note.d_sharp, quality: Chord.Quality.maj, seventh: true),
                    Chord(root: Note.g_sharp, quality: Chord.Quality.maj)
                ]
            }
            .onDisappear { 
                AppDelegate.orientationMask = UIInterfaceOrientationMask.all
            }
    }
}

struct GuitarLessonView_Previews: PreviewProvider {
    static var previews: some View {
        GuitarLessonView()
            .previewInterfaceOrientation(.landscapeRight)
    }
}
