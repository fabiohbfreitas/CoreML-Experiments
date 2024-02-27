//
//  CameraViewModel.swift
//  CameraLiveCaptureTesting
//
//  Created by Fabio Freitas on 23/02/24.
//

import AVFoundation
import Photos
import SwiftUI

extension CameraView {
    @Observable
    class CameraViewModel: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
        var session = AVCaptureSession()
        var preview = AVCaptureVideoPreviewLayer()
//        var output = AVCaptureVideoDataOutput()
        var photoOutput = AVCapturePhotoOutput()
        
        var previewOutput: UIImage?
        var hasPreviewPhoto: Bool {
            previewOutput != nil
        }

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
            session.sessionPreset = .hd1920x1080
            do {
                guard let device = AVCaptureDevice.default(for: .video) else { return }
                let input = try AVCaptureDeviceInput(device: device)
                guard session.canAddInput(input) else { return }
                session.addInput(input)

//                guard session.canAddOutput(output) else { return }
//                session.addOutput(output)
//
//                output.alwaysDiscardsLateVideoFrames = true
//                output.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .background))
                
                guard session.canAddOutput(photoOutput) else { return }
                session.addOutput(photoOutput)

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
        
        func tapDiscardPhoto() {
            guard  previewOutput != nil else { return }
            Task {
                self.previewOutput = nil
            }
        }
        
        func tapTakePhoto() {
            let photoSettings = AVCapturePhotoSettings()
            guard let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first else { return }
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            Task {
                self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
            }
        }
        
        func savePhoto() {
            guard let previewOutput else { return }
            
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
                if status == .authorized {
                    do {
                        try PHPhotoLibrary.shared().performChangesAndWait {
                            PHAssetChangeRequest.creationRequestForAsset(from: previewOutput)
                            self?.previewOutput = nil
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            guard let imageData = photo.fileDataRepresentation() else { return }
            self.previewOutput = UIImage(data: imageData)
        }

        func captureOutput(_: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from _: AVCaptureConnection) {
            guard let _: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        }
        
    }
}
