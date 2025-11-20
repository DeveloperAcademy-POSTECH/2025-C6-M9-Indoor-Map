//
//  ContentView.swift
//  ShowcaseMap
//
//  Created by go on 11/13/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var tabSelection: TabIdentifier = .map
    @State private var selectedCategory: POICategory? = nil
    @State private var selectedBoothForMap: TeamInfo?
    @State private var selectedAmenityForMap: Amenity?
    @State private var selectedFloorOrdinal: Int?

    var body: some View {
        TabView(selection: $tabSelection) {
            Tab(
                "부스 전체",
                systemImage: "list.bullet",
                value: .booth
            ) {
                BoothListView(
                    tabSelection: $tabSelection,
                    selectedBoothForMap: $selectedBoothForMap
                )
            }

            Tab(
                "실내 지도",
                systemImage: "map",
                value: .map
            ) {
                IndoorMapView(
                    selectedCategory: $selectedCategory,
                    selectedBooth: $selectedBoothForMap,
                    selectedAmenity: $selectedAmenityForMap,
                    selectedFloorOrdinal: $selectedFloorOrdinal
                )
            }

            Tab(
                "search",
                systemImage: "magnifyingglass",
                value: .search,
                role: .search
            ) {
                SearchView(
                    tabSelection: $tabSelection,
                    selectedBoothForMap: $selectedBoothForMap,
                    selectedAmenityForMap: $selectedAmenityForMap,
                    selectedFloorOrdinal: $selectedFloorOrdinal,
                    onCategorySelected: { category in
                        selectedCategory = category
                        tabSelection = .map
                    }
                )
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    let store = IMDFStore()
    store.loadIMDFData()

    return ContentView()
        .modelContainer(for: FavoriteTeamInfo.self, inMemory: true)
        .environment(store)
}

enum TabIdentifier: String, CaseIterable {
    case booth
    case map
    case search
}
