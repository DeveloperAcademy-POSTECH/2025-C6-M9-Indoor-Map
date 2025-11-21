//
//  IndoorMapView.swift
//  ShowcaseMap
//
//  Created by 딘은딘딘 on 11/15/25.
//

import MapKit
import SwiftData
import SwiftUI

struct IndoorMapView: View {
    @Environment(IMDFStore.self) var imdfStore
    @State private var viewModel: IndoorMapViewModel?
    @State private var selection: UUID?
    @Binding var selectedCategory: POICategory?
    @Binding var selectedBooth: TeamInfo?
    @Binding var selectedAmenity: Amenity?
    @Binding var selectedFloorOrdinal: Int?

    @State private var showMarkerDetail: Bool = false
    @State private var sheetDetent: PresentationDetent = .height(350)
    @State private var sheetHeight: CGFloat = 0
    @State private var animationDuration: CGFloat = 0
    @State private var selectedMarker: IntegrateMarker?

    @Environment(\.modelContext) private var modelContext
    @Query private var favoriteTeamInfos: [FavoriteTeamInfo]
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // iPad 좌측 패널 상태
    @State private var sidePanelContent: SidePanelContent = .category

    private var isFavorite: Bool {
        guard let teamInfo = selectedMarker?.teamInfo else { return false }
        return favoriteTeamInfos.contains { $0.teamInfoId == teamInfo.id }
    }

    private var layout: DeviceLayout {
        DeviceLayout(isIPad: horizontalSizeClass == .regular)
    }

    @Namespace private var mapScope
    var body: some View {
        Group {
            if let viewModel = viewModel {
                if layout.isIPad {
                    iPadMapContent(viewModel: viewModel)
                } else {
                    iPhoneMapContent(viewModel: viewModel)
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = IndoorMapViewModel(imdfStore: imdfStore)
                viewModel?.loadIMDFData()
            }
        }
        .onChange(of: selectedFloorOrdinal) { _, newOrdinal in
            if let ordinal = newOrdinal,
               let levelIndex = viewModel?.levels.firstIndex(where: { $0.properties.ordinal == ordinal })
            {
                viewModel?.selectedLevelIndex = levelIndex
                selectedFloorOrdinal = nil
            }
        }
        .onChange(of: selectedBooth) { _, newValue in
            if let booth = newValue {
                selection = booth.id
                selectedBooth = nil
                selectedCategory = nil
            }
        }
        .onChange(of: selectedAmenity) { _, newValue in
            if let amenity = newValue {
                selection = amenity.identifier
                selectedAmenity = nil
                selectedCategory = nil
            }
        }
        .onChange(of: selectedCategory) { _, newValue in
            viewModel?.selectedCategory = newValue
            if layout.isIPad {
                // iPad: 카테고리 선택 해제 시 패널을 category로 복귀
                if newValue == nil {
                    sidePanelContent = .category
                }
            }
        }
        .onChange(of: viewModel?.selectedCategory) { _, newValue in
            selectedCategory = newValue
        }
        .onChange(of: selection) { _, newValue in
            if let selectedId = newValue {
                selectedMarker = viewModel?.selectMarker(withId: selectedId)

                if let marker = selectedMarker {
                    if layout.isIPad {
                        switch marker.type {
                        case .booth(let teamInfo):
                            sidePanelContent = .boothDetail(teamInfo)
                        case .amenity(let amenityData):
                            sidePanelContent = .amenityDetail(amenityData)
                        }
                    } else {
                        // iPhone일때의 시트
                        sheetDetent = .height(350)
                        showMarkerDetail = true
                    }
                    // 마커 선택 시 카메라 이동
                    viewModel?.moveCameraToSelectedBooth(coordinate: marker.coordinate)
                }
            } else {
                selectedMarker = nil
                if layout.isIPad {
                    sidePanelContent = .category
                } else {
                    showMarkerDetail = false
                }
            }
        }
    }

    // 아이패드 레이아웃

    @ViewBuilder
    private func iPadMapContent(viewModel: IndoorMapViewModel) -> some View {
        ZStack {
            mapView(viewModel: viewModel)
                .ignoresSafeArea()

            // 우측 상단 버튼
            VStack {
                HStack {
                    Spacer()
                    BottomFloatingToolBar(viewModel: viewModel, isIPad: true)
                        .padding(.trailing, 20)
                        .padding(.top, 20)
                }
                Spacer()
            }
        }
        .mapScope(mapScope)
        .overlay(alignment: .center) {
            GeometryReader { geo in
                let sheetWidth = geo.size.width * 0.30
                let fullHeight = geo.size.height
                let sheetHeight = fullHeight
                iPadSidePanel
                    .frame(width: sheetWidth, height: sheetHeight)
                    .background(RoundedRectangle(cornerRadius: 34).fill(.ultraThickMaterial))
                    .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 0)

            }.padding(.horizontal, 32)
                .padding(.vertical, 1)
        }
    }

    @ViewBuilder
    private var iPadSidePanel: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                switch sidePanelContent {
                case .category:
                    CategoryGridView(selectedCategory: $selectedCategory)
                        .padding(.horizontal, 16)
                        .padding(.top, 32)

                case .boothDetail(let teamInfo):
                    iPadBoothDetailPanel(teamInfo: teamInfo)

                case .amenityDetail(let amenityData):
                    iPadAmenityDetailPanel(amenityData: amenityData)
                }
            }.padding(.vertical, 12)
        }
    }

    @ViewBuilder
    private func iPadBoothDetailPanel(teamInfo: TeamInfo) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                SheetIconButton(systemName: "xmark") {
                    sidePanelContent = .category
                    selection = nil
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

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
                    boothNumber: teamInfo.boothNumber,
                    downloadUrl: teamInfo.downloadUrl
                )

                TeamIntroductionView(
                    teamName: teamInfo.name,
                    teamUrl: teamInfo.teamUrl,
                    members: teamInfo.teamMemberString,
                    isIpad: true
                )
            }
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private func iPadAmenityDetailPanel(amenityData: MapMarkerData) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                SheetIconButton(systemName: "xmark") {
                    sidePanelContent = .category
                    selection = nil
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            AmenityDetailView(amenityData: amenityData,selection: $selection)
                .padding(.horizontal, 16)
        }
    }

    // 아이폰 레이아웃

    @ViewBuilder
    private func iPhoneMapContent(viewModel: IndoorMapViewModel) -> some View {
        ZStack {
            mapView(viewModel: viewModel)
                .ignoresSafeArea()
                .sheet(isPresented: $showMarkerDetail) {
                    Group {
                        if let marker = selectedMarker {
                            switch marker.type {
                            case .booth(let teamInfo):
                                BottomSheetView(
                                    sheetDetent: $sheetDetent,
                                    selectedTeamInfo: teamInfo,
                                    isFavorite: isFavorite,
                                    modelContext: modelContext,
                                    favoriteTeamInfos: favoriteTeamInfos,
                                    selection: $selection
                                )
                                .presentationDetents([.height(350), .large], selection: $sheetDetent)

                            case .amenity(let amenityData):
                                AmenityDetailView(amenityData: amenityData,selection: $selection)
                                    .presentationDetents([.height(350)])
                            }
                        }
                    }
                    .presentationBackgroundInteraction(.enabled)
                    .onGeometryChange(for: CGFloat.self) {
                        max(min($0.size.height, 350), 0)
                    } action: { oldValue, newValue in
                        sheetHeight = newValue

                        let diff = abs(newValue - oldValue)
                        let duration = max(min(diff / 100, 0.3), 0)
                        animationDuration = duration
                    }
                    .ignoresSafeArea()
                }
                .overlay(alignment: .bottomLeading) {
                    BottomFloatingToolBar(viewModel: viewModel, isIPad: false)
                        .padding(.leading, 20)
                        .offset(y: showMarkerDetail ? -(sheetHeight - 30) : -30)
                        .animation(.interpolatingSpring(duration: animationDuration, bounce: 0, initialVelocity: 0), value: sheetHeight)
                }.mapScope(mapScope)

            VStack {
                POICategoryFilterView(selectedCategory: $selectedCategory)
                    .padding(.top, 8)

                Spacer()
            }
        }
    }

    // 공통맵뷰

    @ViewBuilder
    private func mapView(viewModel: IndoorMapViewModel) -> some View {
        Map(position: .constant(viewModel.mapCameraPosition),
            bounds: MapCameraBounds(
                minimumDistance: 5,
                maximumDistance: 350
            ),
            interactionModes: [.zoom, .pan, .rotate],
            selection: $selection, scope: mapScope)
        {
            // 사용자 위치
            UserAnnotation()

            // Polygons (Unit, Level 등)
            ForEach(viewModel.mapPolygons) { polygon in
                MapPolygon(coordinates: polygon.coordinates)
                    .foregroundStyle(polygon.fillColor)
                    .stroke(polygon.strokeColor, lineWidth: polygon.lineWidth)
            }

            // 통합 마커 (Booth + Amenity)
            ForEach(viewModel.integrateMarkers) { marker in
                Marker(marker.title, systemImage: marker.iconName, coordinate: marker.coordinate)
                    .tint(marker.tintColor)
                    .tag(marker.id)
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .mapControlVisibility(.hidden)
    }

    @ViewBuilder
    func BottomFloatingToolBar(viewModel: IndoorMapViewModel, isIPad: Bool) -> some View {
        VStack(spacing: 16) {
            Button {
                // 탭으로 5 <-> 6 층 전환
                let nextIndex = (viewModel.selectedLevelIndex + 1) % viewModel.levels.count
                self.viewModel?.selectedLevelIndex = nextIndex
            } label: {
                Text("\(viewModel.currentLevelName)층")
                    .font(.system(size: 19, weight: .medium))
            }
            .frame(width: 48, height: 48)
            .applyGlassEffect() // CategoryFilterView 안에 extension으로 선언됨
            .clipShape(Circle())

            MapUserLocationButton(scope: mapScope)
//                .buttonBorderShape(.circle)
                .clipShape(Circle())
                .frame(width: 48, height: 48)
//                .tint(Color.primary)
                .clipShape(Circle())
                .applyGlassEffect()
        }
        .foregroundStyle(Color.primary)
    }
}

// 아이폰 시트

struct BottomSheetView: View {
    @Binding var sheetDetent: PresentationDetent
    @Environment(\.dismiss) var dismiss
    let selectedTeamInfo: TeamInfo?
    let isFavorite: Bool
    let modelContext: ModelContext
    let favoriteTeamInfos: [FavoriteTeamInfo]
    @Binding var selection: UUID?

    var body: some View {
        if let teamInfo = selectedTeamInfo {
            ScrollView {
                HStack {
                    SheetIconButton(systemName: isFavorite ? "star.fill" : "star") {
                        if isFavorite {
                            if let favorite = favoriteTeamInfos.first(where: { $0.teamInfoId == teamInfo.id }) {
                                modelContext.delete(favorite)
                            }
                        } else {
                            let favorite = FavoriteTeamInfo(teamInfoId: teamInfo.id)
                            modelContext.insert(favorite)
                        }
                    }

                    Spacer()
                    SheetIconButton(systemName: "xmark") {
                        selection = nil
                        dismiss()
                    }
                }
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
                        boothNumber: teamInfo.boothNumber,
                        downloadUrl: teamInfo.downloadUrl
                    )

                    TeamIntroductionView(
                        teamName: teamInfo.name,
                        teamUrl: teamInfo.teamUrl,
                        members: teamInfo.teamMemberString,
                        isIpad: false
                    )
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 26)
        }
    }
}

struct SheetIconButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .medium))
                .padding(12)
                .background(.ultraThinMaterial)
                .frame(width: 40, height: 40)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// 아이패드 사이드패널 뷰형태 구분

private enum SidePanelContent {
    case category
    case boothDetail(TeamInfo)
    case amenityDetail(MapMarkerData)
}

private struct DeviceLayout {
    let isIPad: Bool
}

#Preview {
    let store = IMDFStore()
    store.loadIMDFData()

    return IndoorMapView(
        selectedCategory: .constant(nil),
        selectedBooth: .constant(nil),
        selectedAmenity: .constant(nil),
        selectedFloorOrdinal: .constant(nil)
    )
    .environment(store)
}
