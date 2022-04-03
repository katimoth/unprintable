//
//  Utilities.swift
//  dotti
//
//  Created by Tohei Ichikawa. on 3/19/22.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
			#selector(UIResponder.resignFirstResponder),
			to: nil,
			from: nil,
			for: nil
		)
    }
}

//struct Song {
//    private var songName = "All too Well"
//    private var songBPM: CGFloat
//    private var songDifficulty = "Easy"
//    
//}
