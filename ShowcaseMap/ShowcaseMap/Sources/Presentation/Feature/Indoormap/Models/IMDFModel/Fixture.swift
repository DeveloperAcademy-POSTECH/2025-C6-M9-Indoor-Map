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

    struct Geometry: Codable {
        let coordinates: [[[[Double]]]]
    }

    enum CodingKeys: String, CodingKey {
        case id, type, geometry
        case featureType = "feature_type"
    }
}

struct FixtureCollection: Codable {
    let features: [Fixture]
}
