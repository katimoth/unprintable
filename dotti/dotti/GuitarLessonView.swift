//
//  GuitarLessonView.swift
//  dotti
//
//  Created by Evan Griffith on 4/2/22.
//

import SwiftUI

/// - Invariant: UI orientation must always be landscape
struct GuitarLessonView: View {
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
    
    /// View for labels in the sidebar
    struct Label: View {
        let text: String

        init(_ text: String) {
            self.text = text
        }

        var body: some View {
            Text(text)
                .font(.system(size: TextSize.xs()))
                .foregroundColor(.white)
        }
    }


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
    
    ///Audio View Helper
    ///
//    @StateObject private var audioPlayer = AudioPlayer()
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                // Camera Feed
                FrameView(image: model.frame)
                    .edgesIgnoringSafeArea(.all)
                    /**
                     Hi Evan,
                     
                     The camera code looked very complicated. I think it would be
                     better if you fixed our camera orientation problem.
                     
                     Let me tell you how orientation works. There are 6 different
                     orientations, but we're only interested in `landscapeLeft`
                     and `landscapeRight`. `landscapeLeft` is where the home
                     button is on the left. `landscapeRight` is where the home
                     button is on the right. A Google search will tell you about
                     the others.
                     
                     Below is the `onRotate` event handler, and it will trigger
                     whenever the user rotates their device. The `switch` block
                     after that will determine what the new orientation of the
                     device is. You will need to somehow update the camera
                     manager from here.
                     
                     And before you get confused, there are several different
                     orientation types. The parameter `newOrientation` in the
                     `onRotate` event handler's type is `UIDeviceOrientation`.
                     The type of `videoOrientation` on line 129 of
                     `CameraManager.swift` is of type `AVCaptureVideoOrientation`.
                     
                     Good luck,
                     Tohei
                    */
                    .onRotate { newOrientation in
                        switch newOrientation {
                        case .landscapeLeft:
                            // TODO
                            break
                        case .landscapeRight:
                            // TODO
                            break
                        default: break
                        }
                    }
                // Sidebar
                VStack(alignment: .trailing) {
                    Label("Current Chord")
                    ZStack {
                        Circle()
                            .stroke(Color.ruber, lineWidth: 4)
                            .frame(width: TextSize.l() * 1.5, height: TextSize.l() * 1.5)
                        if let nextChords = nextChords {
                            Text(chordProgression[nextChords.startIndex].root())
                                .font(.system(size: TextSize.l(), weight: .heavy))
                                .foregroundColor(Color.ruber)
                        }
                    }
                        .frame(maxWidth: .infinity)

                    HStack {
                        Label("Next")
                        Spacer()
                        // if let nextChords = nextChords, nextChords.count > 1 {
                            Text(
                                // If there is no immediate next chord, use a
                                // blankspace instead of removing this `Text`
                                // view or else UI will change and become ugly
                                nextChords != nil && nextChords!.count > 1 ?
                                    chordProgression[nextChords!.startIndex + 1].root() :
                                    " "
                            )
                                .font(.system(size: TextSize.m(), weight: .heavy))
                                .underline()
                                .foregroundColor(Color.deep_champagne)
                        // }
                    }
                        .offset(y: -15)

                    // Display next few chords
                    if let nextChords = nextChords, nextChords.count > 2 {
                        // Reason for this extra `VStack`:
                        // The font is not monospaced, so alinging chord names
                        // to the trailing edge looks ugly.
                        // Center aligning chord names within a VStack aligned
                        // to the trailing edge of the sidebar looks better
                        VStack {
                            ForEach(2..<nextChords.count, id: \.self) { i in
                                Text(nextChords[nextChords.startIndex + i].root())
                                    .font(.system(size: TextSize.s()))
                                    .foregroundColor(.gray)
                            }
                        }
                    }

                    // Top-aligns VStack contents
                    Spacer()
                    
                    // AudioView(audioPlayer: audioPlayer)
                }
                    .padding(10)
                    .frame(maxHeight: .infinity)
                    .frame(width: sidebarWidth)
                    .background(.black)
                    .onTapGesture(count: 2) { getPrevChord() }
                    .onTapGesture(count: 1) { getNextChord() }
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

    #if DEBUG
    /// Updates `nextChords`, shifting the array slice to the left by 1.
    ///
    /// The slice will expand in size up to `maxNumNextChords` if slice is at
    /// end of `chordProgression`.
    ///
    /// If slice is `nil`, `nextChords` becomes a slice of size 1 at the end of
    /// `chordProgression`.
    ///
    /// If the slice is at very beginning of the chord progression, do nothing.
    ///
    /// - Attention: For development use only
    func getPrevChord() {
        guard let nextChords = nextChords else {
            self.nextChords = chordProgression.suffix(1)
            return
        }

        if nextChords.startIndex == 0 {
            return
        }

        // Keep end index where it is if slice is expanding from end of chord
        // progression
        let newEndIndex = nextChords.count == maxNumNextChords ?
            nextChords.endIndex - 1 :
            nextChords.endIndex

        self.nextChords = chordProgression[nextChords.startIndex - 1..<newEndIndex]
    }
    #endif
}
