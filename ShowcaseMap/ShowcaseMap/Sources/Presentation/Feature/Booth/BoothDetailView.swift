//
//  BoothDetailView.swift
//  ShowcaseMap
//
//  Created by bishoe01 on 11/15/25.
//

import MapKit
import SwiftData
import SwiftUI

struct BoothDetailView: View {
    let teamInfo: TeamInfo
    @Binding var tabSelection: TabIdentifier
    @Binding var selectedBoothForMap: TeamInfo?
    @Binding var selectedFloorOrdinal: Int?

    @Environment(IMDFStore.self) var imdfStore
    @State private var miniMapPolygons: [MapPolygonData] = []
    @State private var miniMapCameraPosition: MapCameraPosition = .automatic

    @Environment(\.modelContext) private var modelContext
    @Query private var favoriteTeamInfos: [FavoriteTeamInfo]
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isFavorite: Bool {
        favoriteTeamInfos.contains { $0.teamInfoId == teamInfo.id }
    }

    private var layout: DeviceLayout {
        DeviceLayout(isIPad: horizontalSizeClass == .regular)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 12) {
                if layout.isIPad {
                    iPadAppIntroView
                } else {
                    iPhoneHeaderView
                }
                TeamIntroductionView(
                    teamName: teamInfo.name,
                    teamUrl: teamInfo.teamUrl,
                    members: teamInfo.teamMemberString,
                    isIpad: layout.isIPad
                )

                Button {
                    selectedBoothForMap = teamInfo
                    selectedFloorOrdinal = teamInfo.levelId
                    tabSelection = .map
                } label: {
                    Map(position: $miniMapCameraPosition,
                        interactionModes: [.zoom, .pan, .rotate])
                    {
                        // 실내지도
                        ForEach(miniMapPolygons) { polygon in
                            MapPolygon(coordinates: polygon.coordinates)
                                .foregroundStyle(polygon.fillColor)
                                .stroke(polygon.strokeColor, lineWidth: polygon.lineWidth)
                        }
                        // 실제 주인공
                        Marker(teamInfo.appName, coordinate: teamInfo.displayPoint)
                    }
                    .mapStyle(.standard(pointsOfInterest: .excludingAll))
                    .mapControlVisibility(.hidden)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .allowsHitTesting(false)
                }
            }
            .padding(.horizontal, layout.horizontalPadding)
            .padding(.vertical, layout.verticalPadding)
            .safeAreaPadding(.bottom, 100)
        }
        .task {
            // 5층 데이터가져오기(부스가 5층)
            let mapData = imdfStore.getMapData(for: 5, category: nil)
            miniMapPolygons = mapData.polygons

            // 카메라 확대
            miniMapCameraPosition = .camera(
                MapCamera(
                    centerCoordinate: teamInfo.displayPoint,
                    distance: 60,
                    heading: -23,
                    pitch: 0
                )
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if isFavorite {
                        if let favorite = favoriteTeamInfos.first(where: { $0.teamInfoId == teamInfo.id }) {
                            modelContext.delete(favorite)
                        }
                    } else {
                        let favorite = FavoriteTeamInfo(teamInfoId: teamInfo.id)
                        modelContext.insert(favorite)
                    }
                } label: {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                }
            }
        }
    }

    @ViewBuilder
    private var iPadAppIntroView: some View {
        HStack(alignment: .top, spacing: 24) {
            Image(teamInfo.boothNumber)
                .resizable()
                .scaledToFit()
                .frame(width: layout.logoSize, height: layout.logoSize)
                .logoStrokeBorder(cornerRadius: layout.logoCornerRadius)

            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(teamInfo.appName)
                        .font(.title)
                        .foregroundStyle(Color.primary)
                        .bold()

                    Text("부스 · \(teamInfo.boothNumber)")
                        .font(.callout)
                        .foregroundStyle(Color.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(teamInfo.appDescription)
                        .font(.body)
                        .foregroundStyle(Color.primary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(teamInfo.categoryLine)
                        .font(.subheadline)
                        .foregroundStyle(Color(.secondaryLabel))
                }

                Color.clear.frame(height: 12)

                DownloadButton(downloadUrl: teamInfo.downloadUrl, isLarge: true)
            }

            Spacer()
        }
    }

    @ViewBuilder
    private var iPhoneHeaderView: some View {
        BoothHeaderView(
            name: teamInfo.appName,
            boothNumber: teamInfo.boothNumber
        )

        VStack(alignment: .leading, spacing: 12) {
            AppDescriptionView(
                description: teamInfo.appDescription,
                categoryLine: teamInfo.categoryLine
            )

            AppDownloadCardView(appName: teamInfo.appName, boothNumber: teamInfo.boothNumber, downloadUrl: teamInfo.downloadUrl)
        }
    }
}

// 부스 정보 헤더
struct BoothHeaderView: View {
    let name: String
    let boothNumber: String

    var body: some View {
        VStack(alignment: .center, spacing: 2) {
            Text(name)
                .font(.title)
                .foregroundStyle(Color.primary)
                .bold()

            Text("부스 · \(boothNumber)")
                .font(.callout)
                .foregroundStyle(Color.secondary)
        }
    }
}

// 앱 소개
struct AppDescriptionView: View {
    let description: String
    let categoryLine: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(description)
                .font(.body)
                .foregroundStyle(Color.primary)

            Text(categoryLine)
                .font(.subheadline)
                .foregroundStyle(Color(.secondaryLabel))
        }
    }
}

// 앱 다운로드 카드
struct AppDownloadCardView: View {
    let appName: String
    let boothNumber: String
    let downloadUrl: URL?

    @State private var showAlert = false

    var body: some View {
        HStack(spacing: 12) {
            Image(boothNumber)
                .resizable()
                .frame(width: 60, height: 60)
                .logoStrokeBorder(cornerRadius: 18)
            Text(appName)
            Spacer()
            if let downloadUrl {
                Link(destination: downloadUrl) {
                    Text("받기")
                }
                .downloadButtonStyle()
            } else {
                Button("받기") {
                    showAlert = true
                }.downloadButtonStyle()
            }
        }
        .padding(.all, 12)
        .background(Color.quatFill)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .alert("해당 앱은 현재 내부 관계자 대상으로만 제공됩니다.", isPresented: $showAlert) {
            Button("확인", role: .cancel) {}
        }
    }
}

// 팀소개
struct TeamIntroductionView: View {
    let teamName: String
    let teamUrl: URL
    let members: String
    let isIpad: Bool
    let isSheet: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("팀 소개")
                .font(isIpad ? .title3 : .title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color.primary)

            HStack {
                Text("팀 및 프로젝트 설명")
                    .fontWeight(.medium)
                    .foregroundStyle(Color.gray)

                Spacer()
                Link("NotionLink", destination: teamUrl)
                    .fontWeight(.regular)
                    .foregroundStyle(Color.teal)
                    .underline()
            }

            HStack {
                Text("팀명")
                    .fontWeight(.medium)
                    .foregroundStyle(Color.gray)

                Spacer()
                Text(teamName)
                    .fontWeight(.regular)
                    .foregroundStyle(Color.primary)
            }

            HStack(alignment: .top) {
                Text("팀원")
                    .fontWeight(.medium)
                    .foregroundStyle(Color.gray)
                Spacer()
                Text(members)
                    .fontWeight(.regular)
                    .foregroundStyle(Color.primary)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .font(.subheadline)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }
}

#Preview {
    NavigationStack {
        BoothDetailView(
            teamInfo: TeamInfo(
                levelId: 4,
                boothNumber: "1",
                name: "샘플 팀",
                appName: "샘플앱",
                appDescription: "샘플 앱 설명 샘플 앱 설명 샘플 앱 설명 샘플 앱 설명 샘플 앱 설명 샘플 앱 설명 샘플 앱 설명샘플 앱 설명샘플 앱 설명샘플 앱 설명샘플 앱 설명샘플 앱 설명샘플 앱 설명",
                members: [],
                category: .productivity,
                downloadUrl: URL(string: "https://example.com")!,
                teamUrl: URL(string: "https://example.com")!,
                displayPoint: [],
            ),
            tabSelection: .constant(.booth),
            selectedBoothForMap: .constant(nil),
            selectedFloorOrdinal: .constant(nil)
        )
        .environment(IMDFStore())
    }
    .modelContainer(for: FavoriteTeamInfo.self, inMemory: true)
}

private struct DeviceLayout {
    let isIPad: Bool

    var horizontalPadding: CGFloat {
        isIPad ? 32 : 15
    }

    var verticalPadding: CGFloat {
        isIPad ? 28 : 0
    }

    var logoSize: CGFloat {
        isIPad ? 240 : 60
    }

    var logoCornerRadius: CGFloat {
        isIPad ? 38 : 18
    }
}

// 다운로드 버튼
struct DownloadButton: View {
    let downloadUrl: URL?
    let isLarge: Bool

    @State private var showAlert = false

    var body: some View {
        Group {
            if let downloadUrl {
                Link(destination: downloadUrl) {
                    buttonLabel
                }
            } else {
                Button {
                    showAlert = true
                } label: {
                    buttonLabel
                }
            }
        }
        .downloadButtonStyle(isLarge: isLarge)
        .alert("해당 앱은 현재 내부 관계자 대상으로만 제공됩니다.", isPresented: $showAlert) {
            Button("확인", role: .cancel) {}
        }
    }

    private var buttonLabel: some View {
        HStack(spacing: 0) {
            Text("앱 다운로드")
            Image(systemName: "arrow.up.forward")
        }
    }
}

private extension View {
    func downloadButtonStyle(isLarge: Bool = false) -> some View {
        font(isLarge ? .body : .subheadline)
            .foregroundStyle(Color.teal)
            .padding(.vertical, isLarge ? 14 : 4)
            .padding(.horizontal, isLarge ? 20 : 13)
            .background(Color.downloadBtn)
            .clipShape(Capsule())
    }
}
