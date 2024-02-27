//
//  MainView.swift
//  CameraLiveCaptureTesting
//
//  Created by Fabio Freitas on 23/02/24.
//

import AVFoundation
import NaturalLanguage
import SwiftUI

struct MainView: View {
    var body: some View {
        CameraView()
            .ignoresSafeArea()
            .onAppear {
                let test = ""
                let rec = NLLanguageRecognizer()
                defer { rec.reset() }
                rec.processString(test)
//                print(rec.dominantLanguage?.rawValue ?? "<nope>")
            }
    }
}

#Preview {
    MainView()
}
