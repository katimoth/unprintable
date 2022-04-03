//
//  SwiftUIView.swift
//  dotti
//
//  Created by Evan Griffith on 4/2/22.
//

import SwiftUI


//Think this should be similar to a "detail view" where it pops out of the library shit
struct LibraryOverlayView: View {
    @Binding var currentView: AppViews
    var body: some View {
        NavigationView{
            NavigationLink(destination: LibraryView(currentView: $currentView)) {
                Text("Trade View Link")
            }.simultaneousGesture(TapGesture().onEnded(){
                currentView = AppViews.libraryView
                
            })
                .navigationBarItems(leading: Button(action: {currentView = .libraryView}) {
                HStack {
                    Image(systemName: "arrow.left")
                    Text("Back")
                }
            })
        }
        .animation(.linear(duration: 0.7))

    }
}

//struct ResultsView_Pre: PreviewProvider {
//    static var previews: some View {
//        Ru()
//    }
//}
