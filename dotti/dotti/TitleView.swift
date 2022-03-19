//
//  TitleView.swift
//  dotti
//
//  Created by Tohei Ichikawa. on 3/11/22.
//

import SwiftUI

// rgb(252,209,162) navajo white
struct TitleView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 252 / 255, green: 209 / 255, blue: 162 / 255), Color(red: 252 / 255, green: 209 / 255, blue: 162 / 255), .white]),
                startPoint: .top,
                endPoint: .bottom
            ).edgesIgnoringSafeArea(.all)
            VStack {
                Group {
                    Spacer()
                    Group {
                        Image("icon-logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150.0, height: 150.0)
                        Text("dotti")
                            .font(.title)
                        
                    }
                    Spacer()
                    HStack{
                        Button(action: {
                            print("tapped!")
                        }, label: {
                            Text("**REGISTER**")
                                .foregroundColor(Color(red: 52 / 255, green: 28 / 255, blue: 9 / 255))
                                .frame(width: 120, height: 40)
                                .background(.clear)
                                .cornerRadius(5)
                                .font(
                                    .system(size: 16)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5.0)
                                        .stroke(Color(red: 52 / 255, green: 28 / 255, blue: 9 / 255), lineWidth: 2.0)
                                )
                                .padding()
                        })
                        Button(action: {
                            print("tapped!")
                        }, label: {
                            Text("**LOGIN**")
                                .foregroundColor(.white)
                                .frame(width: 180, height: 40)
                                .background(Color(red: 52 / 255, green: 28 / 255, blue: 9 / 255))
                                .font(
                                    .system(size: 16)
                                )
                                .cornerRadius(5)
                                .padding()
                        })
                    }
                }//.frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        TitleView()
    }
}
