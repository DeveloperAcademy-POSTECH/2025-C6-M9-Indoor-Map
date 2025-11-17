//
//  IndoorMapView.swift
//  ShowcaseMap
//
//  Created by 딘은딘딘 on 11/15/25.
//

import SwiftUI
import MapKit

struct IndoorMapView: View {
    @StateObject private var viewModel = IndoorMapViewModel()
    @Binding var selectedCategory: POICategory?

    var body: some View {
        ZStack {
            Map(position: $viewModel.mapCameraPosition) {
                // 사용자 위치
                UserAnnotation()

                // Polygons (Unit, Level 등)
                ForEach(viewModel.mapPolygons) { polygon in
                    MapPolygon(coordinates: polygon.coordinates)
                        .foregroundStyle(polygon.fillColor)
                        .stroke(polygon.strokeColor, lineWidth: polygon.lineWidth)
                }

                // Markers (Amenity, Occupant 등)
                ForEach(viewModel.mapMarkers) { marker in
                    Annotation(marker.title, coordinate: marker.coordinate) {
                        CategoryMarkerView(category: marker.category)
                            .onTapGesture {
                                viewModel.handleAnnotationTap(marker.annotation)
                            }
                    }
                }
            }
            .mapStyle(.standard)
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
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

// MARK: - CategoryMarkerView
struct CategoryMarkerView: View {
    let category: POICategory?

    var body: some View {
        if let category = category {
            ZStack {
                Circle()
                    .fill(Color(uiColor: category.color))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)

                Image(systemName: category.iconName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
        } else {
            // Occupant나 기타 마커
            ZStack {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)

                Image(systemName: "person.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    IndoorMapView(selectedCategory: .constant(nil))
}
