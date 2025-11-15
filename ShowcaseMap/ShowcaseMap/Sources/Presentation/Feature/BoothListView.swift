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
        NavigationView {
            Group {
                List(viewModel.teamInfoList) { teamInfo in
                    Text(teamInfo.name)
                }
            }
            .navigationTitle("부스 목록")
            .task {
                await viewModel.fetchTeamInfo()
            }
        }
    }
}

#Preview {
    BoothListView()
}
