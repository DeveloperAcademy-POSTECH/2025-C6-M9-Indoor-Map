//
//  TeamInfo.swift
//  ShowcaseMap
//
//  Created by bishoe01 on 11/15/25.
//

import Foundation

struct TeamInfo: Identifiable, Hashable, Codable {
    let id: UUID
    let boothNumber: Int
    let name: String
    let appName: String
    let appDescription: String
    let members: [Learner]
    let category: AppCategory
    let downloadUrl: URL
    let teamUrl: URL

    init(
        id: UUID = UUID(),
        boothNumber: Int,
        name: String,
        appName: String,
        appDescription: String,
        members: [Learner],
        category: AppCategory,
        downloadUrl: URL,
        teamUrl: URL
    ) {
        self.id = id
        self.boothNumber = boothNumber
        self.name = name
        self.appName = appName
        self.appDescription = appDescription
        self.members = members
        self.category = category
        self.downloadUrl = downloadUrl
        self.teamUrl = teamUrl
    }
}

extension TeamInfo {
    var categoryLine: String {
        "#\(category.displayName) \(category)"
    }
}
