//
//  MessageBubble.swift
//  Kiki
//
//  Created by Delvina J on 29/10/25.
//

import SwiftUI

struct MessagesBubble: View {
    var text: String = ""
    var date: String = ""
    var color: Color = .clear
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                Text(text)
            }.padding()
                .glassEffect(in: .rect(cornerRadius: 4))
            HStack {
                Text(date)
                    .font(.footnote)
                    .foregroundStyle(.gray)
            }
        }
    }
}
