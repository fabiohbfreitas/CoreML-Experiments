//
//  CameraPreview.swift
//  CameraLiveCaptureTesting
//
//  Created by Fabio Freitas on 23/02/24.
//

import AVFoundation
import SwiftUI

struct CameraPreview: UIViewRepresentable {
    @Binding var cameraViewModel: CameraView.CameraViewModel
    let frame: CGRect

    func makeUIView(context _: Context) -> UIView {
        let view = UIViewType(frame: frame)
        cameraViewModel.preview = AVCaptureVideoPreviewLayer(session: cameraViewModel.session)
        cameraViewModel.preview.frame = frame
        cameraViewModel.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(cameraViewModel.preview)
        return view
    }

    func updateUIView(_: UIViewType, context _: Context) {
        cameraViewModel.preview.frame = frame
        cameraViewModel.preview.connection?.videoRotationAngle = UIDevice.current.orientation.videoRotationAngle
    }
}
