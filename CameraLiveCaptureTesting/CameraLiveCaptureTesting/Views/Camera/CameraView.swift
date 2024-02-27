//
//  CameraView.swift
//  CameraLiveCaptureTesting
//
//  Created by Fabio Freitas on 23/02/24.
//

import AVFoundation
import SwiftUI

struct CameraView: View {
    @State private var cameraViewModel = CameraViewModel()

    var body: some View {
        ZStack {
            GeometryReader { proxy in
                CameraPreview(cameraViewModel: $cameraViewModel, frame: proxy.frame(in: .global))
                    .onAppear {
                        cameraViewModel.requestAccessAndSetup()
                    }
            }

            if let image = cameraViewModel.previewOutput {
                VStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaleEffect(0.85)
                        .clipped()
                        .cornerRadius(12)
                        .padding(.top)
                    HStack(spacing: 30) {
                        Button("Discard") {
                            cameraViewModel.previewOutput = nil
                        }
                        .foregroundStyle(.red)
                        .padding()

                        Button("Save") {
                            cameraViewModel.savePhoto()
                        }
                        .foregroundStyle(.green)
                    }
                    .padding(.bottom, 40)
                }
                .background(.ultraThinMaterial)
            }
            VStack {
                Spacer()
                HStack(spacing: 25) {
                    if cameraViewModel.previewOutput == nil {
                        Button("take photo") {
                            cameraViewModel.tapTakePhoto()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.bottom, 35)
            }
        }
    }
}
