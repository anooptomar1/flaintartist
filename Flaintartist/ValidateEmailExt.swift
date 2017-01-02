//
//  ValidateEmailExt.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.

import Foundation
import UIKit


extension String {
    var isEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
            
            return regex.firstMatch(in: self, options:  NSRegularExpression.MatchingOptions(rawValue: 0), range:  NSMakeRange(0, self.characters.count)) != nil
        } catch {
            return false
        }
    }
}
