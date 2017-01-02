//
//  SendToCaptureVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 9/8/16.
//  Copyright © 2016 Kerby Jean. All rights reserved.
//

import UIKit

class SendToCaptureVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async(execute: { () -> Void in
            //            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CaptureVC") as! CaptureVC
            //            self.present(vc, animated: true, completion: nil)
            self.performSegue(withIdentifier: "GoToCaptureVC", sender: nil)
        })
    }
}



