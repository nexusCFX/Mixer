//
//  MusicPlayer.swift
//  Mixer
//
//  Created by Brandon Chester on 3/17/18.
//  Copyright © 2018 Brandy. All rights reserved.
//

import Foundation
import AVFoundation

class MixedMusicPlayer: NSObject, AVAudioPlayerDelegate {
    
    var currentPlayer:AVAudioPlayer?
    weak var delegate:MusicPlayerActionDelegate?
    
    func load(with fileURL: URL) {
        guard let newPlayer = try? AVAudioPlayer(contentsOf: fileURL) else { return }
        newPlayer.delegate = self
        newPlayer.isMeteringEnabled = true
        newPlayer.prepareToPlay()
        if let player = currentPlayer {
            player.stop()
        }
        currentPlayer = newPlayer
    }
    
    func play() {
        currentPlayer?.play()
    }
    
    func pause() {
        currentPlayer?.pause()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.musicPlayerDidEndPlayback(self)
    }
}

protocol MusicPlayerActionDelegate: AnyObject {
    func musicPlayerDidEndPlayback(_ player: MixedMusicPlayer)
}
