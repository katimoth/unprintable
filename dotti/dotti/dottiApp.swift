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
    case resultsView
    case lessonView
}

@main
struct dottiApp: App {
    @State var currentView = AppViews.titleView
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            switch (currentView) {
            case .titleView:
                TitleView(currentView: $currentView).transition(.move(edge: .bottom))
            case .libraryView:
                LibraryView(currentView: $currentView).transition(.move(edge: .bottom))
            case .resultsView:
                EmptyView()
            case .lessonView:
                GuitarLessonView()
            }
            EmptyView()
        }
    }
}
