//
//  IndoorMapView.swift
//  ShowcaseMap
//
//  Created by 딘은딘딘 on 11/15/25.
//

import SwiftUI

struct IndoorMapView: View {
    @StateObject private var viewModel = IndoorMapViewModel()

    var body: some View {
        ZStack {
            MapViewRepresentable(
                overlays: viewModel.currentLevelOverlays,
                annotations: viewModel.currentLevelAnnotations,
                features: viewModel.currentLevelFeatures,
                region: viewModel.region
            )
            .ignoresSafeArea()

            VStack {
                POICategoryFilterView(selectedCategory: $viewModel.selectedCategory)
                    .padding(.top, 8)

                Spacer()
            }

            VStack {
                Spacer()

                HStack {
                    if !viewModel.levels.isEmpty {
                        LevelPickerSwiftUI(
                            levels: viewModel.levels,
                            selectedIndex: $viewModel.selectedLevelIndex
                        )
                        .padding(.leading, 16)
                        .padding(.bottom, 16)
                    }

                    Spacer()
                }
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
