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
    let song: Song
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
    @Binding var currentView: AppViews
    init(song: Song, currentView: Binding<AppViews>) {
        self.song = song
        self.orientation = startingOrientation
        self.chords = []
        self._currentView = currentView
        self.fretboardImage = ""
        self.beats = []
        for arr in song.chords! {
            self.chords.append(arr[0] as! String)
            self.beats.append(arr[1] as! Int)
        }
    }
    @StateObject private var audioPlayer = AudioPlayer()
    @State private var lessonStarted = false
    @State private var playHidden = true
    @State private var recHidden = false
    @State private var startBtnHidden = false
    @State private var timerGoing = true
    @State private var countdown: Double?
    @State private var fretboardImage: String
    var body: some View {
        ZStack {
            HStack {
                ZStack {
                    // Camera Feed
                    FrameView(image: model.frame, orientation: $orientation)
                        .edgesIgnoringSafeArea(.all)
                
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
                    
                        .overlay(alignment: .bottom) {
                            Image(fretboardImage)
                                .resizable()
                                .scaledToFit()
                        }
                        
                    
                        if !startBtnHidden && timerGoing {
                            Button(action: {
                                fretboardImage = "overlay_" + (nextChords?[nextChords!.startIndex] ?? "")
                                /*
                                 The button in SongItem (build to see it) is what changes the variable
                                 Possible values: 1x speed, 0.75x speed, 0.50x speed, 0.25x speed.
                                 Thank you!
                                 */
                                let playBackspeed = song.playBackspeed
                                
                                startBtnHidden = true
                                var time = (Double(beats[0]) * 60.0) / (Double(song.bpm!) * playBackspeed)
                                var counter = 0.0
                                var current_beat = 0
                                audioPlayer.recTapped()
                                recHidden.toggle()

                                let timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { timer in
                                    counter += 0.001
                                    if(counter >= time) {
                                        if timerGoing{
                                            audioPlayer.recTapped()
                                            
                                            audioPlayer.doneTapped(chord: nextChords?[nextChords!.startIndex])
                                                
                                            getNextChord()
                                            fretboardImage = "overlay_" + (nextChords?[nextChords!.startIndex] ?? "")
                                            if(current_beat == beats.count - 1) {
                                                timer.invalidate()
                                            }
                                            counter = 0.0
                                            current_beat += 1
                                            time = (Double(beats[current_beat]) * 60.0) / (Double(song.bpm!) * playBackspeed)
                                            audioPlayer.recTapped()
                                        }
                                    }
                                    if nextChords == nil {
                                        audioPlayer.doneTapped(chord: "nil")
                                        timer.invalidate()
                                        startBtnHidden = true
                                        timerGoing = false
                                    } else {
                                        countdown = time - counter
                                    }
                                    
                                }

                            }, label: {
                                Text("start")
                                    .foregroundColor(Color.black)
                                    .frame(width: 120, height: 40)
                                    .background(Color.floral_white)
                                    .cornerRadius(5)
                                    .font(.system(size: 30))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5.0)
                                            .stroke(Color.ruber, lineWidth: 2.0)
                                    )
                                    .padding()
                            })
                        }
                }
                
                

                // Sidebar
                Spacer()
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
                        if let nextChords = nextChords {
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
                    .onTapGesture(count: 2) { getPrevChord() }
                    .onTapGesture(count: 1) { getNextChord() }
            }.border(audioPlayer.borderColor, width: 10)
                .cornerRadius(50)
                .animation(.spring())
                .edgesIgnoringSafeArea(.all)
            
            
            if nextChords == nil {
                ResultsView(audioPlayer: audioPlayer, currentView: $currentView, totalNumChords: Double(chords.count))
                    .edgesIgnoringSafeArea(.all)
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
                nextChords = chords.suffix(maxNumNextChords)
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
        let newEndIndex = min(chords.count, nextChords.endIndex + 1)

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
    
    func stopRecording() -> some View {
        audioPlayer.doneTapped(chord: "nil")
        return EmptyView()
    }
    #endif
}
