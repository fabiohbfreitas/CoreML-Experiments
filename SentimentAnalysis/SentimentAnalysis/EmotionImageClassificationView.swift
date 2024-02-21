//
//  EmotionImageClassificationView.swift
//  SentimentAnalysis
//
//  Created by Fabio Freitas on 21/02/24.
//

import SwiftUI
import CoreML
import UIKit
import Vision

enum HappyImages: String, Hashable, CaseIterable {
    case Happy1
    case Happy2
    case Happy3
    case Happy4
    
    func getImage() -> ImageResource {
        switch self {
            
        case .Happy1:
                .test1
        case .Happy2:
                .test2
        case .Happy3:
                .test3
        case .Happy4:
                .test4
        }
    }
    
    func getLabel() -> String {
        switch self {
        case .Happy1:
            "Image 1"
        case .Happy2:
            "Image 2"
        case .Happy3:
            "Image 3"
        case .Happy4:
            "Image 4"
        }
    }
}


struct EmotionImageClassificationView: View {
    @State private var selectedImage: HappyImages = .Happy1
    @State private var result = ""
    
    var body: some View {
        VStack {
            ZStack {
                Image(selectedImage.getImage())
                    .resizable()
                    .scaledToFit()
                if !result.isEmpty {
                    VStack {
                        Spacer()
                        Text(result)
                            .foregroundStyle(.white)
                            .font(.title)
                            .bold()
                            .padding(.bottom)
                    }
                    .frame(maxWidth: .infinity)
                    .background {
                        Color.black.opacity(0.6)
                    }
                }
            }
            .frame(maxHeight: 390)
            
            Picker("Select Image", selection: $selectedImage) {
                ForEach(HappyImages.allCases, id: \.self) {
                    Text($0.getLabel())
                }
            }
            Button("Go") {
                classifyImage()
            }
            .buttonStyle(.bordered)
        }
    }
    
    private func classifyImage() {
        do {
            let mlModel = try EmotionsImageClassifier()
            let visionModel = try VNCoreMLModel(for: mlModel.model)

            let req = VNCoreMLRequest(model: visionModel, completionHandler: {
                request, error in
                processObservation(for: request, error: error)
            })
            req.imageCropAndScaleOption = .scaleFit
            
            #if targetEnvironment(simulator)
            req.usesCPUOnly = true
            #endif
            
            guard let image = UIImage(resource: selectedImage.getImage()).cgImage else {
                print("invalid image")
                return }
            
            let handler = VNImageRequestHandler(cgImage: image)
            
            try handler.perform([req])
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func processObservation(for req: VNRequest, error: Error?) {
        if let results = req.results as? [VNClassificationObservation] {
            if results.isEmpty {
                print("nothing...")
                    return
            }
            result = String(format: "Result: %@ %.1f%%", results[0].identifier.capitalized, results[0].confidence * 100)
        } else if let error {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    EmotionImageClassificationView()
}
