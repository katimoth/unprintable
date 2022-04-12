//
//  dottiApp.swift
//  dotti
//
//  Created by Tohei Ichikawa. on 3/11/22.
//

import SwiftUI

enum AppViews {
    case titleView
    case libraryView
    case lessonView
}

@main
struct dottiApp: App {
    @State var currentView = AppViews.titleView
    @State var song: Song?
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    
    var body: some Scene {
        WindowGroup {
            switch (currentView) {
            case .titleView:
                ZStack {
                    TitleView(currentView: $currentView).transition(.move(edge: .bottom))
                    ResultsView()
                }
            case .libraryView:
                LibraryView(currentView: $currentView, song: $song).transition(.move(edge: .bottom))
            case .lessonView:
                GuitarLessonView(song: song!, currentView: $currentView)
            
//            case .lessonView:
//                GuitarLessonView(chordProgression: $song.chords!)
//                GuitarLessonView(chordProgression: [
//                    Chord(root: Note.g_sharp, quality: Chord.Quality.maj),
//                    // Chord(root: Note.e_sharp, quality: Chord.Quality.min),
//                    // Chord(root: Note.c_sharp, quality: Chord.Quality.maj),
//                    // Chord(root: Note.d_sharp, quality: Chord.Quality.maj, seventh: true),
//                    // Chord(root: Note.g_sharp, quality: Chord.Quality.maj),
//                    // Chord(root: Note.e_sharp, quality: Chord.Quality.min),
//                    // Chord(root: Note.c_sharp, quality: Chord.Quality.maj),
//                    // Chord(root: Note.d_sharp, quality: Chord.Quality.maj, seventh: true),
//                    // Chord(root: Note.g_sharp, quality: Chord.Quality.maj),
//                    // Chord(root: Note.e_sharp, quality: Chord.Quality.min),
//                    // Chord(root: Note.c_sharp, quality: Chord.Quality.maj),
//                    // Chord(root: Note.d_sharp, quality: Chord.Quality.maj, seventh: true),
//                    // Chord(root: Note.g_sharp, quality: Chord.Quality.maj),
//                    // Chord(root: Note.e_sharp, quality: Chord.Quality.min),
//                    // Chord(root: Note.c_sharp, quality: Chord.Quality.maj),
//                    // Chord(root: Note.d_sharp, quality: Chord.Quality.maj, seventh: true),
//                    // Chord(root: Note.g_sharp, quality: Chord.Quality.maj),
//                    // Chord(root: Note.e_sharp, quality: Chord.Quality.min),
//                    // Chord(root: Note.c_sharp, quality: Chord.Quality.maj),
//                    // Chord(root: Note.d_sharp, quality: Chord.Quality.maj, seventh: true),
//
//                    Chord(root: Note.a, quality: Chord.Quality.maj),
//                    Chord(root: Note.b, quality: Chord.Quality.maj),
//                    Chord(root: Note.c, quality: Chord.Quality.maj),
//                    Chord(root: Note.d, quality: Chord.Quality.maj),
//                    Chord(root: Note.e, quality: Chord.Quality.maj),
//                    Chord(root: Note.f, quality: Chord.Quality.maj),
//                    Chord(root: Note.g, quality: Chord.Quality.maj),
//                ])
            }
            EmptyView()
        }
    }
}
