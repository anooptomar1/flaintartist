//
//  VideoPlayer.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-07-01.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


import UIKit
import AVFoundation

var player: AVPlayer?

func setupPlayer(videoUrl: URL, playerView: UIView, gravity: AVLayerVideoGravity) {
    player = AVPlayer(url: videoUrl as URL)
    player?.actionAtItemEnd = .none
    player?.isMuted = true
    let playerLayer = AVPlayerLayer(player: player)
    playerLayer.videoGravity = gravity
    playerLayer.frame = playerView.bounds
    playerView.layer.addSublayer(playerLayer)
    player?.play()
    // add observer to watch for video end in order to loop video
   // NotificationCenter.default.addObserver(self, selector: #selector(loopVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player)
    
    // if video ends, will restart
}

