//
//  ResetPasswordVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import FirebaseAuth

class ResetPasswordVC: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var sendBtn: RoundedBtn!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var email = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        emailTextField.becomeFirstResponder()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ResetPasswordVC.textChanged(sender:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        sendBtn.isEnabled = false
        
        if !email.isEmpty {
            emailTextField.text = email
            sendBtn.isEnabled = true
            sendBtn.alpha = 1.0
        }
        
    }
    
    
    @IBAction func sendBtnTapped(_ sender: Any) {
        send()
    }
    
    
    @IBAction func backBtnTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        send()
        return true
    }
    
    
    func textChanged(sender: NSNotification) {
        if emailTextField.text == email {
            sendBtn.isEnabled = true
            sendBtn.alpha = 1
        }
        
        if emailTextField.hasText {
            sendBtn.isEnabled = true
            sendBtn.alpha = 1
        } else {
            sendBtn.isEnabled = false
            sendBtn.alpha = 0.7
        }
    }
    
    
    func send() {
        sendBtn.setTitle("", for: .normal)
        indicator.isHidden = false
        indicator.startAnimating()
        let email = emailTextField.text!
        let alert = Alerts()
        Auth.auth().sendPasswordReset(withEmail: email, completion: { (error) in
            if error != nil {
                alert.showAlert("Error", message: error!.localizedDescription, target: self)
                self.indicator.stopAnimating()
                self.sendBtn.setTitle("Send Link", for: .normal)
                
            } else {
                alert.showAlert("Email Sent", message: "We just send an email to \(email), to help you recover your account.", target: self)
                self.indicator.stopAnimating()
                self.sendBtn.setTitle("Send Link", for: .normal)
            }
        })
    }
}
