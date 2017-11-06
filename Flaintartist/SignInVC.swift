//
//  LoginVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-27.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftyUserDefaults

class SignInVC: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInBtn: UIButton!
    
    private let alert = Alerts()
    private let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailField.delegate = self
        passwordField.delegate = self
        emailField.text = Defaults[.email] 
        NotificationCenter.default.addObserver(self, selector: #selector(SignInVC.textChanged(sender:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        signInBtn.isEnabled = false
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .gray
        let spinner: UIBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.rightBarButtonItem = spinner
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func register(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "RegisterNav") as! UINavigationController
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func signIn(_ sender: Any) {
        passwordField.resignFirstResponder()
        activityIndicator.startAnimating()
        AuthService.instance.signIn(email: emailField.text!, password: passwordField.text!) { (success, error) in
            if !success! {
                self.activityIndicator.stopAnimating()
                self.alert.showNotif(text: error!.localizedDescription, vc: self, backgroundColor: UIColor.notifBackgroundColor , textColor: UIColor.white, autoHide: true, position: .top)
                return
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
    }

    
    //MARK: Functions
    func errorAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Try again", style: .default, handler: nil)
        alertVC.addAction(action)
        present(alertVC, animated: true, completion: nil)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            passwordField.resignFirstResponder()
            //logIn()
        }
        
        return true
    }

    
    @objc func textChanged(sender: NSNotification) {
        if emailField.hasText && passwordField.hasText  {
            signInBtn.isEnabled = true
        } else {
            signInBtn.isEnabled = false
        }
    }
}
