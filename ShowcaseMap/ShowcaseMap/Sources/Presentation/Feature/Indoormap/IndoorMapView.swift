//
//  IndoorMapView.swift
//  ShowcaseMap
//
//  Created by 딘은딘딘 on 11/16/25.
//

import SwiftUI

struct IndoorMapView: View {
    @StateObject private var viewModel = IndoorMapViewModel()

    var body: some View {
        ZStack(alignment: .trailing) {
            MapViewRepresentable(
                overlays: viewModel.currentLevelOverlays,
                annotations: viewModel.currentLevelAnnotations,
                features: viewModel.currentLevelFeatures,
                region: viewModel.region
            )
            .ignoresSafeArea()

            if !viewModel.levels.isEmpty {
                LevelPickerSwiftUI(
                    levels: viewModel.levels,
                    selectedIndex: $viewModel.selectedLevelIndex
                )
                .padding(.trailing, 16)
            }
        }
        .onAppear {
            viewModel.loadIMDFData()
        }
    }
}

#Preview {
    IndoorMapView()
}
