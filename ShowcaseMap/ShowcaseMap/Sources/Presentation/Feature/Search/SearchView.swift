//
//  SearchView.swift
//  ShowcaseMap
//
//  Created by bishoe01 on 11/16/25.
//

import SwiftUI

struct SearchView: View {
    @Binding var tabSelection: TabIdentifier
    @Binding var selectedBoothForMap: TeamInfo?
    @Binding var selectedAmenityForMap: Amenity?
    @Binding var selectedFloorOrdinal: Int?

    @State private var viewModel = SearchViewModel()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(IMDFStore.self) private var imdfStore
    var onCategorySelected: ((POICategory?) -> Void)?

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: layout.LazyVStackSpacing) {
                    // 편의시설
                    if viewModel.searchText.isEmpty || !viewModel.filteredAmenities.isEmpty {
                        Text("편의 시설")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.primary)

                        VStack(alignment: .leading, spacing: layout.ListSpacing) {
                            // 검색어가 없으면 카테고리 목록, 있으면 amenity 검색 결과
                            if viewModel.searchText.isEmpty {
                                // 기존 카테고리 목록
                                ForEach(AmenityCategory.allCases) { category in
                                    Button {
                                        onCategorySelected?(category.toPOICategory)
                                    } label: {
                                        HStack(alignment: .center, spacing: 10) {
                                            Image(systemName: category.symbolName)
                                                .font(.system(.title2))
                                                .foregroundStyle(category.foregroundColor)
                                                .frame(width: 48, height: 48)
                                                .background(category.backgroundColor)
                                                .clipShape(Circle())

                                            Text(category.displayName)
                                                .font(.body)
                                                .foregroundStyle(Color.primary)

                                            Spacer()
                                        }
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                }
                            } else {
                                // Amenity 검색 결과
                                ForEach(viewModel.filteredAmenities, id: \.identifier) { amenity in
                                    if let poiCategory = POICategory.from(amenityCategory: amenity.properties.category) {
                                        Button {
                                            selectedAmenityForMap = amenity
                                            selectedFloorOrdinal = findFloorOrdinal(for: amenity)
                                            tabSelection = .map
                                        } label: {
                                            HStack(alignment: .center, spacing: 10) {
                                                Image(systemName: poiCategory.iconName)
                                                    .font(.system(.title2))
                                                    .foregroundStyle(Color.teal)
                                                    .frame(width: 48, height: 48)
                                                    .background(Color.teal.opacity(0.1))
                                                    .clipShape(Circle())

                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(amenity.properties.name?.bestLocalizedValue ?? amenity.title ?? "편의시설")
                                                        .font(.body)
                                                        .foregroundStyle(Color.primary)

                                                    Text(poiCategory.rawValue)
                                                        .font(.caption)
                                                        .foregroundStyle(Color.secondary)
                                                }

                                                Spacer() // 버튼영역 넓히기 위함
                                            }
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }

                    // 부스
                    if !viewModel.searchText.isEmpty {
                        if !viewModel.filteredTeamInfo.isEmpty {
                            Text("부스")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.primary)
                                .padding(.top, viewModel.searchText.isEmpty || viewModel.filteredAmenities.isEmpty ? 0 : 8)

                            if layout.isIPad {
                                iPadBoothGridView
                            } else {
                                iPhoneBoothListView
                            }
                        } else if viewModel.filteredAmenities.isEmpty {
                            // 검색 결과가 없을 때
                            VStack(spacing: 8) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 48))
                                    .foregroundStyle(Color.secondary)
                                Text("검색 결과가 없습니다")
                                    .font(.body)
                                    .foregroundStyle(Color.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                        }
                    }
                }
                .padding(.horizontal, layout.horizontalPadding)
                .safeAreaPadding(.bottom, 100)
            }
            .navigationTitle("검색")
            .navigationBarTitleDisplayMode(.automatic)
            .task {
                await viewModel.fetchTeamInfo()
            }
            .onAppear {
                viewModel.currentLevelAmenities = imdfStore.amenities
            }
            .onChange(of: imdfStore.amenities) { _, newAmenities in
                viewModel.currentLevelAmenities = newAmenities
            }
        }
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
    }

    @ViewBuilder
    private var iPadBoothGridView: some View {
        BoothGridView(
            teamInfoList: viewModel.filteredTeamInfo,
            isIPad: true,
            searchText: viewModel.searchText
        ) { teamInfo in
            Button {
                selectedBoothForMap = teamInfo
                selectedFloorOrdinal = teamInfo.levelId
                tabSelection = .map
            } label: {
                BoothItemView(
                    teamInfo: teamInfo,
                    isIPad: true,
                    searchText: viewModel.searchText,
                    showBoothNumber: true
                )
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var iPhoneBoothListView: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.filteredTeamInfo) { teamInfo in
                Button {
                    selectedBoothForMap = teamInfo
                    selectedFloorOrdinal = teamInfo.levelId
                    tabSelection = .map
                } label: {
                    BoothItemView(
                        teamInfo: teamInfo,
                        isIPad: false,
                        searchText: viewModel.searchText,
                        showBoothNumber: true
                    )
                }
                .buttonStyle(.plain)

                if teamInfo.id != viewModel.filteredTeamInfo.last?.id {
                    Divider()
                }
            }
        }
        .background(Color(.quaternarySystemFill))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    NavigationStack {
        SearchView(
            tabSelection: .constant(.search),
            selectedBoothForMap: .constant(nil),
            selectedAmenityForMap: .constant(nil),
            selectedFloorOrdinal: .constant(nil),
            onCategorySelected: nil
        )
    }
}

extension SearchView {
    private var layout: DeviceLayout {
        DeviceLayout(isIPad: horizontalSizeClass == .regular)
    }

    /// Amenity가 속한 층 찾기
    private func findFloorOrdinal(for amenity: Amenity) -> Int? {
        for level in imdfStore.levels {
            for unit in level.units {
                if unit.amenities.contains(where: { $0.identifier == amenity.identifier }) {
                    return level.properties.ordinal
                }
            }
        }
        return nil
    }
}

private struct DeviceLayout {
    let isIPad: Bool

    var horizontalPadding: CGFloat {
        isIPad ? 32 : 15
    }

    var ListSpacing: CGFloat {
        isIPad ? 16 : 10
    }

    var LazyVStackSpacing: CGFloat {
        isIPad ? 16 : 12
    }
}
