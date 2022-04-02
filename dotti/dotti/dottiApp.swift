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
}

@main
struct dottiApp: App {
    @State var currentView = AppViews.titleView
    var body: some Scene {
        WindowGroup {
            switch (currentView) {
            case .titleView:
                TitleView($currentView)
            case .libraryView:
                LibraryView($currentView)
            default:
                print("Nope")
                throw NSError()
            }
            // TitleView()
            // LibraryView()
        }
    }
}
