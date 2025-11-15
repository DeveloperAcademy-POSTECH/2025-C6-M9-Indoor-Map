//
//  BoothListView.swift
//  ShowcaseMap
//
//  Created by bishoe01 on 11/15/25.
//

import SwiftUI

struct BoothListView: View {
    @State private var viewModel = BoothListViewModel()

    var body: some View {
        NavigationStack {
            List(viewModel.teamInfoList) { teamInfo in
                NavigationLink(value: teamInfo) {
                    Text(teamInfo.name)
                }
            }
            .navigationTitle("부스 목록")
            .navigationDestination(for: TeamInfo.self) { teamInfo in
                BoothDetailView(teamInfo: teamInfo)
            }
            .task {
                await viewModel.fetchTeamInfo()
            }
        }
    }
}

#Preview {
    BoothListView()
}
