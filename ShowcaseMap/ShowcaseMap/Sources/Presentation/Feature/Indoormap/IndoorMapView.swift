//
//  IndoorMapView.swift
//  ShowcaseMap
//
//  Created by 딘은딘딘 on 11/15/25.
//

import MapKit
import SwiftUI

struct IndoorMapView: View {
    @Environment(IMDFStore.self) var imdfStore
    @State private var viewModel: IndoorMapViewModel?
    @State private var selection: UUID?
    @Binding var selectedCategory: POICategory?
    @Binding var selectedBooth: TeamInfo?

    @State private var showTeamInfo: Bool = false
    @State private var sheetDetent: PresentationDetent = .height(350)
    @State private var sheetHeight: CGFloat = 0
    @State private var animationDuration: CGFloat = 0
    @State private var selectedTeamInfo: TeamInfo?

    @State private var isLevelPickerExpanded: Bool = false
    @State private var showLevelInfo: Bool = false
    @State private var selectedLevelName: String = ""

    @Namespace private var mapScope
    var body: some View {
        Group {
            if let viewModel = viewModel {
                mapContent(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = IndoorMapViewModel(imdfStore: imdfStore)
                viewModel?.loadIMDFData()
            }

            selectedLevelName = viewModel?.currentLevelName ?? ""

            // BoothDetailView에서 상태 전달 염두
            if let booth = selectedBooth {
                selection = booth.id
                selectedBooth = nil
            }
        }
        .onChange(of: selectedCategory) { _, newValue in
            viewModel?.selectedCategory = newValue
        }
        .onChange(of: viewModel?.selectedCategory) { _, newValue in
            selectedCategory = newValue
        }
        .onChange(of: selection) { _, newValue in
            if let selectedId = newValue {
                selectedTeamInfo = viewModel?.selectBooth(withId: selectedId)

                if let teamInfo = selectedTeamInfo {
                    // 마커 선택 시 층 모드 해제
                    isLevelPickerExpanded = false
                    showLevelInfo = false

                    sheetDetent = .height(350)
                    showTeamInfo = true

                    // 탭한 마커 중심으로 카메라 이동
                    viewModel?.moveCameraToSelectedBooth(coordinate: teamInfo.displayPoint)
                }
            } else {
                selectedTeamInfo = nil
                showTeamInfo = false
            }
        }
        .onChange(of: isLevelPickerExpanded) { _, newValue in
            if newValue {
                // 층선택시 부스관련 시트 제거
                selection = nil
                showTeamInfo = false

                // 바로 층정보 시트 표시
                selectedLevelName = viewModel?.currentLevelName ?? ""
                showLevelInfo = true
            }
        }
    }

    @ViewBuilder
    private func mapContent(viewModel: IndoorMapViewModel) -> some View {
        ZStack {
            Map(position: .constant(viewModel.mapCameraPosition), selection: $selection, scope: mapScope) {
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
            .sheet(isPresented: $showLevelInfo) {
                LevelInfoSheet(levelName: selectedLevelName)
                    .presentationDetents([.height(80)])
                    .presentationBackgroundInteraction(.enabled)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(spacing: 0) {
                    if isLevelPickerExpanded {
                        LevelPickerOverlay(viewModel: viewModel)
                            .padding(.bottom, 16)
                    }

                    BottomFloatingToolBar(viewModel: viewModel)
                }
                .padding(.leading, 20)
            }

            VStack {
                POICategoryFilterView(selectedCategory: .constant(viewModel.selectedCategory))
                    .padding(.top, 8)

                Spacer()
            }
        }
    }

    @ViewBuilder
    func LevelPickerOverlay(viewModel: IndoorMapViewModel) -> some View {
        VStack(spacing: 12) {
            // X 버튼
            Button {
                withAnimation {
                    isLevelPickerExpanded = false
                    showLevelInfo = false
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 19, weight: .medium))
            }
            .padding(.all, 10)
            .background(Color(.systemBackground))
            .clipShape(Circle())

            // 층 버튼들
            VStack(spacing: 4) {
                ForEach(Array(viewModel.levels.enumerated()), id: \.offset) { index, level in
                    let levelName = level.properties.shortName.bestLocalizedValue ?? "\(level.properties.ordinal)"

                    Button {
                        self.viewModel?.selectedLevelIndex = index
                        selectedLevelName = levelName
                        showLevelInfo = true
                    } label: {
                        Text(levelName)
                            .font(.system(size: 19, weight: .medium))
                            .foregroundStyle(Color.primary)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(viewModel.selectedLevelIndex == index ? Color.primary.opacity(0.2) : Color(.systemBackground))
                            )
                    }
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 26)
                    .fill(Color(.systemBackground).opacity(0.9))
            )
        }
        .foregroundStyle(Color.primary)
    }

    @ViewBuilder
    func BottomFloatingToolBar(viewModel: IndoorMapViewModel) -> some View {
        if !isLevelPickerExpanded {
            VStack(spacing: 16) {
                Button {
                    withAnimation {
                        isLevelPickerExpanded.toggle()
                    }
                } label: {
                    Text(viewModel.currentLevelName)
                        .font(.system(size: 19, weight: .medium))
                }
                .padding(.all, 10)
                .background(Color(.systemBackground))
                .clipShape(Circle())

                Button {} label: {
                    Image(systemName: "location")
                        .font(.system(size: 19, weight: .medium))
                }
                .padding(.all, 10)
                .background(Color(.systemBackground))
                .clipShape(Circle())
            }
            .font(.title3)
            .foregroundStyle(Color.primary)
            .offset(y: showTeamInfo ? -(sheetHeight - 50) : -10)
            .animation(.interpolatingSpring(duration: animationDuration, bounce: 0, initialVelocity: 0), value: sheetHeight)
        }
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

struct LevelInfoSheet: View {
    let levelName: String

    var body: some View {
        VStack(spacing: 4) {
            Text(levelName)
                .font(.headline)
                .foregroundStyle(Color.primary)
                .bold()

            Text("<설명>")
                .font(.caption)
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    IndoorMapView(selectedCategory: .constant(nil), selectedBooth: .constant(nil))
        .environment(IMDFStore())
}
