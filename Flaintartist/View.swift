//
//  View.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-08-07.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

//
//  View.swift
//  Ti Goute
//
//  Created by Kerby Jean on 2017-08-05.
//  Copyright © 2017 Flaint, Inc. All rights reserved.
//

import UIKit

@IBDesignable
public extension UIView {
    @IBInspectable public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        
        set {
            layer.cornerRadius = newValue
        }
    }
    @IBInspectable public var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        
        set {
            layer.shadowRadius = newValue
        }
    }
    @IBInspectable public var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        
        set {
            layer.shadowOpacity = newValue
        }
    }
    @IBInspectable public var shadowColor: UIColor? {
        get {
            return layer.shadowColor != nil ? UIColor(cgColor: layer.shadowColor!) : nil
        }
        
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }
    @IBInspectable public var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        
        set {
            layer.shadowOffset = newValue
        }
    }
    @IBInspectable public var zPosition: CGFloat {
        get {
            return layer.zPosition
        }
        
        set {
            layer.zPosition = newValue
        }
    }
}

func viewController(forStoryboardName: String) -> UIViewController {
    return UIStoryboard(name: forStoryboardName, bundle: nil).instantiateInitialViewController()!
}

class TemplateImageView: UIImageView {
    @IBInspectable var templateImage: UIImage? {
        didSet {
            image = templateImage?.withRenderingMode(.alwaysTemplate)
        }
    }
}
