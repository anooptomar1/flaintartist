//
//  Camera.swift
//  Flaintartist
//
//  Created by Kerby Jean on 5/24/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


import AVFoundation

var videoDataOutput: AVCaptureVideoDataOutput!
var videoDataOutputQueue: DispatchQueue!
var previewLayer:AVCaptureVideoPreviewLayer!
var captureDevice : AVCaptureDevice!
let session = AVCaptureSession()

@available(iOS 10.0, *)
extension ProfileVC {
    
@available(iOS 10.0, *)
    func setupAVCapture(view: UIView){
    session.sessionPreset = AVCaptureSessionPreset640x480
    guard let device = AVCaptureDevice .defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back) else{
        return
    }
    captureDevice = device
    beginSession(view: view)
}

func beginSession(view: UIView){
    var err : NSError? = nil
    var deviceInput:AVCaptureDeviceInput?
    do {
        deviceInput = try AVCaptureDeviceInput(device: captureDevice)
    } catch let error as NSError {
        err = error
        deviceInput = nil
    }
    if err != nil {
        print("error: \(String(describing: err?.localizedDescription))");
    }
    if session.canAddInput(deviceInput){
        session.addInput(deviceInput);
    }
    
    videoDataOutput = AVCaptureVideoDataOutput()
    videoDataOutput.alwaysDiscardsLateVideoFrames=true
    videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
    videoDataOutput.setSampleBufferDelegate(self as AVCaptureVideoDataOutputSampleBufferDelegate, queue: videoDataOutputQueue)
    if session.canAddOutput(videoDataOutput){
        session.addOutput(videoDataOutput)
    }
    videoDataOutput.connection(withMediaType: AVMediaTypeVideo).isEnabled = true
    
    previewLayer = AVCaptureVideoPreviewLayer(session: session)
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspect
    
    let rootLayer :CALayer = view.layer
    rootLayer.masksToBounds = true
    previewLayer.frame = rootLayer.bounds
    rootLayer.addSublayer(previewLayer)
    session.startRunning()
}

}

