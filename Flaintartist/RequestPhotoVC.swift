//
//  RequestPhotoVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/12/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class RequestPhotoVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func requestBtnTapped(_ sender: Any) {
        
        let email = Defaults[.email]
        DataService.ds.REF_MAILGUN.sendMessage(to: "kerby.jean@hotmail.fr", from: email, subject: "Photographer Request", body: "Photographer Request", success: { (success) in
            self.confirmAlert(title:"Photographer have been successfully Requested." , message: "The photographer will get in contact with you in approximatively one day.")
        }, failure: { (error) in
            self.confirmAlert(title: "Request failed" , message: "Please verify your network connection and try again.")
        })

    }
    
    func confirmAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}
