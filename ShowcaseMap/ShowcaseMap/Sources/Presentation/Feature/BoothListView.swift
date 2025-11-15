//
//  BoothListView.swift
//  ShowcaseMap
//
//  Created by bishoe01 on 11/15/25.
//

import SwiftData
import SwiftUI

struct BoothListView: View {
    @State private var viewModel = BoothListViewModel()
    @State private var selectedCategory: AppCategory?
    @State private var showFavorites: Bool = false
    @Query private var favoriteTeamInfos: [FavoriteTeamInfo]

    private var filteredTeamInfoList: [TeamInfo] {
        var filtered = viewModel.teamInfoList

        if showFavorites {
            let favoriteTeamInfoId = Set(favoriteTeamInfos.map { $0.teamInfoId })
            filtered = filtered.filter { favoriteTeamInfoId.contains($0.id) }
        }

        if let selectedCategory = selectedCategory {
            filtered = filtered.filter { $0.category == selectedCategory }
        }

        return filtered
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    CategoryFilterView(
                        selectedCategory: $selectedCategory,
                        showFavorites: $showFavorites
                    )

                    VStack(spacing: 0) {
                        ForEach(filteredTeamInfoList) { teamInfo in
                            NavigationLink(value: teamInfo) {
                                BoothListItemView(teamInfo: teamInfo)
                            }
                            // 경계선처리
                            if teamInfo.id != filteredTeamInfoList.last?.id {
                                Divider()
                            }
                        }
                    }
                    .background(Color(.quaternarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)
                }
                .safeAreaPadding(.bottom, 100)
            }
            .navigationTitle("부스")
            .navigationBarTitleDisplayMode(.large)
            .toolbarTitleDisplayMode(.inline)
            .navigationDestination(for: TeamInfo.self) { teamInfo in
                BoothDetailView(teamInfo: teamInfo)
            }
            .task {
                await viewModel.fetchTeamInfo()
            }
        }
    }
}

#Preview {
    BoothListView()
        .modelContainer(for: FavoriteTeamInfo.self, inMemory: true)
}

struct CategoryFilterView: View {
    @Binding var selectedCategory: AppCategory?
    @Binding var showFavorites: Bool

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    selectedCategory = nil
                    showFavorites = false
                } label: {
                    Text("전체")
                        .foregroundColor(selectedCategory == nil && !showFavorites ? Color.white : Color.primary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                }
                .background(selectedCategory == nil && !showFavorites ? Color.teal : Color(.tertiarySystemFill))
                .clipShape(Capsule())

                Button {
                    showFavorites.toggle()
                    if showFavorites {
                        selectedCategory = nil
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")

                        Text("즐겨찾기")
                    }.foregroundColor(showFavorites ? Color.white : Color.primary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                }
                .background(showFavorites ? Color.teal : Color(.tertiarySystemFill))
                .clipShape(Capsule())

                ForEach(AppCategory.allCases) { category in
                    Button {
                        selectedCategory = category
                        showFavorites = false
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "circle.fill")
                            Text(category.displayName)
                        }
                        .foregroundColor(selectedCategory == category ? Color.white : Color.primary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                    }
                    .background(selectedCategory == category ? Color.teal : Color(.tertiarySystemFill))
                    .clipShape(Capsule())
                }
            }
        }
        .padding(.leading)
        .padding(.top, 12)
    }
}

struct BoothListItemView: View {
    let teamInfo: TeamInfo

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            // TODO: 각각 앱 이름에 맞는 이미지로 변경 필요
            Image("appLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 4) {
                Text(teamInfo.appName)
                    .font(.headline)
                    .foregroundStyle(Color.primary)
                Text(teamInfo.categoryLine)
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
            }
            Spacer()
        }
        .padding(14)
    }
}
