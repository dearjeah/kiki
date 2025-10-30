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

    func generateKiki(with persona: Kiki)  async throws -> CGImage? {
        isGenerating = true

        let extractedrompt: ImagePlaygroundConcept = .extracted(
            from: "Create a 5-year-old \(persona.nationality.rawValue) \(persona.sex.rawValue) that play with \(persona.interest.rawValue)."
        )
        let avatarReferenceImg = NSImage(named: persona.sex.rawValue)
        guard let avatarReferenceCg = avatarReferenceImg?.cgImage else { return nil }

        let kikiAvatar = try await generateImage(with: extractedrompt, referenceImg: avatarReferenceCg)

        isGenerating = false

        return kikiAvatar
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

    private func generateImage(with prompt: ImagePlaygroundConcept, referenceImg: CGImage?) async throws -> CGImage? {
        do {
            let imageCreator = try await ImageCreator()
            let style = ImagePlaygroundStyle.animation

            var concepts = [prompt]
            if let referenceImg = referenceImg {
                concepts.append(.image(referenceImg))
            }

            let images = imageCreator.images(
                for: concepts,
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
        interest: .ball,
        nationality: .korean
    )
    let generator = AvatarGenerator()

    do {
        var avatar = try await generator.generateKiki(with: kiki)
    } catch {
        print("💥 \(error.localizedDescription)")
    }
}
