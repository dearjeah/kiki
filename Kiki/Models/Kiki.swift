//
//  Kiki.swift
//  Kiki
//
//  Created by Fanny Halim on 29/10/25.
//

import Foundation

struct Kiki {
    var name: String
    var sex: Sex
    var interest: Interest
    var nationality: Nationality
}

enum Sex: String, CaseIterable {
    case male, female
    case other = "Other / Unspecified"
}

enum Interest: String, CaseIterable {
    case animalNature = "Animals / Nature"
    case spaceScience = "Space / Science"
    case artDrawingMusic = "Art / Drawing / Music"
    case sportMovement = "Sports / Movement"
    case storiesFantasy = "Stories / Fantasy"
    case other = "Other / None"
}

enum Nationality: String, CaseIterable {
    case brazillian = "Brazilian"
    case korean = "Korean"
    case indonesian = "Indonesian"
    case african = "African"
    case other = "Other / Unspecified"
}
