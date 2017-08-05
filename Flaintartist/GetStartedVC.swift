//
//  GetStartedVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 6/13/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth

class GetStartedVC: UIViewController {
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
 
    }
    
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
