//
//  BoothListView.swift
//  ShowcaseMap
//
//  Created by bishoe01 on 11/15/25.
//

import SwiftData
import SwiftUI

struct BoothListView: View {
    @Binding var tabSelection: TabIdentifier
    @Binding var selectedBoothForMap: TeamInfo?
    @Binding var selectedFloorOrdinal: Int?

    @State private var viewModel = BoothListViewModel()
    @State private var selectedCategory: AppCategory?
    @State private var showFavorites: Bool = false
    @Query private var favoriteTeamInfos: [FavoriteTeamInfo]
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

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
                if !layout.isIPad {
                    HStack {
                        Text("부스")
                            .font(.system(size: 28, weight: .bold))
                        Spacer()
                        NavigationLink(value: AppTeamMemberNavigation()) {
                            HStack {
                                Image(systemName: "person.2.fill")
                                    .font(.caption2)
                                Text("만든 사람들")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundStyle(Color(.secondaryLabel))
                        }.buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 12)
                    .padding(.horizontal, layout.horizontalPadding)
                }

                VStack(spacing: layout.categorySpacing) {
                    CategoryFilterView(
                        selectedCategory: $selectedCategory,
                        showFavorites: $showFavorites
                    )

                    Group {
                        if layout.isIPad {
                            iPadGridView
                        } else {
                            iPhoneListView
                        }
                    }
                    .padding(.horizontal, layout.horizontalPadding)
                }
                .safeAreaPadding(.bottom, 100)
            }
            .toolbar {
                if layout.isIPad {
                    if #available(iOS 26.0, *) {
                        ToolbarItemGroup(placement: .topBarTrailing) {
                            NavigationLink(value: AppTeamMemberNavigation()) {
                                HStack {
                                    Image(systemName: "person.2.fill")
                                        .font(.caption2)
                                    Text("만든 사람들")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                            }.buttonStyle(.plain)
                                .padding(.trailing, 32)
                        }
                        .sharedBackgroundVisibility(.hidden)
                    } else {
                        ToolbarItem(placement: .topBarTrailing) {
                            NavigationLink(value: AppTeamMemberNavigation()) {
                                HStack {
                                    Image(systemName: "person.2.fill")
                                        .font(.caption2)
                                    Text("만든 사람들")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                            }.buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationDestination(for: TeamInfo.self) { teamInfo in
                BoothDetailView(
                    teamInfo: teamInfo,
                    tabSelection: $tabSelection,
                    selectedBoothForMap: $selectedBoothForMap,
                    selectedFloorOrdinal: $selectedFloorOrdinal
                )
            }
            .navigationDestination(for: AppTeamMemberNavigation.self) { _ in
                AppTeamListView(members: AppTeamMember.tntMembers)
            }
            .task {
                await viewModel.fetchTeamInfo()
            }
        }
    }

    @ViewBuilder
    private var iPadGridView: some View {
        BoothGridView(teamInfoList: filteredTeamInfoList, isIPad: true) { teamInfo in
            NavigationLink(value: teamInfo) {
                BoothItemView(teamInfo: teamInfo, isIPad: true)
            }
        }
    }

    @ViewBuilder
    private var iPhoneListView: some View {
        VStack(spacing: 0) {
            ForEach(filteredTeamInfoList) { teamInfo in
                NavigationLink(value: teamInfo) {
                    BoothItemView(teamInfo: teamInfo, isIPad: false)
                }
                if teamInfo.id != filteredTeamInfoList.last?.id {
                    Divider()
                }
            }
        }
        .background(Color(.quaternarySystemFill))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct CategoryFilterView: View {
    @Binding var selectedCategory: AppCategory?
    @Binding var showFavorites: Bool
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var layout: DeviceLayout {
        DeviceLayout(isIPad: horizontalSizeClass == .regular)
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterButton(
                    isSelected: selectedCategory == nil && !showFavorites
                ) {
                    selectedCategory = nil
                    showFavorites = false
                } label: {
                    Text("전체")
                }

                FilterButton(
                    isSelected: showFavorites
                ) {
                    showFavorites.toggle()
                    if showFavorites {
                        selectedCategory = nil
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                        Text("즐겨찾기")
                    }
                }

                ForEach(AppCategory.allCases) { category in
                    FilterButton(
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                        showFavorites = false
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: category.systemImageName)
                            Text(category.displayName)
                        }
                    }
                }
            }
            .padding(.horizontal, layout.horizontalPadding)
        }
    }
}

extension BoothListView {
    private var layout: DeviceLayout {
        DeviceLayout(isIPad: horizontalSizeClass == .regular)
    }
}

private struct DeviceLayout {
    let isIPad: Bool

    var categorySpacing: CGFloat {
        isIPad ? 52 : 18
    }

    var horizontalPadding: CGFloat {
        isIPad ? 32 : 16
    }
}

// Components

struct FilterButton<Label: View>: View {
    let isSelected: Bool
    let action: () -> Void
    @ViewBuilder let label: () -> Label

    var body: some View {
        Button(action: action) {
            label()
                .foregroundColor(isSelected ? Color.white : Color.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
        }
        .background(isSelected ? Color.teal : Color(.tertiarySystemFill))
        .clipShape(Capsule())
    }
}

struct AppTeamMemberNavigation: Hashable {}

// #Preview {
//    BoothListView(
//        tabSelection: .constant(.booth),
//        selectedBoothForMap: .constant(nil),
//        selectedFloorOrdinal: .constant(nil)
//    )
//    .modelContainer(for: FavoriteTeamInfo.self, inMemory: true)
// }
