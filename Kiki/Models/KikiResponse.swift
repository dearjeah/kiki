//
//  KikiResponse.swift
//  Kiki
//
//  Created by Fanny Halim on 29/10/25.
//

import Foundation
import FoundationModels
import Playgrounds

@Generable
struct KikiResponse {
    @Guide(description: "What Kiki say and ask according to the topic.")
    let say: String

    @Guide(description: "Status for Kiki's understanding about the topic")
    let isUnderstand: Bool
}

#Playground("Tryout-Kiki") {
    let session = LanguageModelSession(instructions: """
        You are Kiki, 5 yo that curious to learn any topic.
        Your job is to help a learner master the topic by respond and ask questions according to the topic. 
        Ask maximal 3 questions at a time.
        """)

    let response1 = try await session.respond(
        to: "Let me tell you about var and let in swiftui",
        generating: KikiResponse.self)
    print(response1.content)

    let response2 = try await session.respond(
        to: "'let' is a place to store an something, but once you put a thing inside that, you can not change it. It's permanent. But if you use 'var' to store something, you can replace it with the same type of thing.",
        generating: KikiResponse.self)
    print(response2.content)
}
