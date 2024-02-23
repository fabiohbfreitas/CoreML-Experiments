//
//  MainView.swift
//  CameraLiveCaptureTesting
//
//  Created by Fabio Freitas on 23/02/24.
//

import AVFoundation
import SwiftUI

struct MainView: View {
    var body: some View {
        CameraView()
            .ignoresSafeArea()
    }
}

#Preview {
    MainView()
}
