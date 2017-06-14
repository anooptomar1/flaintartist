//
//  Alerts.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import GSMessages

class Alerts {
    
    func showAlert(_ title: String, message: String, target: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(action)
        target.present(alert, animated: true, completion: nil)
    }
    
    func createAccountAlert(_ title: String, message: String, view: UIView, target: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
            
        }
        alert.addAction(action)
        target.present(alert, animated: true, completion: nil)
        
    }
    
    
    func deteteArt(_ target: ProfileVC)  {
        let alert = UIAlertController(title: "", message: "Are you sure you want to remove it from your Gallery? After removing, the action is irreversible.", preferredStyle: .actionSheet)
        
        let action = UIAlertAction(title: "Remove from My Gallery", style: .destructive) { (UIAlertAction) in
            //Function to Delete Art
            //target.removeArt()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(action)
        alert.addAction(cancel)
        target.present(alert, animated: true, completion: nil)
        
    }
    
 
    
    
    func showNotif(text: String, vc: UIViewController, backgroundColor: UIColor, textColor: UIColor, autoHide: Bool) {
        GSMessage.successBackgroundColor = backgroundColor
        vc.showMessage(text, type: .success, options: [
            .animation(.slide),
            .animationDuration(0.6),
            .autoHide(autoHide),
            .autoHideDelay(3.0),
            .height(30.0),
            .hideOnTap(true),
            .position(.top),
            .textAlignment(.center),
            .textColor(textColor),
            .textNumberOfLines(1),
            .textPadding(30.0)
            ])
    }
   
}

