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
    @Binding var songVar: Song?
    @State var song: Song
    @State var buttonColor: Color = Color.green
    @State var textColor: Color = Color.white
    var body: some View {
        HStack(spacing: 5){
            Text(song.title!)
                .foregroundColor(Color.american_bronze)
                .frame(width:180, height: 60)
                .multilineTextAlignment(.trailing)
                
            if !overlayActive{
                VStack(alignment: .leading, spacing: 6, content: {
                
                    Text(song.artist!)
                        .frame(height: 22)
                        .foregroundColor(.black)
                        .font(.system(size: 16).italic())
                        .padding(.trailing)
                    
//                    Text("BPM: " + String(song.bpm!))
//                        .frame(height: 22)
//                        .foregroundColor(.black)
//                        .font(.system(size: 16).italic())
//                        .padding(.trailing, 85)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.5))
                        .frame(height: 22)
                        .padding(.trailing)

                })
            } else {
                
                HStack (alignment: .center, spacing: 6){
                    Button(String(song.playBackspeed) + "x") {
                        if(song.playBackspeed == 0.25) {
                            song.playBackspeed = 1
                        } else {
                            song.playBackspeed -= 0.25
                        }
                        
                        if(song.playBackspeed == 1) {
                            buttonColor = Color.green
                            textColor = Color.white
                        } else if (song.playBackspeed == 0.75) {
                            buttonColor = Color.yellow
                            textColor = Color.white
                        } else if (song.playBackspeed == 0.50) {
                            buttonColor = Color.orange
                            textColor = Color.white
                        } else {
                            buttonColor = Color.red
                            textColor = Color.white
                        }
                    }.animation(.spring())
                    .foregroundColor(textColor)
                    .frame(width: 50, height: 40)
                    .background(buttonColor)
                    .shadow(radius: 15)
                    .font(.system(size: 16))
                    .cornerRadius(5)
                    
                    
                    
                    
                    Button("begin") {
                        songVar = song
                        currentView = .lessonView
                        
                    }
                        .foregroundColor(Color.american_bronze)
                        .frame(width: 75, height: 40)
                        .background(Color.pearl_aqua)
                        .shadow(radius: 15)
                        .font(.system(size: 16))
                        .cornerRadius(5)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                
                }
            }
        }.background(Color.ruber.opacity(0.2))
            .cornerRadius(10)
            .onTapGesture {
                if overlayActive {
                    song.playBackspeed = 1
                    buttonColor = Color.green
                }
                overlayActive.toggle()
            }
    }
}

//struct SongItem_Previews: PreviewProvider {
//    static var previews: some View {
//        SongItem()
//    }
//}
