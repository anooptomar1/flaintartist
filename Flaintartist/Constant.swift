//
//  Constant.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//


import SwiftyUserDefaults

//Id's
let Id_Nav = "NavVC"
let Id_LogIn = "LogInVC"


// Segue
let Seg_Enter = "Enter"
let Seg_ArtroomVC = "ArtRoomVC"
let Seg_GalleryVC = "GalleryVC"
let Seg_WallViewVC = "WallviewVC"
let Seg_ReportVC = "ReportVC"

// UserDefault

extension DefaultsKeys {
    static let key_uid = DefaultsKey<String?>("uid")
    static let email = DefaultsKey<String>("email")
    static let accountType = DefaultsKey<String>("type")
}

//LogIn Errors Codes
let LogErr_WrongPwd    = 17009
let LogErr_WrongEmail  = 17011
let LogErr_WrongDetails  = 17999
