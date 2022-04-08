//
//  GuitarLessonView.swift
//  dotti
//
//  Created by Evan Griffith on 4/2/22.
//

import SwiftUI

/// - Invariant: UI orientation must always be landscape
struct GuitarLessonView: View {
    let sidebarWidth: CGFloat = 150

    /// The full chord progression of the song with indices
    let chordProgression: [Chord]

    /// A slice of `chordProgression` representing the user's next chords.
    /// Chords in this slice will be visible in the sidebar.
    ///
    /// Slice size is always `maxNumNextChords` unless user is near the end of the
    /// song and there are too few chords remaining in `chordProgression`, in
    /// which case it will shrink.
    ///
    /// When the user has finished the song and there are no chords left, this
    /// variable's value is `nil`.
    ///
    /// - Example: 1st element of this slice is the current chord
    @State var nextChords: ArraySlice<Chord>? = []

    /// Defines the size of `nextChords`. In other words, defines the number of
    /// chords the user can preview in the sidebar.
    ///
    /// - Invariant: Must be >= 2
    let maxNumNextChords = 5

    /// Camera View Helper
    ///
    @StateObject private var model = ContentViewModel()
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                // Camera Feed
                
                FrameView(image: model.frame)
                    .edgesIgnoringSafeArea(.all)
                Spacer()
                // Sidebar
                VStack (alignment: .trailing) {
                    Text("Current Chord")
                    if let nextChords = nextChords {
                        Text(chordProgression[nextChords.startIndex].root.rawValue)
                    }

                    Text("Next:")
                    if let nextChords = nextChords, nextChords.count > 1 {
                        Text(chordProgression[nextChords.startIndex + 1].root.rawValue)
                    }

                    // Display next few chords
                    if let nextChords = nextChords, nextChords.count > 2 {
                        ForEach(2..<nextChords.count, id: \.self) { i in
                            Text(nextChords[nextChords.startIndex + i].root.rawValue)
                        }
                    }

                    Button("next chord") {
                        getNextChord()
                    }
                }
                    .padding(5)
                    .frame(maxHeight: .infinity)
                    .frame(width: sidebarWidth)
                    .background(Color.ruber)
            }
        }
            .onAppear {
                // This view is landscape orientation only
                AppDelegate.orientationMask = UIInterfaceOrientationMask.landscape
                setUIOrientation(to: UIInterfaceOrientation.landscapeRight)

                // Load sidebar data
                nextChords = chordProgression.prefix(maxNumNextChords)
            }
            .onDisappear { 
                AppDelegate.orientationMask = UIInterfaceOrientationMask.all
            }
    }

    /// Updates `nextChords`, shifting the array slice to the right by 1.
    ///
    /// The slice will shrink in size if there are too few chords remaining in
    /// `chordProgression`. It becomes `nil` once there are no chords left.
    ///
    /// If the song is already over, nothing happens.
    func getNextChord() {
        guard let nextChords = nextChords, nextChords.count > 1 else {
            self.nextChords = nil
            return
        }

        // When remaining chords are few, we must not index beyond right edge
        let newEndIndex = min(chordProgression.count, nextChords.endIndex + 1)

        self.nextChords = chordProgression[nextChords.startIndex + 1..<newEndIndex]
    }
}
