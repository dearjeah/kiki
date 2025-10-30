//
//  SpeechHelpers.swift
//  Kiki
//
//  Created by Delvina J on 30/10/25.
//

import Foundation
import SwiftUI
import Speech
import AVFoundation

extension DictationView {
    func handlePlayback() {
        guard story.url != nil else {
            return
        }
        
        if isPlaying {
            recorder.playRecording()
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                currentPlaybackTime = recorder.playerNode?.currentTime ?? 0.0
            }
        } else {
            recorder.stopPlaying()
            currentPlaybackTime = 0.0
            timer = nil
        }
    }
    
    func handleRecordingButtonTap() {
        isRecording.toggle()
    }
    
    func handlePlayButtonTap() {
        isPlaying.toggle()
    }
    
    @ViewBuilder func textScrollView(attributedString: AttributedString) -> some View {
        ScrollView {
            VStack(alignment: .leading) {
                textWithHighlighting(attributedString: attributedString)
                Spacer()
            }
        }
    }
    
    func attributedStringWithCurrentValueHighlighted(attributedString: AttributedString) -> AttributedString {
        var copy = attributedString
        copy.runs.forEach { run in
            if shouldBeHighlighted(attributedStringRun: run) {
                let range = run.range
                copy[range].backgroundColor = .mint.opacity(0.2)
            }
        }
        return copy
    }
    
    func shouldBeHighlighted(attributedStringRun: AttributedString.Runs.Run) -> Bool {
        guard isPlaying else { return false }
        let start = attributedStringRun.audioTimeRange?.start.seconds
        let end = attributedStringRun.audioTimeRange?.end.seconds
        guard let start, let end else {
            return false
        }
        
        if end < currentPlaybackTime { return false }
        
        if start < currentPlaybackTime, currentPlaybackTime < end {
            return true
        }
        
        return false
    }
    
    @ViewBuilder func textWithHighlighting(attributedString: AttributedString) -> some View {
        Group {
            Text(attributedStringWithCurrentValueHighlighted(attributedString: attributedString))
                .font(.title)
        }
    }
}
