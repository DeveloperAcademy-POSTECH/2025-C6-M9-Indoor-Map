//
//  AppMakerView.swift
//  ShowcaseMap
//
//  Created by jihanchae on 11/21/25.
//

import SwiftUI

struct AppTeamListView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    let members: [AppTeamMember]
    private var isIpad: Bool {
        horizontalSizeClass == .regular
    }

    var body: some View {
        Group {
            if isIpad {
                appTeamListIpadView
            } else {
                ScrollView {
                    appTeamListIphoneView
                }
            }
        }
        .navigationTitle(isIpad ? "" : "만든 사람들")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder var appTeamListIphoneView: some View {
        VStack(alignment: .leading, spacing: 24) {
            ForEach(members) { member in
                ProfileIponeComponent(member: member)
            }
        }
        .padding(.all, 15)
    }

    @ViewBuilder var appTeamListIpadView: some View {
        GeometryReader { geo in
            let imageWidth = geo.size.width / 2 - 95

            HStack(alignment: .top, spacing: 45) {
                Image("TNT")
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageWidth)
                    .clipped()

                let columns = [
                    GridItem(.flexible(), spacing: 30),
                    GridItem(.flexible(), spacing: 0)
                ]
                VStack(alignment: .leading, spacing: 27) {
                    LazyVGrid(columns: columns, spacing: 28) {
                        ForEach(Array(members.enumerated()), id: \.element.id) { index, member in
                            HStack(alignment: .top) {
                                if index % 2 == 0 {
                                    ProfileIpadComponent(member: member)

                                    Spacer()
                                } else {
                                    Spacer()
                                    ProfileIpadComponent(member: member)
                                }
                            }.frame(maxHeight: .infinity, alignment: .top)
                        }
                    }
                    HStack {
                        Text("Team Website")
                            .fontWeight(.semibold)

                        Link(destination: URL(string: "https://www.tntlab.xyz/")!) {
                            Text("https://www.tntlab.xyz/")
                                .tint(Color.primary)
                                .underline()
                        }
                    }.font(.callout)
                        .foregroundStyle(Color.primary)
                }
            }
        }
        .padding(.horizontal, 45)
        .padding(.vertical, 15)
    }
}

struct ProfileIpadComponent: View {
    let member: AppTeamMember

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(member.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Spacer()

                Link(destination: member.linkedInURL) {
                    Image("linkedIn")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(member.position)
                    .font(.callout)
                    .foregroundColor(Color(.secondaryLabel))
                Text(member.description)
                    .font(.subheadline)
                    .fontWeight(.regular)
                    .lineLimit(nil)
                    .foregroundColor(Color.primary)
            }
        }.frame(maxWidth: .infinity)
    }
}

struct ProfileIponeComponent: View {
    let member: AppTeamMember

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(member.id)
                .resizable()
                .frame(width: 78, height: 78)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(member.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    Link(destination: member.linkedInURL) {
                        Image("linkedIn")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
                Text(member.position)
                    .font(.subheadline)
                    .foregroundColor(Color(.secondaryLabel))
                Spacer()
                Text(member.description)
                    .font(.footnote)
                    .foregroundColor(Color.primary)
            }.padding(.vertical, 4)
        }
    }
}

#Preview {
    NavigationStack {
        AppTeamListView(members: AppTeamMember.tntMembers)
            .navigationTitle("만든 사람들")
            .navigationBarTitleDisplayMode(.inline)
    }
}
