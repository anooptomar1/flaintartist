////
////  Settings.swift
////  Flaintartist
////
////  Created by Kerby Jean on 2017-06-17.
////  Copyright © 2017 Kerby Jean. All rights reserved.
////
//
//enum Setting: String {
//    // Bool settings with SettingsViewController switches
//    case debugMode
//    case scaleWithPinchGesture
//    case ambientLightEstimation
//    case dragOnInfinitePlanes
//    case showHitTestAPI
//    case use3DOFTracking
//    case use3DOFFallback
//    case useOcclusionPlanes
//    
//    // Integer state used in virtual object picker
//    case selectedObjectID
//    
//    static func registerDefaults() {
//        UserDefaults.standard.register(defaults: [
//            Setting.ambientLightEstimation.rawValue: true,
//            Setting.dragOnInfinitePlanes.rawValue: true,
//            Setting.selectedObjectID.rawValue: -1
//            ])
//    }
//}
//extension UserDefaults {
//    func bool(for setting: Setting) -> Bool {
//        return bool(forKey: setting.rawValue)
//    }
//    func set(_ bool: Bool, for setting: Setting) {
//        set(bool, forKey: setting.rawValue)
//    }
//    func integer(for setting: Setting) -> Int {
//        return integer(forKey: setting.rawValue)
//    }
//    func set(_ integer: Int, for setting: Setting) {
//        set(integer, forKey: setting.rawValue)
//    }
//}

