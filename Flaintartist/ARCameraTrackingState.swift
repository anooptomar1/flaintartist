//
//  ARCameraTrackingState.swift
//  Flaintartist
//
//  Created by Kerby Jean on 2017-06-20.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import ARKit
import Foundation

extension ARCamera.TrackingState {
    var presentationString: String {
        switch self {
        case .notAvailable:
            return "TRACKING UNAVAILABLE"
        case .normal:
            return "TRACKING NORMAL"
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                return "TRACKING LIMITED\nToo much camera movement"
            case .insufficientFeatures:
                return "TRACKING LIMITED\nNot enough surface detail"
            }
        }
    }
}

