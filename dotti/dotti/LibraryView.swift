//
//  LibraryView.swift
//  dotti
//
//  Created by Tohei Ichikawa. on 3/19/22.
//

import SwiftUI

struct LibraryView: View {
    @State private var searchText = ""
    @State private var isSearching = false

    var body: some View {
        ZStack {
            Color.floral_white.ignoresSafeArea()
            VStack() {
                Text("Library")
                    .font(Font.h1)
                    .foregroundColor(Color.american_bronze)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search by song or artist", text: $searchText)
                        .onTapGesture { self.isSearching = true }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if isSearching {
                        Button(action: { self.searchText = "" }) {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.gray)
                        }
                        Button(action: { 
                            self.isSearching = false
                            self.hideKeyboard()
                        }) {
                            Text("Cancel")
                        } 
                    }
                }
                    .padding()
                    .background(Color.pearl_aqua.opacity(0.5))
                    .cornerRadius(10)

                Text("Top Songs Today")
                    .font(Font.h2)
                    .foregroundColor(Color.american_bronze)
                    .frame(maxWidth: .infinity, alignment: .leading)
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(0..<100) {
                            Text("**All Too Well** \($0)")
                                // .font(.title)
                                .multilineTextAlignment(.leading)
                                
                                // .foregroundColor(Color.floral_white)
                                .background(Color.american_bronze)
                                // .font(.system(size: 10))
                                // .cornerRadius(5)
                                // .frame(width: 300, height: 35)
                                // .padding(25)
                        }
                    }.frame(maxWidth: .infinity)
                }
            }
                .frame(maxWidth: .infinity)
                .padding()
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
