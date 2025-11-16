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
                VStack(spacing: layout.categorySpacing) {
                    CategoryFilterView(
                        selectedCategory: $selectedCategory,
                        showFavorites: $showFavorites
                    )

                    if layout.isIPad {
                        iPadGridView
                    } else {
                        iPhoneListView
                    }
                }
                .padding(.horizontal, layout.horizontalPadding)
                .safeAreaPadding(.bottom, 100)
            }
            .navigationTitle(layout.isIPad ? "" : "부스")
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

    @ViewBuilder
    private var iPadGridView: some View {
        let columns = Array(
            repeating: GridItem(.flexible(), spacing: 32),
            count: 2
        )

        LazyVGrid(columns: columns, spacing: 40) {
            ForEach(filteredTeamInfoList) { teamInfo in
                NavigationLink(value: teamInfo) {
                    BoothListItemView(teamInfo: teamInfo, isIPad: true)
                }
            }
        }
    }

    @ViewBuilder
    private var iPhoneListView: some View {
        VStack(spacing: 0) {
            ForEach(filteredTeamInfoList) { teamInfo in
                NavigationLink(value: teamInfo) {
                    BoothListItemView(teamInfo: teamInfo, isIPad: false)
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

#Preview {
    BoothListView()
        .modelContainer(for: FavoriteTeamInfo.self, inMemory: true)
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
                            Image(systemName: "circle.fill")
                            Text(category.displayName)
                        }
                    }
                }
            }
        }
        .padding(.top, 12)
        .padding(.trailing, -layout.horizontalPadding)
    }
}

struct BoothListItemView: View {
    let teamInfo: TeamInfo
    var isIPad: Bool = false

    var body: some View {
        let style = BoothItemStyle(isIPad: isIPad)

        HStack(alignment: style.alignment, spacing: style.itemSpacing) {
            // TODO: 각각 앱 이름에 맞는 이미지로 변경 필요
            Image("appLogo")
                .resizable()
                .scaledToFit()
                .frame(width: style.logoSize, height: style.logoSize)
                .clipShape(RoundedRectangle(cornerRadius: style.logoRadius))

            VStack(alignment: .leading, spacing: 4) {
                Text(teamInfo.appName)
                    .font(style.titleFont)
                    .foregroundStyle(Color.primary)
                Text(teamInfo.categoryLine)
                    .font(.subheadline)
                    .foregroundStyle(style.categoryLineColor)
                    .multilineTextAlignment(.leading)

                if isIPad {
                    Spacer()
                    Text(teamInfo.appDescription)
                        .font(.callout)
                        .foregroundStyle(Color.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
            Spacer()
        }
        .padding(style.contentPadding)
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
        isIPad ? 32 : 15
    }
}

private struct BoothItemStyle {
    let isIPad: Bool

    var logoSize: CGFloat {
        isIPad ? 120 : 50
    }

    var logoRadius: CGFloat {
        isIPad ? 38 : 16
    }

    var itemSpacing: CGFloat {
        isIPad ? 16 : 8
    }

    var alignment: VerticalAlignment {
        isIPad ? .top : .center
    }

    var contentPadding: CGFloat {
        isIPad ? 0 : 14
    }

    var titleFont: Font {
        isIPad ? .title2 : .headline
    }

    var categoryLineColor: Color {
        isIPad ? Color.teal : Color.secondary
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
