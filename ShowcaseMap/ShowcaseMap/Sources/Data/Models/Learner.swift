//
//  Learner.swift
//  ShowcaseMap
//
//  Created by bishoe01 on 11/15/25.
//

import Foundation

struct Learner: Identifiable, Hashable, Codable {
    let id: String // 한국어로 닉네임 발음을 그냥 id로 ex) Martin -> 마틴
    let name: String
//    let role: String   // 역할군은 미정

    init(
        id: String,
        name: String,
//        role: String
    ) {
        self.id = id
        self.name = name
//        self.role = role
    }
}
