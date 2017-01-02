//
//  CaptureVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit

class CaptureVC: UIViewController {
    
    @IBOutlet var cameraView: IPDFCameraViewController!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cameraView.setupCameraView()
        self.cameraView.isBorderDetectionEnabled = true
        self.cameraView.cameraViewType = .normal
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.flatWhite()
    }
    
    
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        let tabBarVC = storyboard?.instantiateViewController(withIdentifier: "TabBarVC")
        self.present(tabBarVC!, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.cameraView.start()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.cameraView.stop()
    }
    
    
    @IBAction func captureBtnTapped(_ sender: AnyObject) {
        self.cameraView.captureImage(completionHander: { (image) in
                let captureImageView = UIImageView(image: UIImage(contentsOfFile: image!)!)
                if let artImage = captureImageView.image  {
                    self.performSegue(withIdentifier: "CaptureDetailsVC", sender: artImage)
                }
          }
    )}

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CaptureDetailsVC" {
            let vc = segue.destination as! CaptureDetailsVC
            if let img = sender as? UIImage {
                vc.artImg = img
            }
        }
    }
}
