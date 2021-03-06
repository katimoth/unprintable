//
//  Song.swift
//  dotti
//
//  Created by Mary Keta on 3/30/22.
//

import Foundation

struct Song: Identifiable {
    var id: String
    var title: String?
    var artist: String?
    var bpm: Int?
    var chords: Array<Array<Any>>?
    var playBackspeed: Double = 1
}
