//
//  SentimentAnalysis2.swift
//  SentimentAnalysis
//
//  Created by Fabio Freitas on 19/02/24.
//

import CoreML
import SwiftUI

struct SentimentAnalysis2: View {
    @State private var textInput = ""
    @State private var result = ""

    var body: some View {
        VStack(spacing: 25) {
            Text("Second Model")
                .font(.headline)
                .foregroundStyle(.teal)

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
            let sentimentAnalysis = try SentimentAnalisys2(configuration: MLModelConfiguration())

            let input = SentimentAnalisys2Input(text: textInput.trimmingCharacters(in: .whitespacesAndNewlines))

            let output = try sentimentAnalysis.prediction(input: input)
            result = "Result: \(output.label)"
        } catch {
            print(error.localizedDescription)
        }
    }

    private func resultColor(_ input: String) -> Color {
        if input.contains("positive") {
            return .green
        } else if input.contains("negative") {
            return .red
        } else {
            return .gray
        }
    }
}

#Preview {
    SentimentAnalysis2()
}
