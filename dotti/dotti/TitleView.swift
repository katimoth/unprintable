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
                gradient: Gradient(colors: [Color(red: 252 / 255, green: 209 / 255, blue: 162 / 255), .white]),
                startPoint: .top,
                endPoint: .bottom
            ).edgesIgnoringSafeArea(.all)
            VStack {
                Group {
                    Image("dotti_transparent.png")
                        .resizable()
                        .scaledToFit()
                    Text("dotti")
                        .font(.title)
                    HStack{
                        Button(action: {
                            print("tapped!")
                        }, label: {
                            Text("Login")
                                .foregroundColor(.white)
                                .frame(width: 100, height: 40)
                                .background(Color.green)
                                .cornerRadius(15)
                                .padding()
                        })
                        Button(action: {
                            print("tapped!")
                        }, label: {
                            Text("Register")
                                .foregroundColor(.white)
                                .frame(width: 100, height: 40)
                                .background(Color.green)
                                .cornerRadius(15)
                                .padding()
                        })
                    }
                }.frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        TitleView()
    }
}
