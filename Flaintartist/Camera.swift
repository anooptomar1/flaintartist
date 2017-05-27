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
@available(iOS 10.0, *)
var stillImageOutput: AVCapturePhotoOutput?



let screenWidth = UIScreen.main.bounds.size.width
let screenHeight = UIScreen.main.bounds.size.height
var aspectRatio: CGFloat = 1.0

var viewFinderHeight: CGFloat = 0.0
var viewFinderWidth: CGFloat = 0.0
var viewFinderMarginLeft: CGFloat = 0.0
var viewFinderMarginTop: CGFloat = 0.0

@available(iOS 10.0, *)
extension ProfileVC {
    
@available(iOS 10.0, *)
    func setupAVCapture(view: UIView, session: AVCaptureSession){
    session.sessionPreset = AVCaptureSessionPreset640x480
    guard let device = AVCaptureDevice .defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back) else{
        return
    }
    captureDevice = device
    beginSession(view: view, session: session)
}


    func beginSession(view: UIView, session: AVCaptureSession){
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
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    let rootLayer :CALayer = view.layer
    rootLayer.masksToBounds = true
    previewLayer.frame = UIScreen.main.bounds
    rootLayer.addSublayer(previewLayer)
   }
}

