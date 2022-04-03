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
    //For Scroll Offset
    @State private var scrollViewOffset: CGFloat = 0
    @State private var startOffset: CGFloat = 0
    @Binding var currentView: AppViews

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
                    .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
                
                //ScrollView
                    .transition(.move(edge: .bottom))
                //Scroll to top
                ScrollViewReader { proxyReader in
                    ScrollView(.vertical, showsIndicators: false, content: {
                        
                        VStack(spacing: 25) {
                            ForEach(1...30, id: \.self){index in
                                HStack(spacing: 15){
                                    Text("***All Too Well***")
                                        .foregroundColor(Color.american_bronze)
                                        .frame(width:160, height: 60)
                                        .multilineTextAlignment(.trailing)
                                        
                                    
                                    VStack(alignment: .leading, spacing: 6, content: {
                                        
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.gray.opacity(0.5))
                                            .frame(height: 22)
                                            .padding(.trailing)
                                        
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.gray.opacity(0.5))
                                            .frame(height: 22)
                                            .padding(.trailing, 100)
                                    })
                                }.background(Color.ruber.opacity(0.2))
                                    .cornerRadius(10)
                            }.onTapGesture {
                                currentView = AppViews.resultsView
                            }
                        }
                        .padding()
                        
                        .id("SCROLL_TO_TOP")
                        //getting scrollView Offset
                        .overlay(
                        
                            
                            //GeometryReader
                            GeometryReader{proxy -> Color in
                                
                                DispatchQueue.main.async {
                                    
                                    if startOffset == 0{
                                        self.startOffset = proxy.frame(in: .global).minY
                                    }
                                    
                                    let offset = proxy.frame(in: .global).minY
                                    self.scrollViewOffset = offset - startOffset
                                }
                                
                                
                                return Color.clear
                            }
                                .frame(width: 0, height: 0)
                                ,alignment: .top
                        )
                    })
                    .overlay(
                    
                        Button(action:{
                            withAnimation(.spring()){
                                proxyReader.scrollTo("SCROLL_TO_TOP", anchor: .top)
                            }
                        }, label: {
                            
                            Image(systemName: "arrow.up")
                                .font(.system(size:20, weight: .semibold))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.american_bronze)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.0), radius: 10, x: 0.0, y: 0.0)
                            
                        })
                            .padding(.trailing)
                            .padding(.bottom, getSafeArea().bottom == 0 ? 12 : 0)
                            .opacity( -scrollViewOffset > 450 ? 1 : 0)
                            .animation(.easeInOut(duration: 1))
                            ,alignment: .bottomTrailing
                    )
                }.transition(.move(edge: .bottom))
            }.frame(maxWidth: .infinity)
                .padding()
            
        }.transition(.slide)
    }
}

//struct LibraryView_Previews: PreviewProvider {
//    @Binding var currentView: AppViews
//    static var previews: some View {
//        LibraryView(currentView: $currentView)
//.previewInterfaceOrientation(.portraitUpsideDown)
//    }
//}

extension View{
    
    func getSafeArea()->UIEdgeInsets{
        return UIApplication.shared.windows.first?.safeAreaInsets ?? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
