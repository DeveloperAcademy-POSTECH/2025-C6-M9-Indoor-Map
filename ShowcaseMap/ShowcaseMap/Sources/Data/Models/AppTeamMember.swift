//
//  TeamProfile.swift
//  ShowcaseMap
//
//  Created by jihanchae on 11/21/25.
//

import Foundation

struct AppTeamMember: Identifiable, Hashable {
    // The 'id' property is now the member's name (a String).
    // This removes the need for the bulky UUID.
    let id: String
    
    // Original properties, but 'id' is initialized from 'name'.
    let name: String
    let position: String
    let description: String
    let linkedInURL: URL
    
    // Custom initializer to set 'id' = 'name'
    init(name: String, position: String, description: String, linkedInURL: URL) {
        self.id = name
        self.name = name
        self.position = position
        self.description = description
        self.linkedInURL = linkedInURL
    }
}

extension AppTeamMember {
    static let allTeamMembers: [AppTeamMember] = [
        // Member 1
        AppTeamMember(name: "채지한(Martin)", position: "iOS Developer", description: "...", linkedInURL: URL(string: "...")!),
        // Member 2
        AppTeamMember(name: "김민아(Mina)", position: "Product Owner", description: "...", linkedInURL: URL(string: "...")!),
        // ... all 6 members
    ]
}
