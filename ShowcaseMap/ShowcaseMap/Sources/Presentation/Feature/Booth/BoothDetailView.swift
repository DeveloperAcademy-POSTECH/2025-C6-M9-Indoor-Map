//
//  BoothDetailView.swift
//  ShowcaseMap
//
//  Created by bishoe01 on 11/15/25.
//

import SwiftData
import SwiftUI

struct BoothDetailView: View {
    let teamInfo: TeamInfo
    @Environment(\.modelContext) private var modelContext
    @Query private var favoriteTeamInfos: [FavoriteTeamInfo]

    private var isFavorite: Bool {
        favoriteTeamInfos.contains { $0.teamInfoId == teamInfo.id }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 12) {
                BoothHeaderView(
                    name: teamInfo.name,
                    boothNumber: teamInfo.boothNumber
                )

                VStack(alignment: .leading, spacing: 12) {
                    AppDescriptionView(
                        description: teamInfo.appDescription,
                        categoryLine: teamInfo.categoryLine
                    )

                    AppDownloadCardView(appName: teamInfo.appName) {
                        print(teamInfo.members)
                        // TODO: teaminfo.appUrl 사용
                    }

                    TeamIntroductionView(
                        teamName: teamInfo.name,
                        teamUrl: teamInfo.teamUrl,
                        members: teamInfo.members
                    )

                    // 지도
                }
            }
        }
        .padding(.horizontal, 15)
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
}

// 부스 정보 헤더
private struct BoothHeaderView: View {
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
private struct AppDescriptionView: View {
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
private struct AppDownloadCardView: View {
    let appName: String
    let onDownloadTap: () -> Void

    var body: some View {
        HStack {
            HStack(spacing: 12) {
                // TODO: 이미지 변경 필요
                Image("appLogo")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                Text(appName)
            }
            Spacer()
            Button {
                onDownloadTap()
            } label: {
                Text("받기")
                    .font(.subheadline)
                    .foregroundStyle(Color.teal)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 13)
                    .background(.tertiary.opacity(0.24))
                    .clipShape(.capsule)
            }
        }
    }
}

// 팀소개
private struct TeamIntroductionView: View {
    let teamName: String
    let teamUrl: URL
    let members: [Learner]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("팀소개")
                .font(.title3)
                .foregroundStyle(Color.primary)
            HStack {
                Text("팀 이름")
                    .font(.subheadline)
                    .foregroundStyle(Color.gray)
                Spacer()
                Text(teamName)
                    .font(.subheadline)
                    .foregroundStyle(Color.primary)
            }

            HStack {
                Text("팀 및 프로젝트 설명")
                    .font(.subheadline)
                    .foregroundStyle(Color.gray)
                Spacer()
                Link("NotionLink", destination: teamUrl).font(.subheadline)
                    .foregroundStyle(Color.teal)
                    .underline()
            }
            List(members) { member in
                Text("\(member.name)(\(member.id))")
                    .font(.subheadline)
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
                appDescription: "샘플 앱 설명",
                members: [],
                category: .productivity,
                downloadUrl: URL(string: "https://example.com")!,
                teamUrl: URL(string: "https://example.com")!
            )
        )
    }
    .modelContainer(for: FavoriteTeamInfo.self, inMemory: true)
}
