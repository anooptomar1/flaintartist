//
//  LogInVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SwiftyUserDefaults

class LogInVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var logInBtn: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.flatWhite()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style: .plain, target: nil, action: nil)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        emailField.text = Defaults[.email]
        
        NotificationCenter.default.addObserver(self, selector: #selector(FeedbackVC.textChanged(sender:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        logInBtn.isEnabled = false
    }
    
    
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("Kurbs: Unable to authenticate with Firebase - \(error)")
            } else {
                print("Kurbs: Successfully authenticated with Firebase")
                if let user = user {
                    let userData = ["provider": credential.provider]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
            }
        })
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
    
    
    func userType(id: String) {
        let usersRef = FIRDatabase.database().reference().child("users").child(id)
        usersRef.observe(.value, with: { snapshot in
            if let type =  ((snapshot.value as? NSDictionary)?["userType"] as! String?) {
                if type == "fan" {
                self.performSegue(withIdentifier: "TabBarVC", sender: nil)
                }
            }
            return
        })
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
        logInBtn.BtnTapped()
        logInBtn.setTitle("", for: .normal)
        indicator.isHidden = false
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        
        if let email = emailField.text, let pwd = passwordField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        Defaults[.email] = email
                        self.logInBtn.setTitle("Enter", for: .normal)
                        self.userType(id: user.uid)
                        self.completeSignIn(id: user.uid, userData: userData)
                        self.indicator.stopAnimating()
                    }
                } else {
                    let alert = Alerts()
                    alert.showAlert("Error", message: error!.localizedDescription, target: self)
                    self.indicator.stopAnimating()
                    self.logInBtn.setTitle("Enter", for: .normal)
                    return
                }
            })
        }
    }
    
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        Defaults[.key_uid] = id
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ResetPasswordVC" {
            let resetPasswordVC = segue.destination as! ResetPasswordVC
            let email = sender as! String
            resetPasswordVC.email = email
        }
    }
}
