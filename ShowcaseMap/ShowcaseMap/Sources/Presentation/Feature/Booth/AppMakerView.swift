//
//  AppMakerView.swift
//  ShowcaseMap
//
//  Created by jihanchae on 11/21/25.
//

import SwiftUI


struct AppTeamListView : View {
    
    let members: [AppTeamMember]

        var body: some View {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(members) { member in
                        ProfileComponent(member: member)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
}


struct ProfileComponent: View {
    
    let member: AppTeamMember
    
    var body: some View {
        HStack(spacing:12) {
            Image(systemName: "circle.fill")
                .resizable()
                .frame(width: 78, height: 78)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
        
            
            VStack(alignment: .leading) {
                HStack{
                    
                Text(member.name)
                    .font(.title3.weight(.bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                                  
                Spacer()
                // LinkedIn Button
                Button {
                    //openURL(member.linkedInURL)
                } label: {
                    Image(systemName: "link")
                        .imageScale(.small)
                        .foregroundColor(.blue)
                }
                        .buttonStyle(.plain)
                }
                Text(member.position)
                    .font(Font.subheadline)
                    .foregroundColor(Color.secondary)
                Text(member.description)
                    .font(Font.subheadline)
                    .foregroundColor(Color.primary)
            }
        }
        .padding(.horizontal,15)
    }
}

#Preview {
    AppTeamListView(members: AppTeamMember.allTeamMembers)
}
