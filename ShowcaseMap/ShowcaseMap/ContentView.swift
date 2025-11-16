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

    var body: some View {
        TabView(selection: $tabSelection) {
            Tab(
                "부스 전체",
                systemImage: "list.bullet",
                value: .booth
            ) {
                BoothListView()
            }

            Tab(
                "지도뷰",
                systemImage: "map",
                value: .map
            ) {
                BoothListView()
            }

            Tab(
                "search",
                systemImage: "magnifyingglass",
                value: .search,
                role: .search
            ) {
                SearchView()
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
