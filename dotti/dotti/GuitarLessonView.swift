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

    let sidebarWidth: CGFloat = 150

    /// The full chord progression of the song with indices
    let chordProgression: [[Any]]
    var chords: [String]
    var beats: [Int]

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
    @State var nextChords: ArraySlice<String>? = []

    /// Defines the size of `nextChords`. In other words, defines the number of
    /// chords the user can preview in the sidebar.
    ///
    /// - Invariant: Must be >= 2
    let maxNumNextChords = 4

    /// Starting orientation of this view
    let startingOrientation = UIInterfaceOrientation.landscapeRight

    /// Tracks orientation of this view
    ///
    /// - Invariant: Either `landscapeRight` or `landscapeLeft`
    @State var orientation: UIInterfaceOrientation

    /// Camera View Helper
    ///
    @StateObject private var model = ContentViewModel()
    
    ///Audio View Helper
    ///
//    @StateObject private var audioPlayer = AudioPlayer()

    init(chordProgression: [[Any]]) {
        self.chordProgression = chordProgression
        self.orientation = startingOrientation
        
        self.chords = []
        self.beats = []
        for arr in chordProgression {
            self.chords.append(arr[0] as! String)
            self.beats.append(arr[1] as! Int)
        }
    }
    
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                // Camera Feed
                FrameView(image: model.frame, orientation: $orientation)
                    .edgesIgnoringSafeArea(.all)
                    /**
                     Hi Evan,

                     The camera code looked very complicated. I think it would be
                     better if you fixed our camera orientation problem.
                     
                     Let me tell you how orientation works. There are 6 different
                     orientations, but we're only interested in `landscapeLeft`
                     and `landscapeRight`. A Google search will tell you about
                     the others.

                     HOWEVER! There are several different orientation types, and
                     they DO NOT agree with each other. For example,
                     `UIInterfaceOrientation.landscapeLeft` is where the home
                     button is on the left, but
                     `UIDeviceOrientation.landscapeLeft` is where the home
                     button is on the RIGHT. It's confusing, so be CAREFUL!

                     Good luck,
                     Tohei
                    */
                    .onRotate { newOrientation in
                        switch newOrientation {
                        // home button on the RIGHT
                        case .landscapeLeft:
                            FrameView(image: model.frame, orientation: $orientation)
                                .edgesIgnoringSafeArea(.all)
                            break
                        // home button on the LEFT
                        case .landscapeRight:
                            FrameView(image: model.frame, orientation: $orientation)
                                .edgesIgnoringSafeArea(.all)
                            break
                        default: break
                        }
                    }
                // Sidebar
                Spacer()
                VStack(alignment: .trailing) {
                    HStack {
                        Image(systemName: "pause.fill")
                            .onTapGesture { pause() }
                        Spacer()
                        Image(systemName: "xmark")
                            .onTapGesture { exit() }
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
                        if let nextChords = nextChords {
                            Text(chords[nextChords.startIndex])
                                .font(.system(size: TextSize.l(), weight: .heavy))
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
                                .font(.system(size: TextSize.m(), weight: .heavy))
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
                    .onTapGesture(count: 2) { getPrevChord() }
                    .onTapGesture(count: 1) { getNextChord() }
            }
        }  
            // Want sidebar to go into safe area only when `landscapeRight`
            .ignoresSafeArea(
                edges: orientation == .landscapeRight ?
                    .trailing :
                    .leading // which does not change the look of the UI
            )
            .onAppear {
                // This view is landscape orientation only
                AppDelegate.orientationMask = UIInterfaceOrientationMask.landscape
                setUIOrientation(to: startingOrientation)

                // Load sidebar data
                nextChords = chords.prefix(maxNumNextChords)
            }
            .onRotate { newOrientation in
                // Keep track of UI's orientation
                //
                // WARNING: `UIDeviceOrientation.landscapeLeft` is where home
                // button is on the RIGHT, whereas
                // `UIInterfaceOrientation.landscapeLeft` is where home button
                // is on the LEFT!
                switch newOrientation {
                case UIDeviceOrientation.landscapeRight:
                    orientation = UIInterfaceOrientation.landscapeLeft
                case UIDeviceOrientation.landscapeLeft:
                    orientation = UIInterfaceOrientation.landscapeRight
                default: break
                }
            }
            .onDisappear { 
                AppDelegate.orientationMask = UIInterfaceOrientationMask.all
            }
    }

    func pause() {
        print("pause")
    }

    func exit() {
        print("exit")
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

        self.nextChords = chords[nextChords.startIndex + 1..<newEndIndex]
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
            self.nextChords = chords.suffix(1)
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

        self.nextChords = chords[nextChords.startIndex - 1..<newEndIndex]
    }
    #endif
}
