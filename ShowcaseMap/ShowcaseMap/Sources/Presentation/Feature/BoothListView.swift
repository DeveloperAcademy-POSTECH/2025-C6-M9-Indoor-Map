//
//  BoothListView.swift
//  ShowcaseMap
//
//  Created by bishoe01 on 11/15/25.
//

import SwiftUI

struct BoothListView: View {
    @State private var viewModel = BoothListViewModel()
    @State private var selectedCategory: AppCategory?

    private var filteredTeamInfoList: [TeamInfo] {
        if let selectedCategory = selectedCategory {
            return viewModel.teamInfoList.filter { $0.category == selectedCategory }
        } else {
            return viewModel.teamInfoList
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    CategoryFilterView(selectedCategory: $selectedCategory)

                    VStack(spacing: 0) {
                        ForEach(filteredTeamInfoList) { teamInfo in
                            NavigationLink(value: teamInfo) {
                                BoothListItemView(teamInfo: teamInfo)
                            }
                            // 경계선처리
                            if teamInfo.id != filteredTeamInfoList.last?.id {
                                Divider()
                            }
                        }
                    }
                    .background(Color(.quaternarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)
                }
                .safeAreaPadding(.bottom, 100)
            }
            .navigationTitle("부스")
            .navigationBarTitleDisplayMode(.large)
            .toolbarTitleDisplayMode(.inline)
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

struct CategoryFilterView: View {
    @Binding var selectedCategory: AppCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    selectedCategory = nil
                } label: {
                    Text("전체")
                        .foregroundColor(selectedCategory == nil ? Color.white : Color.primary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                }
                .background(selectedCategory == nil ? Color.teal : Color(.tertiarySystemFill))
                .clipShape(Capsule())

                ForEach(AppCategory.allCases) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        Text(category.displayName)
                            .foregroundColor(selectedCategory == category ? Color.white : Color.primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                    }
                    .background(selectedCategory == category ? Color.teal : Color(.tertiarySystemFill))
                    .clipShape(Capsule())
                }
            }
        }
        .padding(.leading)
        .padding(.top, 12)
    }
}

struct BoothListItemView: View {
    let teamInfo: TeamInfo

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(teamInfo.appName)
                    .font(.headline)
                    .foregroundStyle(Color.primary)
                Text(teamInfo.categoryLine)
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
            }
            Spacer()
        }
        .padding(14)
    }
}
