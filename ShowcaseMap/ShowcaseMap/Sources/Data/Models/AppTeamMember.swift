//
//  TeamProfile.swift
//  ShowcaseMap
//
//  Created by jihanchae on 11/21/25.
//

import Foundation

struct AppTeamMember: Identifiable, Hashable {
    let id: String
    let name: String
    let position: String
    let description: String
    let linkedInURL: URL

    init(name: String, position: String, description: String, linkedInURL: URL) {
        self.id = name
        self.name = name
        self.position = position
        self.description = description
        self.linkedInURL = linkedInURL
    }
}

extension AppTeamMember {
    static let tntMembers: [AppTeamMember] = [
        // Member 1
        AppTeamMember(name: "고재현 (GO)", position: "Product Owner", description: "치열하게 설계하고 집요하게 검증하며 앞으로만 갑니다.", linkedInURL: URL(string: "...")!),
        // Member 2
        AppTeamMember(name: "김지윤 (Elena)", position: "Product Designer", description: "‘사람'을 위한 프로덕트를 디자인합니다.", linkedInURL: URL(string: "...")!),
        // Member 3
        AppTeamMember(name: "양시준 (Air)", position: "iOS Developer", description: "‘사람'을 위한 프로덕트를 디자인합니다.", linkedInURL: URL(string: "...")!),
        // Member 4
        AppTeamMember(name: "정종문 (Finn)", position: "iOS Developer", description: "‘사람'을 위한 프로덕트를 디자인합니다.", linkedInURL: URL(string: "...")!),
        // Member 5
        AppTeamMember(name: "정송헌 (Dean)", position: "iOS Developer", description: "‘사람'을 위한 프로덕트를 디자인합니다.", linkedInURL: URL(string: "...")!),
        // Member 6
        AppTeamMember(name: "채지한 (Martin)", position: "Domain Expert", description: "‘사람'을 위한 프로덕트를 디자인합니다.", linkedInURL: URL(string: "...")!),
    ]
}
