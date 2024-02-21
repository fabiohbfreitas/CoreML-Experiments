//
//  MainApp.swift
//  SentimentAnalysis
//
//  Created by Fabio Freitas on 19/02/24.
//

import SwiftUI

@main
struct MainApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                SentimentAnalysisEn()
                    .tabItem { Label(
                        title: { Text("Text 1") },
                        icon: { Image(systemName: "doc.text.magnifyingglass") }
                    ) }
                SentimentAnalysis2()
                    .tabItem { Label(
                        title: { Text("Text 2") },
                        icon: { Image(systemName: "doc.text.magnifyingglass") }
                    ) }
                EmotionAnalysisView()
                    .tabItem { Label(
                        title: { Text("Emotion") },
                        icon: { Image(systemName: "doc.text.magnifyingglass") }
                    ) }
                EmotionImageClassificationView()
                    .tabItem { Label(
                        title: { Text("Images") },
                        icon: { Image(systemName: "doc.text.magnifyingglass") }
                    ) }
            }
        }
    }
}
