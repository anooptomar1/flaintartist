//
//  Constant.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-09-27.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import MapKit
import SwiftyUserDefaults

let queue = DispatchQueue(label: "com.flaint.queue")

extension DefaultsKeys {
    static let key_uid = DefaultsKey<String?>("uid")
    static let email = DefaultsKey<String>("email")
    static let name = DefaultsKey<String>("name")
}

extension UIColor {
    static let separatorColor = UIColor(red: 200/255.0, green: 199/255.0, blue: 204/255.0, alpha: 1).cgColor
    static let lightGrayColor = UIColor(white: 0.95, alpha: 1)
    
}
