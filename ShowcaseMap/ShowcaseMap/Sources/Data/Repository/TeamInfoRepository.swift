//
//  TeamInfoRepository.swift
//  ShowcaseMap
//
//  Created by bishoe01 on 11/15/25.
//

import Foundation

protocol TeamInfoRepository {
    func fetchTeamInfo() async throws -> [TeamInfo]
}

struct MockTeamRepository: TeamInfoRepository {
    private let fileName: String

    init(fileName: String = "teaminfo") {
        self.fileName = fileName
    }

    func fetchTeamInfo() async throws -> [TeamInfo] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            throw RepositoryError.fileNotFound
        }

        let data = try Data(contentsOf: url)

        let decoder = JSONDecoder()

        return try decoder.decode([TeamInfo].self, from: data)
    }
}

enum RepositoryError: Error {
    case fileNotFound
}
