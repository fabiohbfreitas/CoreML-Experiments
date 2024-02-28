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

enum ImageSample: String, Hashable, CaseIterable {
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
    case Angry4
    case Angry5
    case Angry6
    case Angry7
    case Fear1
    case Fear2
    case Fear3

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
        case .Angry4:
            .angry4
        case .Angry5:
            .angry5
        case .Angry6:
            .angry6
        case .Angry7:
            .angry7
        case .Fear1:
            .fear1
        case .Fear2:
            .fear2
        case .Fear3:
            .fear3
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
        case .Angry4:
            "Image 11"
        case .Angry5:
            "Image 12"
        case .Angry6:
            "Image 13"
        case .Angry7:
            "Image 14"
        case .Fear1:
            "Image 16"
        case .Fear2:
            "Image 17"
        case .Fear3:
            "Image 18"
        }
    }

    func randomExcludingCurrent() -> ImageSample {
        let cases = ImageSample.allCases.filter { $0.rawValue != self.rawValue }
        let index = Int.random(in: 0 ..< cases.count)
        return cases[index]
    }
}

struct EmotionImageClassificationView: View {
    @State private var selectedImage: ImageSample = .Happy1
    @State private var result = ""

    var body: some View {
        VStack {
            Picker("Select Image", selection: $selectedImage) {
                ForEach(ImageSample.allCases, id: \.self) {
                    Text($0.getLabel()).tag($0.getLabel())
                }
            }.onChange(of: selectedImage) { old, new in
                if old.rawValue != new.rawValue {
                    result = ""
                }
            }

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
            VStack(spacing: 20) {
                Button("Random Image") {
                    selectedImage = selectedImage.randomExcludingCurrent()
                }
                Button("Classify Image") {
//                    classifyImage()
                    do {
                        let analysis = try ImageAnalysis(image: UIImage(resource: selectedImage.getImage()))
                        try analysis.analyseImage { modelResult in
                            result = modelResult.capitalized
                        }
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
    }

    private func classifyImage() {
        do {
//            let mlModel = try EmotionsImageClassifier(configuration: MLModelConfiguration())
            let mlModel = try EmotionsImageClassifierAugmented(configuration: MLModelConfiguration())
            let visionModel = try VNCoreMLModel(for: mlModel.model)

            let req = VNCoreMLRequest(model: visionModel, completionHandler: {
                request, error in
                processObservation(for: request, error: error)
            })
//            req.imageCropAndScaleOption = .scaleFit // This gives flaky results

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

enum ImageAnalysisError: Error {
    case InvalidImage
    case FailedToCreateModel
    case FailedRequest
    case FailureProcessingImage
    case EmptyResult
}

class ImageAnalysis {
    public let image: CGImage

    private let visionModel: VNCoreMLModel
    private let handler: VNImageRequestHandler

    init(image: CGImage?) throws {
        guard let image else { throw ImageAnalysisError.InvalidImage }
        self.image = image
        visionModel = try ImageAnalysis.prepareModel()
        handler = VNImageRequestHandler(cgImage: image)
    }

    init(image: UIImage) throws {
        guard let image = image.cgImage else { throw ImageAnalysisError.InvalidImage }
        self.image = image
        visionModel = try ImageAnalysis.prepareModel()
        handler = VNImageRequestHandler(cgImage: image)
    }

    private static func prepareModel() throws -> VNCoreMLModel {
        do {
            let coreml = try EmotionsImageClassifierAugmented(configuration: MLModelConfiguration())
            return try VNCoreMLModel(for: coreml.model)
        } catch {
            throw ImageAnalysisError.FailedToCreateModel
        }
    }

    private func processResult(for req: VNRequest, error: Error?) throws -> String {
        if let error {
            print(error.localizedDescription)
            throw ImageAnalysisError.FailureProcessingImage
        }
        guard let results = req.results as? [VNClassificationObservation] else { throw ImageAnalysisError.EmptyResult }
        guard let result = results.first else { throw ImageAnalysisError.EmptyResult }
        return result.identifier
    }

    public func analyseImage(_ resultCallback: @escaping (String) -> Void) throws {
        var request = VNCoreMLRequest(model: visionModel) { [weak self] visionRequest, err in
            guard let self = self else { return }
            do {
                let analysisResult = try processResult(for: visionRequest, error: err)
                resultCallback(analysisResult)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        #if targetEnvironment(simulator)
        request.usesCPUOnly = true
        #endif

        do {
            try handler.perform([request])
        } catch {
            throw ImageAnalysisError.FailureProcessingImage
        }
    }
}
