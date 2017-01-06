//
//  SettingsVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftyUserDefaults

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var options: [String] = []
    var userInfo : [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Settings"
        tableView.delegate = self
        tableView.dataSource = self
        options = ["Edit Account", "Invite a Friend", "Privacy Policy", "Log Out"]
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
        cell.optionLbl.text = options[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            performSegue(withIdentifier: "EditAccountVC", sender: userInfo)
        }
        
        if indexPath.row == 1 {
            performSegue(withIdentifier: "InviteFriendsVC", sender: nil)
        }
        
        if indexPath.row == 2 {
            performSegue(withIdentifier: "PrivacyVC", sender: nil)
        }
        
        if indexPath.row == 3 {
            logoutAlert()
        }
        
    }
    
    
    func reportProblemAlert(){
        let problem = UIAlertController(title: "Report a Problem", message: "", preferredStyle: .alert)
        let SomethingNotWorking = UIAlertAction(title: "Something Is Not Working", style: .default) { (UIAlertAction) in
            let reportTitleSomething = ["Something Is Not Working", "Brieftly explain what happended."]
            self.performSegue(withIdentifier: "FeedbackVC", sender: reportTitleSomething)
        }
        let generalFeedback = UIAlertAction(title: "General Feedback", style: .default) { (UIAlertAction) in
            let reportTitleGeneral = ["General Feedback", "Brieftly explain what you love, or what could improve."]
            self.performSegue(withIdentifier: "FeedbackVC", sender: reportTitleGeneral)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            return
        }
        problem.addAction(SomethingNotWorking)
        problem.addAction(generalFeedback)
        problem.addAction(cancel)
        present(problem, animated: true, completion: nil)
    }
    
    
    func logoutAlert() {
        let vc = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .alert)
        let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let yes = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
            
            Defaults.remove(.key_uid)
            Defaults.remove(.accountType)
            
            let firebaseAuth = FIRAuth.auth()
            do {
                try firebaseAuth!.signOut()
                let controller = self.storyboard!.instantiateViewController(withIdentifier: "LogInNav")
                self.present(controller, animated: true, completion: nil)
            } catch let signOutError as NSError {
                print("SIGNOUT ERROR:\(signOutError)")
            }
        }
        vc.addAction(yes)
        vc.addAction(no)
        present(vc, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditAccountVC" {
            let editAccountVC = segue.destination as! EditAccountVC
            let userInfo = sender as! [AnyObject]
            editAccountVC.userInfo = userInfo
        } else if segue.identifier == "FeedbackVC" {
            let feedbackVC = segue.destination as! FeedbackVC
            let report = sender as! [String]
            feedbackVC.report = report
        } else if segue.identifier == "PrivacyVC" {
            let feedbackVC = segue.destination as! PrivacyVC
            feedbackVC.hidesBottomBarWhenPushed = true
        }
    }
}
