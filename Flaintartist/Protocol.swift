//
//  Protocol.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/14/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


protocol presentVCProtocol : NSObjectProtocol {
    func performSeg(_ identifier: String, sender: Any) -> Void
}


protocol pushVCProtocol : NSObjectProtocol {
    func push(_ vc: UIViewController) -> Void
}
