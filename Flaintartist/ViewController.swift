//
//  ViewController.swift
//  Flaintartist
//
//  Created by Kerby Jean on 5/24/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate{
        
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 10.0, *) {
            //self.setupAVCapture(view: view)
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        // do stuff here
    }
    
    // clean up AVCapture
    func stopCamera(){
        session.stopRunning()
    }
}
