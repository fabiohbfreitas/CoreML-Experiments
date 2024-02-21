//
//  MainApp.swift
//  SentimentAnalysis
//
//  Created by Fabio Freitas on 19/02/24.
//

import SwiftUI

@main
struct MainApp: App {
    @State var selectedTab = 4
    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                SentimentAnalysisEn()
                    .tabItem { Label(
                        title: { Text("Text 1") },
                        icon: { Image(systemName: "doc.text.magnifyingglass") }
                    ) }
                    .tag(1)
                SentimentAnalysis2()
                    .tabItem { Label(
                        title: { Text("Text 2") },
                        icon: { Image(systemName: "doc.text.magnifyingglass") }
                    ) }
                    .tag(2)
                EmotionAnalysisView()
                    .tabItem { Label(
                        title: { Text("Emotion") },
                        icon: { Image(systemName: "doc.text.magnifyingglass") }
                    ) }
                    .tag(3)
                EmotionImageClassificationView()
                    .tabItem { Label(
                        title: { Text("Images") },
                        icon: { Image(systemName: "doc.text.magnifyingglass") }
                    ) }
                    .tag(4)
            }
        }
    }
}
