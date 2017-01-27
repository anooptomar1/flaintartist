//
//  EditArtVC.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/13/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import SceneKit
import Firebase
import SDWebImage
import FirebaseStorage
import FirebaseAuth

class EditArtVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, SwipeViewDelegate, SwipeViewDataSource, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet var scnView: SCNView!
    @IBOutlet var heightLbl: UILabel!
    @IBOutlet var widthLbl: UILabel!
    @IBOutlet weak var heightSlider: UISlider!
    @IBOutlet weak var widthSlider: UISlider!
    @IBOutlet weak var swipeView: SwipeView!
    @IBOutlet weak var segmentedCtrl: UISegmentedControl!
    @IBOutlet var priceTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var wordCountLbl: UILabel!
    @IBOutlet weak var typePickerView: UIPickerView!
    @IBOutlet weak var imgContentView: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    
    var artImg: UIImage!
    var artDetails: Art!
    var measure: Array = [AnyObject]()
    var SizeView = UIView()
    var typesView = UIView()
    var DetailsView = UIView()
    
    var heightValue: CGFloat = 0
    var widthValue: CGFloat = 0
    var lenghtValue: CGFloat = 0
    var titleText: String = ""
    var descText: String = ""
    var types = ["Modern", "Abstract", "Realism"]
    var type = ""
    
    var detailsScene = DetailsScene(create: true)
    
    var doneBtn = UIBarButtonItem()
    var user: Users!
    let storage = FIRStorage.storage()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scnView = self.scnView!
        let scene = detailsScene
        scnView.scene = scene
        scnView.backgroundColor = UIColor(red: 249, green: 249, blue: 249, alpha: 1)
        scnView.autoenablesDefaultLighting = true
        scnView.isJitteringEnabled = true
        
        if let img = artImg as UIImage? {
            self.detailsScene.setup(artImage: img)
        }
        
        swipeView.delegate = self
        swipeView.dataSource = self
        swipeView.alignment = .edge
        //swipeView.isPagingEnabled = true
        swipeView.itemsPerPage = 1
        swipeView.bounces = false
        swipeView.isScrollEnabled = false
        
        
        
        doneBtn = UIBarButtonItem(title: "Save", style: .done, target: self, action:  #selector(CaptureDetailsVC.doneBtnTapped(_:)))
        doneBtn.tintColor = UIColor.flatSkyBlue()
        self.navigationItem.rightBarButtonItem = doneBtn
        
        segmentedCtrl.selectedSegmentIndex = 0
        
        //NotificationCenter.default.addObserver(self, selector: #selector(CaptureDetailsVC.valueChanged(sender:)), name: nil, object: nil)
        doneBtn.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(CaptureDetailsVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CaptureDetailsVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        //        let pan = UIPanGestureRecognizer(target: self, action: #selector(NextStepCaptureVC.pan(gesture:)))
        //        view.addGestureRecognizer(pan)
        
        segmentedCtrl.tintColor = UIColor.flatBlack()
        
        heightSlider.value = Float(artImg.size.height / 100)
        widthSlider.value = Float(artImg.size.width)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.tintColor = UIColor.flatBlack()
        
    }

    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func doneBtnTapped(_ sender: Any) {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .gray
        let spinner: UIBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        navigationItem.rightBarButtonItem = spinner
        activityIndicator.startAnimating()
        
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        let price:Int? = Int(priceTextField.text!)
        let title = titleTextField.text!
        let desc = descTextView.text!
        let height = heightSlider.value
        let width = widthSlider.value

        let artDetails = self.artDetails as Art
        let artRef = DataService.instance.REF_ARTS.child(artDetails.artID)
        let newArtDetails = ["description": desc, "title": title, "height": height, "width": width, "price": price!, "userUID": uid!] as [String : Any]
        artRef.updateChildValues(newArtDetails) { (error, reference) in
            self.dismiss(animated: true, completion: nil)
        }
    
    }

    
    
    @IBAction func SliderValueChanged(_ sender: UISlider) {
    
        if sender.tag == 1 {
            heightLbl.text = "Height: \(Int(sender.value)) cm"
        } else if sender.tag == 2 {
            UIView.animate(withDuration: 0.5) {
            self.widthLbl.isHidden = false
        }
           if sender.value == 0 {
                
        }
            widthLbl.text = "Width: \(Int(sender.value)) cm"
        }
        
        if sender.isTouchInside == false {
            Timer.scheduledTimer(timeInterval: 6.0, target: self, selector: #selector(CaptureDetailsVC.stopAnimation), userInfo: nil, repeats: false)
        }
    }
    
    func stopAnimation() {
        let stopAnimation = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.6)
        stopAnimation.timingMode = SCNActionTimingMode.easeInEaseOut;
        self.detailsScene.boxnode.runAction(stopAnimation)
    }
    
    @IBAction func segmentTapped(_ sender: AnyObject) {
        if sender.selectedSegmentIndex == 0 {
            swipeView.scrollToItem(at: 0, duration: 0.5)
        } else if  segmentedCtrl.selectedSegmentIndex == 1 {
            swipeView.scrollToItem(at: 1, duration: 0.5)
        } else if segmentedCtrl.selectedSegmentIndex == 2 {
            swipeView.scrollToItem(at: 2, duration: 0.5)
        }
    }
    
    
    func postToFirebase(imgUrl: String) {
            let tabBarVC = storyboard?.instantiateViewController(withIdentifier: "TabBarVC")
            self.present(tabBarVC!, animated: true, completion: nil)
        }
    
    
    // MARK: Functions
    
    func valueChanged(sender: NSNotification) {
        if priceTextField != nil || titleTextField != nil || descTextView != nil {
            if let title = titleTextField.text{
                if heightSlider.value == 0 || widthSlider.value == 0 || title.isEmpty || descTextView.text == "Description..."{
                    self.doneBtn.isEnabled = false
                } else if heightSlider.value > 0 && widthSlider.value > 0 && !title.isEmpty || descTextView.text != "Description..." || descTextView.text != ""{
                    self.doneBtn.isEnabled = true
                    descText = descTextView.text
                }
            }
        }
    }
    
    
    func numberOfItems(in swipeView: SwipeView!) -> Int {
        return 3
    }
    
    func swipeView(_ swipeView: SwipeView!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        if index == 0 {
            UIView.animate(withDuration: 2, animations: {
                self.SizeView = Bundle.main.loadNibNamed("Size", owner: self, options: nil)?[0] as! UIView
                self.segmentedCtrl.selectedSegmentIndex = 0
                self.SizeView.isUserInteractionEnabled = true
                self.SizeView.frame = CGRect(x: 0, y: 0, width: self.swipeView.frame.width, height: self.swipeView.frame.height)
                self.heightSlider.value = Float(self.artDetails.artHeight)
                self.widthSlider.value = Float(self.artDetails.artWidth)
            })
            return SizeView
        } else if index == 1 {
            UIView.animate(withDuration: 2, animations: {
                self.typesView = Bundle.main.loadNibNamed("Types", owner: self, options: nil)?[0] as! UIView
                self.segmentedCtrl.selectedSegmentIndex = 1
                self.typesView.isUserInteractionEnabled = true
                self.typesView.frame = CGRect(x: 0, y: 0, width: self.swipeView.frame.width, height: self.swipeView.frame.height)
                self.typePickerView.delegate = self
                self.typePickerView.dataSource = self
                let row = self.typePickerView.selectedRow(inComponent: 0)
                self.pickerView(self.typePickerView, didSelectRow: row, inComponent:0)
            })
            return typesView
        } else if index == 2 {
            UIView.animate(withDuration: 2, animations: {
                self.DetailsView = Bundle.main.loadNibNamed("Details", owner: self, options: nil)?[0] as! UIView
                self.segmentedCtrl.selectedSegmentIndex = 2
                self.DetailsView.isUserInteractionEnabled = true
                self.DetailsView.frame = CGRect(x: 0, y: 0, width: self.swipeView.frame.width, height: self.swipeView.frame.height)
                self.priceTextField.delegate = self
                self.priceTextField.text = "\(self.artDetails.price)"
                self.titleTextField.delegate = self
                self.titleTextField.text = "\(self.artDetails.title)"
                self.descTextView.delegate = self
                self.descTextView.text = self.artDetails.description
                self.descTextView.textColor = UIColor.lightGray
            })
            return DetailsView
        }
        return view
    }
    
    
    
    // MARK: PickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return types[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return types.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let type = self.types[row]
        self.type = type
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    //MARK: TextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        let len = textView.text.characters.count
        wordCountLbl.text = "\(100 - len)"
        if len != 0 {
            wordCountLbl.isHidden = false
        } else {
            wordCountLbl.isHidden = true
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if(text == "\n") {
            textView.resignFirstResponder()
            done()
            return false
        }
        
        
        if text.characters.count == 0 {
            if descTextView.text.characters.count != 0 {
                return true
            }
        }
        else if descTextView.text.characters.count > 99 {
            return false
        }
        
        return true
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.flatBlack()
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description..."
            textView.textColor = UIColor.lightGray
        }
    }
    
    
    
    // MARK: TextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
            textField.resignFirstResponder()
            descTextView.becomeFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        titleText = textField.text!
        return true
    }
    
    // MARK: Keyboard
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    
    // MARK: Gestures
    
    //    func pan(gesture: UIPanGestureRecognizer) {
    //        // The amount of movement up/down since last change in slider
    //        let yTranslation = gesture.translation(in: gesture.view).y
    //        let tolerance: CGFloat = 40
    //        if abs(yTranslation) >= tolerance {
    //            let newValue = heightSlider.value - Float(yTranslation / tolerance)
    //            heightSlider.setValue(newValue, animated: true)
    //
    //            // Reset the overall translation within the view
    //            gesture.setTranslation(.zero, in: gesture.view)
    //        }
    //    }
    
    func done() {
        if let imgData =  UIImageJPEGRepresentation(artImg, 0.0) {
            let imgUID = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            let userUID = (FIRAuth.auth()?.currentUser?.uid)!
            DataService.instance.REF_STORAGE.reference().child("Arts").child(userUID).child(imgUID).put(imgData, metadata: metadata){(metaData,error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                } else {
                    let downloadURL = metaData?.downloadURL()!.absoluteString
                    if let url = downloadURL {
                        self.postToFirebase(imgUrl: url)
                    }
                }
            }
        }
    }
}
