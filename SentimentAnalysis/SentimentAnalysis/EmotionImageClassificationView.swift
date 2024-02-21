//
//  EmotionImageClassificationView.swift
//  SentimentAnalysis
//
//  Created by Fabio Freitas on 21/02/24.
//

import CoreML
import SwiftUI
import UIKit
import Vision

enum HappyImages: String, Hashable, CaseIterable {
    case Happy1
    case Happy2
    case Happy3
    case Happy4
    case Sad1
    case Sad2
    case Sad3
    case Angry1
    case Angry2
    case Angry3

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
        case .Sad1:
            .testSad1
        case .Sad2:
            .testSad2
        case .Sad3:
            .testSad3
        case .Angry1:
            .angry1
        case .Angry2:
            .angry2
        case .Angry3:
            .angry3
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
        case .Sad1:
            "Image 5"
        case .Sad2:
            "Image 6"
        case .Sad3:
            "Image 7"
        case .Angry1:
            "Image 8"
        case .Angry2:
            "Image 9"
        case .Angry3:
            "Image 10"
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
                    .frame(maxWidth: .infinity, maxHeight: 60)
                    .background {
                        Color.black.opacity(0.6)
                    }
                }
            }
            .frame(maxHeight: 390)

            Picker("Select Image", selection: $selectedImage) {
                ForEach(HappyImages.allCases, id: \.self) {
                    Text($0.getLabel()).tag($0.getLabel())
                }
            }.onChange(of: selectedImage) { _, _ in
                result = ""
            }
            Button("Go") {
                classifyImage()
                print("tap")
            }
            .buttonStyle(.bordered)
        }
    }

    private func classifyImage() {
        do {
            let mlModel = try EmotionsImageClassifier(configuration: MLModelConfiguration())
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
                return
            }

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
