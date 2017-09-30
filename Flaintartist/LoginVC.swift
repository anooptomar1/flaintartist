//
//  LoginVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-27.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class LogInVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var logInBtn: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    let alert = Alerts()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.lightGray
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style: .plain, target: nil, action: nil)
        
        //        emailField.delegate = self
        //        passwordField.delegate = self
        //
        //        emailField.text = Defaults[.email]
        //
        //        NotificationCenter.default.addObserver(self, selector: #selector(LogInVC.textChanged(sender:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        //        logInBtn.isEnabled = false
    }
    
    
    @IBAction func fbLogInTapped(_ sender: Any) {
        AuthService.instance.facebookLogIn(viewController: self) { (errMsg, data) in
            guard errMsg == nil else {
                //self.indicator.stopAnimating()
                return
            }
        }
        
    }
    
    @IBAction func logInBtnTapped(_ sender: UIButton) {
        logIn()
    }
    
    @IBAction func forgotBtnTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "ResetPasswordVC", sender: emailField.text!)
    }
    
    @IBAction func createAccountBtnTapped(_ sender: AnyObject) {
        let createAccount = storyboard?.instantiateViewController(withIdentifier: "ChooseAccountTypeNav")
        present(createAccount!, animated: true, completion: nil)
    }
    
    
    
    //MARK: Functions
    func errorAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Try again", style: .default, handler: nil)
        alertVC.addAction(action)
        present(alertVC, animated: true, completion: nil)
    }
    
    
    func indicatorAnim() {
        if indicator.isAnimating == true {
            logInBtn.setTitle("", for: .normal)
        } else {
            logInBtn.setTitle("Enter", for: .normal)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            passwordField.resignFirstResponder()
            logIn()
        }
        
        return true
    }
    
    
    func logIn() {
        //logInBtn.BtnTapped()
        logInBtn.setTitle("", for: .normal)
        indicator.isHidden = false
        indicator.startAnimating()
        passwordField.resignFirstResponder()
        if let email = emailField.text, let pwd = passwordField.text {
            AuthService.instance.logIn(email: email, password: pwd, onComplete: { (errMsg, data) in
                guard errMsg == nil else {
                    self.alert.showAlert("Error", message: errMsg!, target: self)
                    self.logInBtn.setTitle("Log In", for: .normal)
                    self.indicator.stopAnimating()
                    return
                }
            })
        }
    }
    
    func textChanged(sender: NSNotification) {
        if emailField.hasText && passwordField.hasText  {
            logInBtn.isEnabled = true
            logInBtn.alpha = 1
        } else {
            logInBtn.isEnabled = false
            logInBtn.alpha = 0.7
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ResetPasswordVC" {
//            let resetPasswordVC = segue.destination as! ResetPasswordVC
//            let email = sender as! String
//            resetPasswordVC.email = email
//        }
//    }
}
