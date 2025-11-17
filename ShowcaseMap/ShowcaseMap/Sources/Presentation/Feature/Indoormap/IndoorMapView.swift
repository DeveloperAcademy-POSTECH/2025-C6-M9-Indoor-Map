//
//  IndoorMapView.swift
//  ShowcaseMap
//
//  Created by 딘은딘딘 on 11/15/25.
//

import MapKit
import SwiftUI

struct IndoorMapView: View {
    @State private var viewModel = IndoorMapViewModel()
    @State private var selection: UUID?
    @Binding var selectedCategory: POICategory?

    @State private var showTeamInfo: Bool = false
    @State private var sheetDetent: PresentationDetent = .height(350)
    @State private var sheetHeight: CGFloat = 0
    @State private var animationDuration: CGFloat = 0
    @State private var selectedTeamInfo: TeamInfo?

    @Namespace private var mapScope
    var body: some View {
        ZStack {
            Map(position: $viewModel.mapCameraPosition, selection: $selection, scope: mapScope) {
                // 사용자 위치
                UserAnnotation()

                // Polygons (Unit, Level 등)
                ForEach(viewModel.mapPolygons) { polygon in
                    MapPolygon(coordinates: polygon.coordinates)
                        .foregroundStyle(polygon.fillColor)
                        .stroke(polygon.strokeColor, lineWidth: polygon.lineWidth)
                }

                // annotation (Amenity, Occupant 등)
//                ForEach(viewModel.mapMarkers) { marker in
//                    Marker(marker.title, coordinate: marker.coordinate)
//                        .tag(marker.id)
//                }

                // 부스 마커
                ForEach(viewModel.teamInfos) { teamInfo in
                    Marker(teamInfo.name, coordinate: teamInfo.displayPoint)
                        .tag(teamInfo.id)
                }
            }
            .mapStyle(.standard)
            .mapControlVisibility(.hidden)
            .ignoresSafeArea()
            .sheet(isPresented: $showTeamInfo) {
                BottomSheetView(
                    sheetDetent: $sheetDetent,
                    selectedTeamInfo: selectedTeamInfo
                )
                .presentationDetents([.height(80), .height(350), .large], selection: $sheetDetent)
                .presentationBackgroundInteraction(.enabled)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onGeometryChange(for: CGFloat.self) {
                    max(min($0.size.height, 350), 0)
                } action: { oldValue, newValue in
                    sheetHeight = newValue

                    let diff = abs(newValue - oldValue)
                    let duration = max(min(diff / 100, 0.3), 0)
                    animationDuration = duration

                }.ignoresSafeArea()
            }
            .overlay(alignment: .bottomLeading) {
                BottomFloatingToolBar()
                    .padding(.leading, 20)
            }

            VStack {
                POICategoryFilterView(selectedCategory: $viewModel.selectedCategory)
                    .padding(.top, 8)

                Spacer()
            }
            // LEVEL PICKER
//            VStack {
//                Spacer()
//
//                HStack {
//                    if !viewModel.levels.isEmpty {
//                        LevelPickerSwiftUI(
//                            levels: viewModel.levels,
//                            selectedIndex: $viewModel.selectedLevelIndex
//                        )
//                        .padding(.leading, 16)
//                        .padding(.bottom, 16)
//                    }
//
//                    Spacer()
//                }
//            }
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
        .onChange(of: selection) { _, newValue in
            if let selectedId = newValue {
                selectedTeamInfo = viewModel.teamInfos.first { $0.id == selectedId }
                if selectedTeamInfo != nil {
                    sheetDetent = .height(350)
                    showTeamInfo = true
                }
            } else {
                selectedTeamInfo = nil
                showTeamInfo = false
            }
        }
    }

    @ViewBuilder
    func BottomFloatingToolBar() -> some View {
        VStack(spacing: 16) {
            Button {} label: {
                Image(systemName: "location")
            }
            .padding(.all, 10)
            .background(Color.white)
            .clipShape(Capsule())

            Button {} label: {
                Image(systemName: "location")
            }
            .padding(.all, 10)
            .background(Color.white)
            .clipShape(Capsule())
        }
        .font(.title3)
        .foregroundStyle(Color.primary)
        .offset(y: showTeamInfo ? -(sheetHeight - 50) : -10)
        .animation(.interpolatingSpring(duration: animationDuration, bounce: 0, initialVelocity: 0), value: sheetHeight)
    }
}

struct BottomSheetView: View {
    @Binding var sheetDetent: PresentationDetent
    let selectedTeamInfo: TeamInfo?

    var body: some View {
        if let teamInfo = selectedTeamInfo {
            if sheetDetent == .height(80) {
                VStack(spacing: 4) {
                    Text(teamInfo.appName)
                        .font(.system(size: 17))
                        .foregroundStyle(Color.primary)
                        .bold()

                    Text("부스 · \(teamInfo.boothNumber)")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .center, spacing: 16) {
                        BoothHeaderView(
                            name: teamInfo.appName,
                            boothNumber: teamInfo.boothNumber
                        )

                        AppDescriptionView(
                            description: teamInfo.appDescription,
                            categoryLine: teamInfo.categoryLine
                        )

                        AppDownloadCardView(
                            appName: teamInfo.appName,
                            boothNumber: teamInfo.boothNumber
                        ) {
                            print("다운로드 탭")
                        }

                        TeamIntroductionView(
                            teamName: teamInfo.name,
                            teamUrl: teamInfo.teamUrl,
                            members: teamInfo.members,
                            isIpad: false
                        )
                    }
                    .padding(.all, 20)
                }
            }
        }
    }
}

#Preview {
    IndoorMapView(selectedCategory: .constant(nil))
}
