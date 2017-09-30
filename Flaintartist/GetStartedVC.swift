//
//  GetStartedVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-27.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import AVFoundation
import FBSDKLoginKit
import FirebaseAuth


class GetStartedVC: UIViewController {
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var playerView: VideoContainerView!
    
    //let videoURL: NSURL = Bundle.main.url(forResource: "Showcase", withExtension: "mp4")! as NSURL
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setupPlayer(videoUrl: videoURL as URL, playerView: playerView, gravity: AVLayerVideoGravity.resizeAspectFill)
    }
    
    
    //    override func viewDidAppear(_ animated: Bool) {
    //        super.viewDidAppear(animated)
    //        player?.play()
    //    }
    //
    //    override func viewDidDisappear(_ animated: Bool) {
    //        super.viewDidDisappear(animated)
    //        player?.pause()
    //    }
    //
    //    func playerItemDidReachEnd() {
    //        player!.seek(to: kCMTimeZero)
    //    }
    //
    //    @objc func loopVideo() {
    //        player?.seek(to: kCMTimeZero)
    //        player?.play()
    //    }
    
    
    @IBAction func fbRegisterBtn(_ sender: UIButton) {
        sender.setTitle("", for: .normal)
        indicator.startAnimating()
        let vc = view.window?.rootViewController
        AuthService.instance.facebookSignIn(viewController: vc!) { (errMsg, data) in
            guard errMsg == nil else {
                return
            }
            self.indicator.stopAnimating()
        }
    }
}

