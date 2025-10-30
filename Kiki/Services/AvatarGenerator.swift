//
//  AvatarGenerator.swift
//  Kiki
//
//  Created by Fanny Halim on 29/10/25.
//

import Foundation
import ImagePlayground
import CoreGraphics
import Playgrounds
import SwiftUI

enum AvatarGenerationError: Error {
    case failedToGenerateKikiAvatar
    case failedToGenerateLearnerAvatar

}

final class AvatarGenerator {
    var isGenerating: Bool = false

    func generateAvatars(with persona: Kiki) async throws -> (CGImage, CGImage) {
        isGenerating = true

        let learnerPrompt =
        "Create monkey wearing a hoodie with a bow tie"
//            """
//            Create a modern, friendly avatar of a learner from \(persona.nationality).
//            The learner should look focused yet approachable.
//            Style it as a clean, vibrant digital illustration style.
//            The setting and clothing can subtly reflect the learner’s nationality.
//            Use bright colors, warm lighting, and a confident, curious expression.
//            """

        let kikiPrompt =
        "create a black cat play with \(persona.interest)"
//                """
//                Create a friendly, cartoon-style avatar of a 5-year-old child named \(persona.name).
//                The child is \(persona.sex), from \(persona.nationality), and loves \(persona.interest).
//                Show the child smiling, with expressive eyes and a playful pose that reflects their interests.
//                Use bright colors, soft lighting, and a cheerful, modern illustration style.
//                The background should be simple or themed around their interests.
//                Make the avatar look unique and full of personality — not generic.
//                """

        let learnerAvatar = try await generateImage(with: learnerPrompt)
        let kikiAvatar = try await generateImage(with: kikiPrompt)

        isGenerating = false

        guard let learnerImage = learnerAvatar else {
            throw AvatarGenerationError.failedToGenerateLearnerAvatar
        }
        guard let kikiImage = kikiAvatar else {
            throw AvatarGenerationError.failedToGenerateKikiAvatar
        }

        return (learnerImage, kikiImage)
    }

    private func generateImage(with prompt: String) async throws -> CGImage? {
        do {
            let imageCreator = try await ImageCreator()
            let style = ImagePlaygroundStyle.animation

            let images = imageCreator.images(
                for: [.text(prompt)],
                style: style,
                limit: 1
            )

            for try await image in images {
                return image.cgImage
            }

        }
        catch ImageCreator.Error.notSupported {
            print("Image creation not supported on the current device.")
        } catch {
            throw error
        }

        return nil
    }

    func generateAvatar(with avatarReference: CGImage) async throws -> CGImage? {
        do {
            let imageCreator = try await ImageCreator()
            let style = ImagePlaygroundStyle.illustration

            let images = imageCreator.images(
                for: [
                    .extracted(from: "A learner", title:
"""
                               Create a modern, friendly avatar of a learner from Indonesia.
                               The learner should look focused yet approachable.
                               Style it as a clean, vibrant digital illustration style.
                               The setting and clothing can subtly reflect the learner’s nationality.
                               Use bright colors, warm lighting, and a confident, curious expression.
"""),
                    .image(avatarReference)
                ],
                style: style,
                limit: 1
            )

            for try await image in images {
                return image.cgImage
            }
        } catch {
            throw error
        }

        return nil
    }

    func generateKiki(with persona: Kiki)  async throws -> CGImage? {
        do {
            let imageCreator = try await ImageCreator()
            let style = ImagePlaygroundStyle.animation
            let avatarReference = NSImage(named: persona.sex.rawValue)

            guard let cgImage = avatarReference?.cgImage else { return nil }

            let images = imageCreator.images(
                for: [
                    .extracted(from: "A learner", title:"""
                        Create an full body avatar of a 5-year-old child named \(persona.name).
                        The child is \(persona.sex), from \(persona.nationality), while do \(persona.interest).
                        Show the child smiling, with expressive eyes and a playful pose that reflects their interests.
                        Use bright colors, soft lighting, and a cheerful, modern illustration style.
                        The background should be simple or themed around their interests.
                        Make the avatar look unique and full of personality — not generic.)
                        """),
                    .image(cgImage)
                ],
                style: style,
                limit: 1
            )

            for try await image in images {
                return image.cgImage
            }
        } catch {
            throw error
        }

        return nil
    }
}

extension NSImage {
    var cgImage: CGImage? {
        // Try to get a CGImage from the image’s first representation
        guard let imageData = tiffRepresentation,
              let source = CGImageSourceCreateWithData(imageData as CFData, nil) else {
            return nil
        }
        return CGImageSourceCreateImageAtIndex(source, 0, nil)
    }
}


#Playground {
    let kiki = Kiki(
        name: "Kiki",
        sex: .boy,
        interest: .car,
        nationality: .korean
    )
    let generator = AvatarGenerator()

    do {
        var avatar = try await generator.generateKiki(with: kiki)
    } catch {
        print("💥 \(error.localizedDescription)")
    }
}
