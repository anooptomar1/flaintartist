//
//  Unused.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/26/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


// ALL THE UNUSED CODE

//NEWS VC

  /*  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headerView = Bundle.main.loadNibNamed("HeaderView", owner: self, options: nil)?.first as! HeaderView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(NewsVC.seeMoreBtnTapped(_:)))
        seeMoreBtn.addGestureRecognizer(tapGesture)

        typeLbl.text = categories[section]
        if section == 0 && section == 2 {
            self.seeMoreBtn.isHidden = true
        }
        return headerView
    }
 */




// MARK: EDIT SWIPEVIEW
//
/* extension ProfileVC: SwipeViewDelegate, SwipeViewDataSource {

    func numberOfItems(in swipeView: SwipeView!) -> Int {
        return 3
    }

    func swipeView(_ swipeView: SwipeView!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        if index == 0 {
            UIView.animate(withDuration: 2, animations: {
                self.sizeView = Bundle.main.loadNibNamed("Size", owner: self, options: nil)?[0] as! SizeView
                self.sizeView.isUserInteractionEnabled = true
                self.sizeView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200)
                self.sizeView.heightSlider.value = 40
                self.sizeView.widthSlider.value = 40
                self.sizeView.heightLbl.text = "Height: \(Int(self.sizeView.widthSlider.value)) cm"
                self.sizeView.heightSlider.addTarget(self, action: #selector(ProfileVC.SliderValueChanged(_:)), for: .valueChanged)
                self.sizeView.widthSlider.addTarget(self, action: #selector(ProfileVC.SliderValueChanged(_:)), for: .valueChanged)
            })
            return self.sizeView
        }

                else if index == 1 {
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
                        self.titleTextField.delegate = self
                        self.descTextView.delegate = self
                        self.descTextView.text = "Description..."
                        self.descTextView.textColor = UIColor.lightGray
                    })
                    return DetailsView
                }
        return UIView()
    }


    func SliderValueChanged(_ sender: UISlider) {
        if sender.tag == 1 {
           self.sizeView.heightLbl.text = "Height: \(Int(sender.value)) cm"

        } else if sender.tag == 2 {
            UIView.animate(withDuration: 0.5) {
               self.sizeView.widthLbl.isHidden = false
            }
            if sender.value == 0 {

            }
            self.sizeView.widthLbl.text = "Width: \(Int(sender.value)) cm"
        }
    }
} */




 // CaptureDetails VC
 // Pan to change size


 /* MARK: Gestures
 
 
 
  let pan = UIPanGestureRecognizer(target: self, action: #selector(NextStepCaptureVC.pan(gesture:)))
    view.addGestureRecognizer(pan)

    func pan(gesture: UIPanGestureRecognizer) {
        // The amount of movement up/down since last change in slider
        let yTranslation = gesture.translation(in: gesture.view).y
        let tolerance: CGFloat = 40
        if abs(yTranslation) >= tolerance {
            let newValue = heightSlider.value - Float(yTranslation / tolerance)
            heightSlider.setValue(newValue, animated: true)

            // Reset the overall translation within the view
            gesture.setTranslation(.zero, in: gesture.view)
        }
    } */


//
//func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
//    let vc = storyboard?.instantiateViewController(withIdentifier: "WebVC") as! WebVC
//    vc.url = URL
//    present(vc, animated: true, completion: nil)
//    return false
//}
//
//




