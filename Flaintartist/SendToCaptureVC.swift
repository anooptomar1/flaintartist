//
//  SendToCaptureVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 9/8/16.
//  Copyright © 2016 Kerby Jean. All rights reserved.
//

import UIKit

class SendToCaptureVC: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async(execute: { () -> Void in
            self.performSegue(withIdentifier: "GoToCaptureVC", sender: nil)
        })
    }
}



