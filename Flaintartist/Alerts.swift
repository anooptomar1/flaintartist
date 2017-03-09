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
            // Function to Delete Art
            //target.removeArt()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(action)
        alert.addAction(cancel)
        target.present(alert, animated: true, completion: nil)
        
    }
    
    
    func showNotif(vc: UIViewController, backgroundColor: UIColor) {
        GSMessage.successBackgroundColor = backgroundColor
        vc.showMessage("Successfully added to favorites.", type: .success, options: [
            .animation(.slide),
            .animationDuration(0.3),
            .autoHide(true),
            .autoHideDelay(3.0),
            .height(44.0),
            .hideOnTap(true),
            .position(.top),
            .textAlignment(.center),
            .textColor(UIColor.flatSkyBlue()),
            .textNumberOfLines(1),
            .textPadding(30.0)
            ])
    }
    
    
    // Change picture alert
    func changeProfilePicture(_ target: UIViewController) {
        let camera = Camera(delegate_: target as! UIImagePickerControllerDelegate & UINavigationControllerDelegate)
        let changeProfilePictureSheet = UIAlertController(title: "Change profile picture", message: "", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Take photo", style: .default) { (UIAlertAction) in
            camera.PresentPhotoCamera(target, canEdit: true)
        }
        let libraryAction = UIAlertAction(title: "Choose from Library", style: .default) { (UIAlertAction) in
            camera.PresentPhotoLibrary(target, canEdit: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        changeProfilePictureSheet.addAction(cameraAction)
        changeProfilePictureSheet.addAction(libraryAction)
        changeProfilePictureSheet.addAction(cancelAction)
        target.present(changeProfilePictureSheet, animated: true, completion: nil)
    }
    
    
    
    
    func changeBackgroundPicture(_ target: UIViewController) {
        let camera = Camera(delegate_: target as! UIImagePickerControllerDelegate & UINavigationControllerDelegate)
        let changeBackgroundPictureSheet = UIAlertController(title: "Change background picture", message: "", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Take photo", style: .default) { (UIAlertAction) in
            camera.PresentPhotoCamera(target, canEdit: true)
        }
        let libraryAction = UIAlertAction(title: "Choose from Library", style: .default) { (UIAlertAction) in
            camera.PresentPhotoLibrary(target, canEdit: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        changeBackgroundPictureSheet.addAction(cameraAction)
        changeBackgroundPictureSheet.addAction(libraryAction)
        changeBackgroundPictureSheet.addAction(cancelAction)
        target.present(changeBackgroundPictureSheet, animated: true, completion: nil)
    }
}

