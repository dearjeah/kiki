//
//  AvatarPickerTestingView.swift
//  Kiki
//
//  Created by Fanny Halim on 30/10/25.
//

import SwiftUI
import PhotosUI

struct AvatarPickerTestingView: View {

    @State private var photoPickerItem: PhotosPickerItem?
    @State private var avatarReferenceNsImg: NSImage?
    @State private var avatarNsImg: NSImage?

    private var generator = AvatarGenerator()

    var body: some View {
        HStack{
            Spacer()
            PhotosPicker(
                selection: $photoPickerItem,
                matching: .not(.screenshots)
            ) {
                if let avatarReferenceNsImg {
                    Image(nsImage: avatarReferenceNsImg)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                }
            }

            Spacer()

            if let image = avatarNsImg {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                if avatarReferenceNsImg == nil {
                    Text("Waiting for reference photo...")
                } else {
                    ProgressView("...")
                }
            }
            Spacer()
        }
        .onChange(of: photoPickerItem) { _, _ in
            Task {
                if let photoPickerItem,
                   let data = try? await photoPickerItem.loadTransferable(type: Data.self),
                   let imageRep = NSBitmapImageRep(data: data) {

                    let nsImage = NSImage(size: imageRep.size)
                    nsImage.addRepresentation(imageRep)
                    avatarReferenceNsImg = nsImage

//                    if let rep = NSBitmapImageRep(data: data) {
//                        let nsImage = NSImage(size: rep.size)
//                        nsImage.addRepresentation(rep)
//                        avatarReferenceNsImg = nsImage
//                    }

//                    if let nsImage = NSImage(data: data) {
//                        avatarReferenceNsImg = nsImage
//                    }

//                    avatarNsImg = try? await generator.generateAvatar(with: avatarReferenceNsImg!)
                } else {

                }
            }
        }
    }
}

#Preview {
    AvatarPickerTestingView()
}
