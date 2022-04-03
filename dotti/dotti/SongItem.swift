//
//  SongItem.swift
//  dotti
//
//  Created by Evan Griffith on 4/3/22.
//

import SwiftUI

struct SongItem: View {
    @State private var overlayActive: Bool = false
    @Binding var currentView: AppViews
//    @Binding var song: Song
    var body: some View {
        HStack(spacing: 15){
            Text("***All Too Well***")
                .foregroundColor(Color.american_bronze)
                .frame(width:160, height: 60)
                .multilineTextAlignment(.trailing)
                
            if !overlayActive{
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
            } else {
                VStack(alignment: .center, spacing: 6, content: {
                    Button("begin lesson") {currentView = AppViews.lessonView }
                        .foregroundColor(Color.american_bronze)
                        .frame(width: 140, height: 40)
                        .background(Color.pearl_aqua)
                        .shadow(radius: 15)
                        .font(.system(size: 16))
                        .cornerRadius(5)
                        .padding()
                })
            }
        }.background(Color.ruber.opacity(0.2))
            .cornerRadius(10)
            .onTapGesture {
                overlayActive.toggle()
            }
    }
}

//struct SongItem_Previews: PreviewProvider {
//    static var previews: some View {
//        SongItem()
//    }
//}
