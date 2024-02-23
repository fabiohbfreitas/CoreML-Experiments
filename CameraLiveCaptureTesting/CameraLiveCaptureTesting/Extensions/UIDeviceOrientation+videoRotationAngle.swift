//
//  UIDeviceOrientation+videoRotationAngle.swift
//  CameraLiveCaptureTesting
//
//  Created by Fabio Freitas on 23/02/24.
//

import UIKit

extension UIDeviceOrientation {
    var videoRotationAngle: CGFloat {
        switch self {
        case .landscapeLeft:
            0
        case .portrait:
            90
        case .landscapeRight:
            180
        case .portraitUpsideDown:
            270
        default:
            90
        }
    }
}
