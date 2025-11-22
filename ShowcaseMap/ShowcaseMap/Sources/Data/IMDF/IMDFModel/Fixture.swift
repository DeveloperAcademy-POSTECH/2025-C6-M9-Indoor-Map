//
//  Fixture.swift
//  ShowcaseMap
//
//  Created by bishoe01 on 11/15/25.
//

import Foundation

struct Fixture: Codable, Identifiable {
    let id: String
    let type: String
    let featureType: String
    let geometry: Geometry
    let properties: Properties

    var levelId: String { properties.levelId }

    struct Geometry: Codable {
        let coordinates: [[[[Double]]]]
    }

    struct Properties: Codable {
        let levelId: String

        enum CodingKeys: String, CodingKey {
            case levelId = "level_id"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, type, geometry, properties
        case featureType = "feature_type"
    }
}

struct FixtureCollection: Codable {
    let features: [Fixture]
}
