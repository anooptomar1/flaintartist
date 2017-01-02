//
//  RoundedBtn.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


import Foundation
import UIKit

class RoundedBtn: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 5
    }
}


extension UIButton {
    func BtnTapped() {
        UIView.animate(withDuration: 0.4 , animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { finish in
            UIView.animate(withDuration: 0.4){
                self.transform = CGAffineTransform.identity
            }
        })
    }
}
