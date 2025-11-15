//
//  FavoriteTeamInfo.swift
//  ShowcaseMap
//
//  Created by bishoe01 on 11/15/25.
//

import Foundation
import SwiftData

@Model
final class FavoriteTeamInfo {
    var teamInfoId: UUID
    
    init(teamInfoId: UUID) {
        self.teamInfoId = teamInfoId
    }
}

