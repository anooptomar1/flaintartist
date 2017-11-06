//
//  DetailsVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-27.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import YYText
import TOCropViewController


final class DetailsVC: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var textCell: UITableViewCell!
    let textView = YYTextView()


    lazy var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addArt)))
        configure()
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        
        let title = titleField.text!
        let description = textView.text!
        let data = UIImageJPEGRepresentation(imageView.image!, 0.1)
        DataService.instance.createNewArt(title: title, description: description, data: data!) { (success, error) in
            if !success {
                print("Error")
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func addArtTapped(_ sender: Any) {
        addArt()        
    }
    
    @objc func addArt() {
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
//    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
//    }
//
        
//    func crop() {
//
//        var targetSize: CGSize {
//            let scale = UIScreen.main.scale
//            return CGSize(width: 0, height:0 )
//            return CGSize(width: imageView.image!.size.width * scale,  height: imageView.image!.size.height * scale)
//        }
//
//            guard let image = imageView.image else { return }
//
//            let cropController:TOCropViewController = TOCropViewController(image: image)
//            cropController.delegate = self
//            self.present(cropController, animated: true, completion: nil)
//    }
//
//
//    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
//        cropViewController.dismiss(animated: true, completion: nil)
//    }
//
//    func cropViewController(_ cropViewController: TOCropViewController, didCropToRect cropRect: CGRect, angle: Int) {
//        cropViewController.dismiss(animated: true, completion: nil)
//    }
    
}


extension DetailsVC:  YYTextViewDelegate, YYTextKeyboardObserver {
    
    func configure() {
        textView.delegate = self
        textView.frame = textCell.bounds
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = UIColor.darkText
        textView.dataDetectorTypes = .all
        textView.placeholderText = "Description"
        textView.keyboardDismissMode = .interactive
        textView.contentInset = UIEdgeInsets(top: 10, left: 5, bottom: 0, right: 0)
        textView.scrollIndicatorInsets = textView.contentInset
        textCell.addSubview(textView)
    }
}
