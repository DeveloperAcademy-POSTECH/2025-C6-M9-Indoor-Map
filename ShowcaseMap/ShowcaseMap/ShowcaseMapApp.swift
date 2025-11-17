//
//  ShowcaseMapApp.swift
//  ShowcaseMap
//
//  Created by go on 11/13/25.
//

import SwiftData
import SwiftUI

@main
struct ShowcaseMapApp: App {
    @State private var imdfStore = IMDFStore()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FavoriteTeamInfo.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(imdfStore)
                .onAppear {
                    imdfStore.loadIMDFData()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
