//
//  Styles.swift
//  dotti
//
//  Created by Tohei Ichikawa. on 3/15/22.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        //! Untested
        // case 3: // RGB (12-bit)
        //     (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (0, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    static let american_bronze = Color("american-bronze")
    static let deep_champagne = Color("deep-champagne")
    static let floral_white = Color("floral-white")
    static let pearl_aqua = Color("pearl-aqua")
    static let pearl_aqua_tint_50 = Color("pearl-aqua_tint-50")
    static let pearl_aqua_tint_80 = Color("pearl-aqua_tint-80")
    static let ruber = Color(red: 206/255, green: 70/255, blue: 116/255)
}

extension Font {
    static let comfortaa_regular = "Comfortaa-Regular"
    static let h1 = Font.custom(comfortaa_regular, size: 40)
    static let h2 = Font.custom(comfortaa_regular, size: 30)
}
