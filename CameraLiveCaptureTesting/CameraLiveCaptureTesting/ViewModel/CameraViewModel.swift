//
//  CameraViewModel.swift
//  CameraLiveCaptureTesting
//
//  Created by Fabio Freitas on 23/02/24.
//

import AVFoundation
import SwiftUI

extension CameraView {
    @Observable
    class CameraViewModel: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var session = AVCaptureSession()
        var preview = AVCaptureVideoPreviewLayer()
        var output = AVCaptureVideoDataOutput()

        func requestAccessAndSetup() {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { _ in
                    self.setup()
                }
            case .authorized:
                setup()
            default:
                print("other camera status")
            }
        }

        private func setup() {
            session.beginConfiguration()
            session.sessionPreset = .hd1280x720
            do {
                guard let device = AVCaptureDevice.default(for: .video) else { return }
                let input = try AVCaptureDeviceInput(device: device)
                guard session.canAddInput(input) else { return }
                session.addInput(input)

                guard session.canAddOutput(output) else { return }
                session.addOutput(output)

                output.alwaysDiscardsLateVideoFrames = true
                output.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .background))

                session.commitConfiguration()

                Task(priority: .background) {
                    self.session.startRunning()
                    await MainActor.run {
                        self.preview.connection?.videoRotationAngle = UIDevice.current.orientation.videoRotationAngle
                    }
                }

            } catch {
                print(error.localizedDescription)
            }
        }

        func captureOutput(_: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from _: AVCaptureConnection) {
            guard let _pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            print(Date().timeIntervalSince1970)
        }
    }
}
