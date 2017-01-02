//
//  FeedbackVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import FirebaseAuth

class FeedbackVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var feedbackTitleLbl: UILabel!
    @IBOutlet weak var feedbackDescLbl: UILabel!
    
    var report: [String] = []
    
    var sendBtn: UIBarButtonItem!
    var alert = Alerts()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        textView.becomeFirstResponder()
        
        sendBtn = UIBarButtonItem(title: "Send", style: .done, target: self, action:  #selector(FeedbackVC.sendFeedback))
        self.navigationItem.rightBarButtonItem = sendBtn
        self.navigationItem.title = "Feedback"
        
        feedbackTitleLbl.text = report[0]
        feedbackDescLbl.text = report[1]
        
        NotificationCenter.default.addObserver(self, selector: #selector(FeedbackVC.textChanged(sender:)), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }
    
    
    
    func sendFeedback() {
        
        if textView.text == "" {
            alert.showAlert("Empty", message: "Unable to send an empty message.", target: self)
            return
        }
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        activityIndicator.hidesWhenStopped = true
        let spinner: UIBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.rightBarButtonItem = spinner
        
        //            let email = UserDefaults.standard.value(forKey: "artistEmail") as! String
        //            let subject = report[0]
        //            let body = textView.text!
        //            let mailgun = Mailgun.client(withDomain: "sandbox079d656352f446b18afea9698cd9cec1.mailgun.org", apiKey: "key-e54a16504f3f85f0775df25ab5a65dd8")
        //
        //            mailgun?.sendMessage(to: "kerby.jean@hotmail.fr", from: email, subject: subject , body: body, success: { (success) in
        //                print("Email Sent")
        //                activityIndicator.stopAnimating()
        //                self.thanksAlert()
        //                }, failure: { (error) in
        //                print("Error sending Email\(error?.localizedDescription)")
        //                activityIndicator.stopAnimating()
        //            })
    }
    
    func textChanged(sender: NSNotification) {
        if textView.hasText  {
            sendBtn.isEnabled = true
        } else {
            sendBtn.isEnabled = false
        }
    }
    
    
    func thanksAlert() {
        let alert = UIAlertController(title: "Thank you", message: "Your feedback help make the app better. We'll contact you if we need more details.", preferredStyle: .alert)
        let close = UIAlertAction(title: "Close", style: .default) { (UIAlertAction) in
            self.navigationController!.popViewController(animated: true)
        }
        alert.addAction(close)
        present(alert, animated: true, completion: nil)
    }
}
