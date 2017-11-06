//
//  RegisterNextVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-10-03.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

final class RegisterNextVC: UITableViewController {

    @IBOutlet weak var nameField: TextFieldRect!
    @IBOutlet weak var passwordField: TextFieldRect!
    @IBOutlet weak var signUpBtn: UIButton!
    
    lazy var alert = Alerts()
    private let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(SignInVC.textChanged(sender:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .gray
        let spinner: UIBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.rightBarButtonItem = spinner
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.isTranslucent = false
        navigationController?.navigationBar.isTranslucent  = false
        navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func register(_ sender: Any) {
        activityIndicator.startAnimating()
        let name = nameField.text!
        let password = passwordField.text!
        let email = Defaults[.email]

        AuthService.instance.signUp(name: name, email: email, password: password) { (success, error) in
            if !success! {
                self.alert.showNotif(text: (error?.localizedDescription)!, vc: self, backgroundColor: UIColor.notifBackgroundColor , textColor: UIColor.white, autoHide: true, position: .top)
                self.activityIndicator.stopAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    @objc func textChanged(sender: NSNotification) {
        if nameField.hasText && passwordField.hasText {
            signUpBtn.isEnabled = true
        } else {
            signUpBtn.isEnabled = false
        }
    }
}
