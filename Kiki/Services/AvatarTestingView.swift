//
//  AvatarTestingView.swift
//  Kiki
//
//  Created by Fanny Halim on 29/10/25.
//

import SwiftUI

struct AvatarTestingView: View {
    @State private var learnerAvatar: CGImage?
    @State private var kikiAvatar: CGImage?

    private var generator = AvatarGenerator()

    // The persona we’ll generate avatars for
    let kiki = Kiki(
        name: "Kiki",
        sex: .girl,
        interest: .dragon,
        nationality: .korean
    )

    var body: some View {
        HStack {
            Spacer()
            if let image = learnerAvatar {
                Image(
                    nsImage: NSImage(
                        cgImage: image,
                        size: NSSize(width: 200, height: 200)
                    )
                )
            } else {
                ProgressView("Learner: loading...")
                Spacer()
            }
            if let image = kikiAvatar {
                Image(
                    nsImage: NSImage(
                        cgImage: image,
                        size: NSSize(width: 200, height: 200)
                    )
                )
            } else {
                ProgressView("Kiki: loading...")
            }
            Spacer()
        }
        .task {
            do {
                let (learnerImg, kikiImg) = try await generator.generateAvatars(with: kiki)
                self.learnerAvatar = learnerImg
                self.kikiAvatar = kikiImg
                
            } catch {
                print(
                    "Failed to generate avatars: \(error.localizedDescription)"
                )
            }
        }
    }
}

#Preview {
    AvatarTestingView()
}
