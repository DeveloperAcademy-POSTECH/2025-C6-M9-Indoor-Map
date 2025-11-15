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

    @State private var selectedIndex: Int = 0

    var body: some View {
        TabView(selection: $selectedIndex) {
            Tab(
                "부스",
                systemImage: "list.bullet",
                value: 0
            ) {
                BoothListView()
            }

            Tab(
                "지도뷰",
                systemImage: "map",
                value: 1
            ) {
                Text("지도뷰")
            }
            
            Tab(
                "search"
                ,systemImage: "magnifyingglass",
                value: 2,
                role:.search
            ){
                Text("search")
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
