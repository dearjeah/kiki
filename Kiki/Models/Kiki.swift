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
    case boy, girl
}

enum Interest: String, CaseIterable {
    case car
    case cooking
    case dragon
    case videoGame = "video game"
    case playOutside = "play outside"
}

enum Nationality: CaseIterable {
    case portuguese
    case korean
    case indonesian
}
