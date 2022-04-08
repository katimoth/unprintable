//
//  MusicUtilities.swift
//  dotti
//
//  Created by Tohei Ichikawa. on 4/6/22.
//

enum Note: String {
    case c_doubleFlat = "C𝄫"
    case c_flat = "C♭"
    case c = "C"
    case c_natural = "C♮"
    case c_sharp = "C♯"
    case c_doubleSharp = "C𝄪"

    case d_doubleFlat = "D𝄫"
    case d_flat = "D♭"
    case d = "D"
    case d_natural = "D♮"
    case d_sharp = "D♯"
    case d_doubleSharp = "D𝄪"

    case e_doubleFlat = "E𝄫"
    case e_flat = "E♭"
    case e = "E"
    case e_natural = "E♮"
    case e_sharp = "E♯"
    case e_doubleSharp = "E𝄪"

    case f_doubleFlat = "F𝄫"
    case f_flat = "F♭"
    case f = "F"
    case f_natural = "F♮"
    case f_sharp = "F♯"
    case f_doubleSharp = "F𝄪"

    case g_doubleFlat = "G𝄫"
    case g_flat = "G♭"
    case g = "G"
    case g_natural = "G♮"
    case g_sharp = "G♯"
    case g_doubleSharp = "G𝄪"

    case a_doubleFlat = "A𝄫"
    case a_flat = "A♭"
    case a = "A"
    case a_natural = "A♮"
    case a_sharp = "A♯"
    case a_doubleSharp = "A𝄪"

    case b_doubleFlat = "B𝄫"
    case b_flat = "B♭"
    case b = "B"
    case b_natural = "B♮"
    case b_sharp = "B♯"
    case b_doubleSharp = "B𝄪"

    func callAsFunction() -> String {
        return self.rawValue
    }
}

struct Chord {
    enum Quality {
        case dim
        case halfDim
        case min
        case maj
        case aug
        case perfect
    }

    enum Inversion {
        case first
        case second
        case third
    }

    enum Suspension {
        case sus2
        case sus4
        case sus9
    }

    enum Extension {
        case ninth
        case eleventh
        case thirteenth
    }

    init(
        root: Note,
        quality: Quality,
        seventh: Bool = false,
        inversion: Inversion? = nil,
        suspension: Suspension? = nil,
        `extension`: Extension? = nil
    ) {
        self.root = root
        self.quality = quality
        self.seventh = seventh
        self.inversion = inversion
        self.suspension = suspension
        self.extension = `extension`
    }

    let root: Note
    let quality: Quality
    let seventh: Bool
    let inversion: Inversion?
    let suspension: Suspension?
    let `extension`: Extension?
}
