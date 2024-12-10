[![iOS Build](https://github.com/fabiohbfreitas/CoreML-Experiments/actions/workflows/Build.yaml/badge.svg?branch=main)](https://github.com/fabiohbfreitas/CoreML-Experiments/actions/workflows/Build.yaml)

## What is Machine Learning?
Machine learning (ML) is a branch of artificial intelligence (AI) where computer systems learn patterns from data to make predictions or decisions without being explicitly programmed. Instead of following fixed rules, ML models generalize from training data to handle new, unseen inputs.

## What are Machine Learning Tasks?
Machine learning tasks are categories of problems that ML models aim to solve. The main tasks include:  
- **Classification**: Predicting discrete categories (e.g., spam or not spam).  
- **Regression**: Predicting continuous values (e.g., stock prices).  
- **Clustering**: Grouping data into similar clusters without labeled data.  
- **Anomaly Detection**: Identifying outliers or unusual data points.  

## What is Classification?
Classification is a supervised learning task where the goal is to assign inputs to one of several predefined categories. For example, an image recognition model might classify an image as a "cat" or "dog." Classification models are trained on labeled data and aim to predict the correct class for new, unseen inputs.

## What is Text Classification?
Text classification is the process of categorizing text into predefined labels. It involves analyzing text data (like emails, reviews, or comments) and predicting its category. Common applications include spam detection, sentiment analysis, and topic classification. Models for text classification are trained on labeled text data and learn to recognize patterns in the text, such as specific words, phrases, or context.

## What is Image Classification?
Image classification involves categorizing images into specific classes. The model processes pixel data from images and predicts a label (e.g., "cat," "dog," or "car"). This task is widely used in object detection, facial recognition, and medical imaging. Image classification models are trained on labeled image datasets and use features like shapes, textures, and colors to identify patterns for classification.

## What is CreateML?
CreateML is a macOS app and framework that allows developers to create, train, and evaluate machine learning models using a simple, user-friendly interface. It requires minimal coding and provides visual tools to build models quickly. CreateML is designed to work seamlessly with Xcode and integrates easily into iOS apps through CoreML.

### Supported Tasks in CreateML
CreateML supports a variety of machine learning tasks, including:  
- **Image Classification**: Classify images into categories (e.g., cats vs. dogs).  
- **Object Detection**: Identify and locate objects within an image.  
- **Text Classification**: Categorize text into predefined labels (e.g., sentiment analysis).  
- **Sound Classification**: Classify audio clips (e.g., recognizing animal sounds).  
- **Activity Classification**: Classify movement data (e.g., identifying walking, running, or cycling).  
- **Tabular Data Models**: Work with structured datasets for regression or classification tasks.  

## What is CoreML?
CoreML is a machine learning framework for Apple platforms (iOS, macOS, watchOS, and tvOS) that enables developers to integrate and run trained ML models directly on devices. It allows for fast, on-device inference, enhancing performance, privacy, and offline capabilities. CoreML supports models created with CreateML as well as models from other ML libraries like TensorFlow, PyTorch, and scikit-learn. It optimizes models for Apple hardware to ensure efficient execution, even on devices with limited resources.


## Differences Between CreateML and CoreML
- **CreateML**: A macOS app and framework used to create, train, and evaluate machine learning models with a simple, no-code or low-code approach. It's user-friendly, supports visual tools, and is ideal for developers new to ML.  
- **CoreML**: A framework for integrating trained ML models into iOS, iPadOS, macOS, watchOS, and tvOS apps. CoreML runs models on-device, offering fast, efficient inference with low latency and privacy protection. It consumes models trained with CreateML, TensorFlow, PyTorch, and other ML tools.  

## How to Integrate and Use CoreML in an iOS App Using SwiftUI

To use a CoreML model in a SwiftUI app, you'll need to load the model, make predictions, and update the UI accordingly. Below is a step-by-step guide with best practices.

### 1. **Add the CoreML Model to the Project**
1. Drag and drop the `EmotionsImageClassifier.mlmodel` file into your Xcode project.  
2. Xcode will automatically generate a Swift class for the model (e.g., `EmotionsImageClassifier`).  

---

### 2. **Create a ViewModel for ML Predictions**
It’s best to keep ML logic separate from the UI. We’ll create a `ClassifierViewModel` to handle model predictions.

```swift
import SwiftUI
import CoreML
import Vision

enum ClassifierError: LocalizedError {
    case modelLoadingFailed
    case imageConversionFailed
    case classificationFailed(Error)
    case imageRequestFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .modelLoadingFailed:
            return "Failed to load the machine learning model."
        case .imageConversionFailed:
            return "Unable to convert UIImage to CIImage."
        case .classificationFailed(let error):
            return "Classification error: \(error.localizedDescription)"
        case .imageRequestFailed(let error):
            return "Failed to perform image request: \(error.localizedDescription)"
        }
    }
}

@Observable
class ClassifierViewModel {
    var predictedEmotion: String = "Unknown"  // Automatically observed state

    private var model: VNCoreMLModel?

    init() {
        // Load the CoreML model into a Vision model for better flexibility
        if let mlModel = try? EmotionsImageClassifier(configuration: MLModelConfiguration()).model {
            self.model = try? VNCoreMLModel(for: mlModel)
        } else {
            print(ClassifierError.modelLoadingFailed.localizedDescription)
        }
    }

    /// Classifies an image and updates the `predictedEmotion`
    func classifyImage(_ image: UIImage) {
        guard let model = model, let ciImage = CIImage(image: image) else {
            print(ClassifierError.imageConversionFailed.localizedDescription)
            return
        }

        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            if let results = request.results as? [VNClassificationObservation], let topResult = results.first {
                self?.predictedEmotion = topResult.identifier
            } else if let error = error {
                print(ClassifierError.classificationFailed(error).localizedDescription)
            }
        }

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print(ClassifierError.imageRequestFailed(error).localizedDescription)
        }
    }
}

```

## Text Classification ViewModel Example (Using `SentimentAnalysis.mlmodel`)

Here’s an example of how to create a **ViewModel** for text classification using a CoreML model named `SentimentAnalysis.mlmodel`. This ViewModel will load the model, make predictions on text inputs, and update the prediction result.

---

### **1. ViewModel for Text Classification**

```swift
import SwiftUI
import CoreML
import NaturalLanguage

enum SentimentError: LocalizedError {
    case modelLoadingFailed
    case textClassificationFailed
    
    var errorDescription: String? {
        switch self {
        case .modelLoadingFailed:
            return "Failed to load the sentiment analysis model."
        case .textClassificationFailed:
            return "Failed to classify the provided text."
        }
    }
}

@Observable
class SentimentViewModel {
    var predictedSentiment: String = "Unknown"  // Automatically observed state
    
    private var model: NLModel?

    init() {
        loadModel()
    }
    
    /// Loads the SentimentAnalysis model
    private func loadModel() {
        do {
            let mlModel = try SentimentAnalysis(configuration: MLModelConfiguration()).model
            self.model = try NLModel(mlModel: mlModel)
        } catch {
            print(SentimentError.modelLoadingFailed.localizedDescription)
        }
    }

    /// Predicts the sentiment for the given text
    func classifyText(_ text: String) {
        guard let model = model else {
            print(SentimentError.modelLoadingFailed.localizedDescription)
            return
        }
        
        // Use NLModel to classify the input text
        if let sentiment = model.predictedLabel(for: text) {
            DispatchQueue.main.async {
                self.predictedSentiment = sentiment
            }
        } else {
            print(SentimentError.textClassificationFailed.localizedDescription)
        }
    }
}

```
