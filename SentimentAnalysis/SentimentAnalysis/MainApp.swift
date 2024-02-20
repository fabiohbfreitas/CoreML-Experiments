//
//  SentimentAnalysisApp.swift
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
                        title: { Text("Model 1") },
                        icon: { Image(systemName: "doc.text.magnifyingglass") }
                    ) }
                SentimentAnalysis2()
                    .tabItem { Label(
                        title: { Text("Model 2") },
                        icon: { Image(systemName: "doc.text.magnifyingglass") }
                    ) }
            }
        }
    }
}
