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
            VStack {
                Spacer()
                HStack(spacing: 25) {
                    Button("test") {
                        print("test 1")
                    }
                    .buttonStyle(.borderedProminent)
                    Button("test2") {
                        print("test 2")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.bottom, 35)
            }
        }
    }
}
