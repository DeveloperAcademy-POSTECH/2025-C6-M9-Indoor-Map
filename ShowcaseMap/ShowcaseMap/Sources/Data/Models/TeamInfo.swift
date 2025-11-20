//
//  TeamInfo.swift
//  ShowcaseMap
//
//  Created by bishoe01 on 11/15/25.
//

import CoreLocation
import Foundation

struct TeamInfo: Identifiable, Hashable, Codable {
    let id: UUID

    let boothNumber: String
    let name: String
    let appName: String
    let appDescription: String
    let members: [Learner]
    let category: AppCategory
    let downloadUrl: URL
    let teamUrl: URL
    private let display_point: [Double]
    let levelId: Int
    var displayPoint: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: display_point[1], longitude: display_point[0])
    }

    init(
        id: UUID = UUID(),
        levelId: Int,
        boothNumber: String,
        name: String,
        appName: String,
        appDescription: String,
        members: [Learner],
        category: AppCategory,
        downloadUrl: URL,
        teamUrl: URL,
        displayPoint: [Double],

    ) {
        self.id = id
        self.levelId = levelId
        self.boothNumber = boothNumber
        self.name = name
        self.appName = appName
        self.appDescription = appDescription
        self.members = members
        self.category = category
        self.downloadUrl = downloadUrl
        self.teamUrl = teamUrl
        self.display_point = displayPoint
    }
}

extension TeamInfo {
    var categoryLine: String {
        "#\(category.displayName)"
    }

    var teamMemberString: String {
        return members
            .map { "\($0.name)(\($0.id))" }
            .joined(separator: ", ")
    }
}
