//
//  IndoorMapView.swift
//  ShowcaseMap
//
//  Created by 딘은딘딘 on 11/15/25.
//

import SwiftUI

struct IndoorMapView: View {
    @StateObject private var viewModel = IndoorMapViewModel()
    @Binding var selectedCategory: POICategory?

    var body: some View {
        ZStack {
            MapViewRepresentable(
                overlays: viewModel.currentLevelOverlays,
                annotations: viewModel.currentLevelAnnotations,
                features: viewModel.currentLevelFeatures,
                region: viewModel.region,
                onAnnotationTap: { annotation in
                    viewModel.handleAnnotationTap(annotation)
                }
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
        .onChange(of: selectedCategory) { _, newValue in
            viewModel.selectedCategory = newValue
        }
        .onChange(of: viewModel.selectedCategory) { _, newValue in
            selectedCategory = newValue
        }
        .sheet(item: $viewModel.selectedBooth) { booth in
            BoothDetailView(teamInfo: booth)
        }
    }
}

#Preview {
    IndoorMapView(selectedCategory: .constant(nil))
}
