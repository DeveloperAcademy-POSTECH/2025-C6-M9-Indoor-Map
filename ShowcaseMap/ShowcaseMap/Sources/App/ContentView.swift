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
                "지도뷰",
                systemImage: "map",
                value: .map
            ) {
                IndoorMapView(
                    selectedCategory: $selectedCategory,
                    selectedBooth: $selectedBoothForMap
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
                    onCategorySelected: { category in
                        selectedCategory = category
                        tabSelection = .map
                    }
                )
            }
        }.ignoresSafeArea()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: FavoriteTeamInfo.self, inMemory: true)
}


enum TabIdentifier: String, CaseIterable {
    case booth
    case map
    case search
}
