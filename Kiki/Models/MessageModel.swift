//
//  MessageModel.swift
//  Kiki
//
//  Created by Delvina J on 29/10/25.
//

import SwiftUI

enum MessageType {
    case user
    case bot
}

struct MessageModel: Hashable {
    var id = UUID()
    var messages: String
    var type: MessageType
    var timeDate: String = ""
}
