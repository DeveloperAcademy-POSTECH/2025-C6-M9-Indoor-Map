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

    private var isFavorite: Bool {
        guard let teamInfo = selectedMarker?.teamInfo else { return false }
        return favoriteTeamInfos.contains { $0.teamInfoId == teamInfo.id }
    }

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
        }
        .onChange(of: selectedFloorOrdinal) { _, newOrdinal in
            if let ordinal = newOrdinal,
               let levelIndex = viewModel?.levels.firstIndex(where: { $0.properties.ordinal == ordinal }) {
                viewModel?.selectedLevelIndex = levelIndex
                selectedFloorOrdinal = nil
            }
        }
        .onChange(of: selectedBooth) { _, newValue in
            if let booth = newValue {
                selection = booth.id
                selectedBooth = nil
            }
        }
        .onChange(of: selectedAmenity) { _, newValue in
            if let amenity = newValue {
                selection = amenity.identifier
                selectedAmenity = nil
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
                selectedMarker = viewModel?.selectMarker(withId: selectedId)

                if let marker = selectedMarker {
                    sheetDetent = .height(350)
                    showMarkerDetail = true

                    // 마커 선택 시 카메라 이동
                    viewModel?.moveCameraToSelectedBooth(coordinate: marker.coordinate)
                }
            } else {
                selectedMarker = nil
                showMarkerDetail = false
            }
        }
    }

    @ViewBuilder
    private func mapContent(viewModel: IndoorMapViewModel) -> some View {
        ZStack {
            Map(position: .constant(viewModel.mapCameraPosition),
                bounds: MapCameraBounds(
                    minimumDistance: 5,
                    maximumDistance: 350
                ),
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
            .mapStyle(.standard)
            .mapControlVisibility(.hidden)
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
                                favoriteTeamInfos: favoriteTeamInfos
                            )
                            .presentationDetents([.height(350), .large], selection: $sheetDetent)

                        case .amenity(let amenityData):
                            AmenityDetailView(amenityData: amenityData)
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
                BottomFloatingToolBar(viewModel: viewModel)
                    .padding(.leading, 20)
            }

            VStack {
                POICategoryFilterView(selectedCategory: $selectedCategory)
                    .padding(.top, 8)

                Spacer()
            }
        }
    }

    @ViewBuilder
    func BottomFloatingToolBar(viewModel: IndoorMapViewModel) -> some View {
        VStack(spacing: 16) {
            Button {
                // 탭으로 5 <-> 6 층 전환
                let nextIndex = (viewModel.selectedLevelIndex + 1) % viewModel.levels.count
                self.viewModel?.selectedLevelIndex = nextIndex
            } label: {
                Text("\(viewModel.currentLevelName)층")
                    .font(.system(size: 19, weight: .medium))
            }
            .padding(.all, 13)
            .applyGlassEffect() //CategoryFilterView 안에 extension으로 선언됨
            .clipShape(Circle())

            Button {} label: {
                Image(systemName: "location")
                    .font(.system(size: 19, weight: .medium))
            }
            .padding(.all, 13)
            .applyGlassEffect()
            .clipShape(Circle())
        }
        .font(.title3)
        .foregroundStyle(Color.primary)
        .offset(y: showMarkerDetail ? -(sheetHeight - 30 /* 프리뷰에서는 겹쳐보일 수 있음 */ ) : -30)
        .animation(.interpolatingSpring(duration: animationDuration, bounce: 0, initialVelocity: 0), value: sheetHeight)
    }
}


struct BottomSheetView: View {
    @Binding var sheetDetent: PresentationDetent
    @Environment(\.dismiss) var dismiss
    let selectedTeamInfo: TeamInfo?
    let isFavorite: Bool
    let modelContext: ModelContext
    let favoriteTeamInfos: [FavoriteTeamInfo]

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
