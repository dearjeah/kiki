//
//  Helper.swift
//  Kiki
//
//  Created by Delvina J on 30/10/25.
//

import Foundation
import AVFoundation
import SwiftUI

public enum RecordingState: Equatable {
    case stopped
    case recording
    case paused
}

public enum PlaybackState: Equatable {
    case playing
    case notPlaying
}

public struct AudioData: @unchecked Sendable {
    var buffer: AVAudioPCMBuffer
    var time: AVAudioTime
}


extension AVAudioPlayerNode {
    var currentTime: TimeInterval {
        guard let nodeTime: AVAudioTime = self.lastRenderTime, let playerTime: AVAudioTime = self.playerTime(forNodeTime: nodeTime) else { return 0 }
        
        return Double(playerTime.sampleTime) / playerTime.sampleRate
    }
}
