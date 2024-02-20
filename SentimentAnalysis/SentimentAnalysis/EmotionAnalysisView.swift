//
//  EmotionAnalysis.swift
//  SentimentAnalysis
//
//  Created by Fabio Freitas on 20/02/24.
//

import SwiftUI
import CoreML

struct EmotionAnalysisView: View {
    @State private var textInput = ""
    @State private var result = ""

    var body: some View {
        VStack(spacing: 25) {
            Text("Emotion Analysis")
                .font(.headline)
                .foregroundStyle(.mint)

            if !result.isEmpty {
                Text(result)
                    .foregroundStyle(resultColor(result))
            }

            HStack(spacing: 20) {
                TextField("", text: $textInput)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                if !textInput.isEmpty {
                    Button("Clear") {
                        textInput = ""
                    }
                }
            }
            Button("Analyze") {
                analyze()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }

    private func analyze() {
        guard !textInput.isEmpty else { return }
        do {
            let sentimentAnalysis = try EmotionAnalisys(configuration: MLModelConfiguration())

            let input = EmotionAnalisysInput(text: textInput.trimmingCharacters(in: .whitespacesAndNewlines))

            let output = try sentimentAnalysis.prediction(input: input)
            print(output.label)
            result = "Result: \(output.label)"
        } catch {
            print(error.localizedDescription)
        }
    }

    private func resultColor(_ input: String) -> Color {
        if input.contains("happy") {
            return .green
        } else if input.contains("anger") {
            return .red
        } else if input.contains("fear") {
            return .brown
        } else if input.contains("love") {
            return .pink
        } else if input.contains("surprise") {
            return .yellow
        } else {
            return .gray
        }
    }
}

#Preview {
    EmotionAnalysisView()
}
