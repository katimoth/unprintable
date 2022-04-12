//
//  TitleView.swift
//  dotti
//
//  Created by Tohei Ichikawa. on 3/11/22.
//

import SwiftUI

struct TitleView: View {

    @Binding var currentView: AppViews

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.deep_champagne,
                    Color.deep_champagne,
                    Color.floral_white
                ]),
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
                            .font(Font.custom("GochiHand-Regular", size: 50))
                            .foregroundColor(Color.american_bronze)
                    }
                    Spacer()
                    HStack{
//                        Button(action: {
//                            print("tapped!")
//                            currentView = AppViews.libraryView
//                        }, label: {
//                            Text("**REGISTER**")
//                                .foregroundColor(Color.american_bronze)
//                                .frame(width: 120, height: 40)
//                                .background(.clear)
//                                .cornerRadius(5)
//                                .font(.system(size: 16))
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 5.0)
//                                        .stroke(Color.american_bronze, lineWidth: 2.0)
//                                )
//                                .padding()
//                        })
                        Button(action: {
                            print("tapped!")
                            currentView = AppViews.libraryView
                        }, label: {
                            Text("**CONTINUE**")
                                .foregroundColor(Color.floral_white)
                                .frame(width: 340, height: 40)
                                .background(Color.american_bronze)
                                .font(.system(size: 20))
                                .cornerRadius(5)
                                .padding()
                        })
                    }
                }
            }
        }
//        .transition(.move(edge: .leading))
        .animation(.easeInOut(duration: 0.7))
    }
}
//
//struct TitleView_Previews: PreviewProvider {
//    static var previews: some View {
//        TitleView()
//    }
//}
