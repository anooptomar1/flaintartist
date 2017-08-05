//
//  InviteFriendsVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit

import UIKit
import MessageUI

class InviteFriendsVC: UIViewController, MFMailComposeViewControllerDelegate {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var array = [48049,24910,50002,27375,20297,27767,22894,41655,26067,40227,45202,37720,24107,25074]
    
    let alert = Alerts()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func inviteBtnTapped(_ sender: Any) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            alert.showAlert("Oups something went wrong", message: "Your Iphone doesn't seem to be able to sent emails", target: self)
        }
    }
    
    
    @IBAction func dismissBtnTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let randomCode = Int(arc4random_uniform(UInt32(array.count)))
        print(array[randomCode])
        let code = array[randomCode]
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setSubject("Go download this awesome App...")
        mailComposerVC.setMessageBody("Hi, to enter the app you will need to use my code \(code)", isHTML: false)
        return mailComposerVC
    }
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if error != nil {
            alert.showAlert("Oups something went wrong", message: "We we're unable to send the email", target: self)
            return
        } else {
            alert.showAlert("Email succesfully sent", message:"", target: self)
        }
        controller.dismiss(animated: true, completion: nil)
    }
}
