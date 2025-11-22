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

    init(id: String, name: String, position: String, description: String, linkedInURL: URL) {
        self.id = id
        self.name = name
        self.position = position
        self.description = description
        self.linkedInURL = linkedInURL
    }
}

extension AppTeamMember {
    static let tntMembers: [AppTeamMember] = [
        AppTeamMember(id: "Go", name: "고재현 (GO)", position: "Product Owner", description: "치열하게 설계하고 집요하게 검증하며 앞으로만 갑니다.", linkedInURL: URL(string: "...")!),
        AppTeamMember(id: "Elena", name: "김지윤 (Elena)", position: "Product Designer", description: "‘사람'을 위한 프로덕트를 디자인합니다.", linkedInURL: URL(string: "https://www.linkedin.com/in/jiyoon-kim-565951249/")!),
        AppTeamMember(id: "Air", name: "양시준 (Air)", position: "iOS Developer", description: "장인의 마음가짐으로 소프트웨어를 다듬어 가는 엔지니어", linkedInURL: URL(string: "https://www.linkedin.com/in/yangsijun/")!),
        AppTeamMember(id: "Finn", name: "정종문 (Finn)", position: "iOS Developer", description: "소통이 잘되는 개발자가 되기 위해 노력합니다.", linkedInURL: URL(string: "https://www.linkedin.com/in/jongmun-j-366673277/")!),
        AppTeamMember(id: "Dean", name: "정송헌 (Dean)", position: "iOS Developer", description: "테크 멘토가 되기 위해 목적과 근거를 가진 개발을 합니다", linkedInURL: URL(string: "https://www.linkedin.com/in/%EC%86%A1%ED%97%8C-%EC%A0%95-04a44b331/")!),
        AppTeamMember(id: "Martin", name: "채지한 (Martin)", position: "Domain Expert", description: "더 나은 세상을 위해 본질을 끊임없이 탐구합니다", linkedInURL: URL(string: "https://www.linkedin.com/in/jihan-chae-a893a4259/")!),
    ]
}
