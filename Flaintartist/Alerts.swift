//
//  Alerts.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-27.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import GSMessages

final class Alerts {
    
    lazy var artVC = ArtViewModelController()
    lazy var section = ToolsSectionController()
    lazy var vc = EditVC()

    
    func artAlert(target: ProfileVC, art: Art) {
        let alert = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        
        let edit = UIAlertAction(title: "Edit", style: .default) { (action) in
            self.vc.title = "Edit"
            let nav = UINavigationController(rootViewController: self.vc)
            self.vc.art.append(art)
            target.present(nav, animated: true, completion: nil)
        }

        
        let share = UIAlertAction(title: "Share", style: .default) { (action) in
        }
        
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.deteteArt(art: art, target: target)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(edit)
        alert.addAction(share)
        alert.addAction(delete)
        alert.addAction(cancel)
        target.present(alert, animated: true, completion: nil)
    }
    
    @objc func back() {
        vc.dismiss(animated: true, completion: nil)
    }
    
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
    
    private func deteteArt(art: Art, target: ProfileVC)  {
        let alert = UIAlertController(title: "", message: "Are you sure you want to remove it from your Gallery? After removing, the action is irreversible.", preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Remove from My Gallery", style: .destructive) { (UIAlertAction) in
            //Function to Delete Art
            self.artVC.deleteArt(art, completionBlock: { (success, error) in
                if !success {
                    print("ERROR DELETING ART: \(String(describing: error?.localizedDescription))")
                } else {
                    self.section.adapter.performUpdates(animated: true)
                }
            })
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        target.present(alert, animated: true, completion: nil)
    }

    
    func showNotif(text: String, vc: UIViewController, backgroundColor: UIColor, textColor: UIColor, autoHide: Bool, position: GSMessagePosition) {
        GSMessage.successBackgroundColor = backgroundColor
        vc.showMessage(text, type: .success, options: [
            .animation(.slide),
            .animationDuration(0.6),
            .autoHide(autoHide),
            .autoHideDelay(3.0),
            .height(30.0),
            .hideOnTap(true),
            .position(position),
            .textAlignment(.center),
            .textColor(textColor),
            .textNumberOfLines(1),
        ])
    }
}


