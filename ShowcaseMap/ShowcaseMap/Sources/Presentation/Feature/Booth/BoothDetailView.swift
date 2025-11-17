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
                    members: teamInfo.members,
                    isIpad: layout.isIPad
                )

                Button {
                    selectedBoothForMap = teamInfo
                    tabSelection = .map
                } label: {
                    Map {
                        Marker(teamInfo.appName, coordinate: teamInfo.displayPoint)
                    }
                    .frame(width: .infinity, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .allowsHitTesting(false)
                }
            }
            .padding(.horizontal, layout.horizontalPadding)
            .padding(.vertical, layout.verticalPadding)
            .safeAreaPadding(.bottom, 100)
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

            if #available(iOS 26.0, *) {
                ToolbarSpacer(.fixed, placement: .topBarTrailing)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // TODO: 공유 로직
                } label: {
                    Image(systemName: "square.and.arrow.up")
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
                .clipShape(RoundedRectangle(cornerRadius: layout.logoCornerRadius))

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

                    Text(teamInfo.categoryLine)
                        .font(.subheadline)
                        .foregroundStyle(Color(.tertiaryLabel))
                }
                Spacer()

                Button {
                    print(teamInfo.members)
                    // TODO: teaminfo.appUrl 사용
                } label: {
                    HStack(spacing: 0) {
                        Text("앱 다운로드")
                            .font(.body)

                        Image(systemName: "arrow.up.forward")
                    }
                }
                .foregroundStyle(Color.teal)
                .padding(.vertical, 14)
                .padding(.horizontal, 20)
                .background(Color.downloadBtn)
                .clipShape(Capsule())
            }

            Spacer()
        }
    }

    @ViewBuilder
    private var iPhoneHeaderView: some View {
        BoothHeaderView(
            name: teamInfo.name,
            boothNumber: teamInfo.boothNumber
        )

        VStack(alignment: .leading, spacing: 12) {
            AppDescriptionView(
                description: teamInfo.appDescription,
                categoryLine: teamInfo.categoryLine
            )

            AppDownloadCardView(appName: teamInfo.appName, boothNumber: teamInfo.boothNumber) {
                print(teamInfo.members)
                // TODO: teaminfo.appUrl 사용
            }
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
                .font(.subheadline)
                .foregroundStyle(Color.primary)

            Text(categoryLine)
                .font(.subheadline)
                .foregroundStyle(Color(.tertiaryLabel))
        }
    }
}

// 앱 다운로드 카드
struct AppDownloadCardView: View {
    let appName: String
    let boothNumber: String
    let onDownloadTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // TODO: 이미지 변경 필요
            Image(boothNumber)
                .resizable()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            Text(appName)
            Spacer()
            Button {
                onDownloadTap()
            } label: {
                Text("받기")
                    .font(.subheadline)
                    .foregroundStyle(Color.teal)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 13)
                    .background(Color.downloadBtn)
                    .clipShape(.capsule)
            }
        }
        .padding(.all, 12)
        .background(Color.quatFill)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

// 팀소개
struct TeamIntroductionView: View {
    let teamName: String
    let teamUrl: URL
    let members: [Learner]
    let isIpad: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("팀소개")
                .font(isIpad ? .title2 : .title3)
                .foregroundStyle(Color.primary)
            HStack {
                Text("팀 이름")
                    .font(isIpad ? .headline : .subheadline)
                    .foregroundStyle(Color.gray)
                Spacer()
                Text(teamName)
                    .font(isIpad ? .headline : .subheadline)
                    .foregroundStyle(Color.primary)
            }

            HStack {
                Text("팀 및 프로젝트 설명")
                    .font(isIpad ? .headline : .subheadline)
                    .foregroundStyle(Color.gray)
                Spacer()
                Link("NotionLink", destination: teamUrl)
                    .font(isIpad ? .headline : .subheadline)
                    .foregroundStyle(Color.teal)
                    .underline()
            }
            List(members) { member in
                Text("\(member.name)(\(member.id))")
                    .font(isIpad ? .body : .subheadline)
                    .listRowBackground(Color(.quaternarySystemFill))
            }
            .scaledToFit()
            .listStyle(.insetGrouped)
            .padding(.all, -16) // insetgrouped가 padding내장
            .scrollContentBackground(.hidden)
        }
        .padding(.top, 16)
    }
}

#Preview {
    NavigationStack {
        BoothDetailView(
            teamInfo: TeamInfo(
                boothNumber: "1",
                name: "샘플 팀",
                appName: "샘플앱",
                appDescription: "샘플 앱 설명 샘플 앱 설명 샘플 앱 설명 샘플 앱 설명 샘플 앱 설명 샘플 앱 설명 샘플 앱 설명샘플 앱 설명샘플 앱 설명샘플 앱 설명샘플 앱 설명샘플 앱 설명샘플 앱 설명",
                members: [],
                category: .productivity,
                downloadUrl: URL(string: "https://example.com")!,
                teamUrl: URL(string: "https://example.com")!,
                displayPoint: []
            ),
            tabSelection: .constant(.booth),
            selectedBoothForMap: .constant(nil)
        )
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
