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

enum Sex: CaseIterable {
    case boy, girl
}

enum Interest: String, CaseIterable {
    case car = "Car"
    case cooking = "Cooking"
    case dragon = "Dragon"
    case videoGame = "Video Game"
    case playOutside = "Play Outside"
}

enum Nationality: String, CaseIterable {
    case brazillian = "Brazillian"
    case korean = "Korean"
    case indonesian = "Indonesian"
}
