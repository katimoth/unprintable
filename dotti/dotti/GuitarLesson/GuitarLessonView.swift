//
//  GuitarLessonView.swift
//  dotti
//
//  Created by Evan Griffith on 4/2/22.
//

import SwiftUI


/// - Invariant: UI orientation must always be landscape
struct GuitarLessonView: View {
    @Binding var currentView: AppViews

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
    @State private var counter = 0.0
    @State private var current_beat = 0
    
    func createChordTimer() -> Timer {
        return Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { timer in
            counter += 0.001
            var time = (Double(beats[0]) * 60.0) / (Double(song.bpm!) * song.playBackspeed)
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
                    if(current_beat < beats.count) {
                        time = (Double(beats[current_beat]) * 60.0) / (Double(song.bpm!) * song.playBackspeed)
                    }

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
    }
    
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
                                
                                startBtnHidden = true
            
                                audioPlayer.recTapped()
                                recHidden.toggle()

                                let timer = createChordTimer()

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
                SidebarView(
                    currentView: $currentView,
                    chords: chords,
                    nextChords: $nextChords,
                    startBtnHidden: $startBtnHidden,
                    countdown: $countdown,
                    timerGoing: $timerGoing,
                    audioPlayer: audioPlayer
                )
            }
                // Correctness border
                // Turns green if user plays a chord correct, red if wrong
                .border(audioPlayer.borderColor, width: 10)
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