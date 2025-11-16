//
//  SearchView.swift
//  ShowcaseMap
//
//  Created by bishoe01 on 11/16/25.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText: String = ""
    @State private var viewModel = BoothListViewModel()
    
    // 부스검색
    private var filteredTeamInfo: [TeamInfo] {
        guard !searchText.isEmpty else { return [] }
        
        let searchLowercased = searchText.lowercased()
        
        return viewModel.teamInfoList.filter { teamInfo in
            // 앱 이름
            teamInfo.appName.lowercased().contains(searchLowercased) ||
                // 부스번호
                String(teamInfo.boothNumber).contains(searchText) ||
                // 멤버이름(본명,영어이름 둘다)
                teamInfo.members.contains { member in
                    member.name.lowercased().contains(searchLowercased) ||
                        member.id.lowercased().contains(searchLowercased)
                }
        }
    }
    
    // 편의시설 검색
    private var filteredAmenities: [AmenityCategory] {
        guard !searchText.isEmpty else { return AmenityCategory.allCases }
        
        let searchLowercased = searchText.lowercased()
        return AmenityCategory.allCases.filter { category in
            category.displayName.lowercased().contains(searchLowercased)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    // 편의시설
                    if searchText.isEmpty || !filteredAmenities.isEmpty {
                        if !searchText.isEmpty {
                            Text("편의 시설")
                                .font(.title3)
                                .foregroundStyle(Color.primary)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(filteredAmenities) { category in
                                Button {
                                    // TODO: 눌렀을때 이동하는 로직
                                } label: {
                                    HStack(alignment: .center, spacing: 10) {
                                        Image(systemName: category.symbolName)
                                            .font(.system(.title2))
                                            .foregroundStyle(category.foregroundColor)
                                            .frame(width: 48, height: 48)
                                            .background(category.backgroundColor)
                                            .clipShape(Circle())
                                        
                                        Text(category.displayName)
                                            .font(.body)
                                            .foregroundStyle(Color.primary)
                                        
                                        Spacer() // 버튼영역 넓히기 위함
                                    }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    // 부스
                    if !searchText.isEmpty {
                        if !filteredTeamInfo.isEmpty {
                            Text("부스")
                                .font(.title3)
                                .foregroundStyle(Color.primary)
                                .padding(.top, searchText.isEmpty || filteredAmenities.isEmpty ? 0 : 8)
                            
                            VStack(spacing: 0) {
                                ForEach(filteredTeamInfo) { teamInfo in
                                    NavigationLink(value: teamInfo) {
                                        // TODO: 지도에서 부스 클릭된 것처럼 로직 연결
                                        SearchBoothItemView(teamInfo: teamInfo, searchText: searchText)
                                    }
                                    
                                    if teamInfo.id != filteredTeamInfo.last?.id {
                                        Divider()
                                    }
                                }
                            }
                            .background(Color(.quaternarySystemFill))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        } else if filteredAmenities.isEmpty {
                            // 검색 결과가 없을 때
                            VStack(spacing: 8) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 48))
                                    .foregroundStyle(Color.secondary)
                                Text("검색 결과가 없습니다")
                                    .font(.body)
                                    .foregroundStyle(Color.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .safeAreaPadding(.bottom, 100)
            }
            .navigationTitle("검색")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: TeamInfo.self) { teamInfo in
                BoothDetailView(teamInfo: teamInfo)
            }
            .task {
                await viewModel.fetchTeamInfo()
            }
        }
        .searchable(text: $searchText, prompt: "부스, 앱 이름, 멤버 이름으로 검색")
    }
}

// 부스 검색결과(임시 뷰 - 추후 디자인에 맞게 수정예정)
struct SearchBoothItemView: View {
    let teamInfo: TeamInfo
    let searchText: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image("appLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(teamInfo.appName)
                    .font(.headline)
                    .foregroundStyle(Color.primary)
                
                HStack(spacing: 4) {
                    Text(teamInfo.categoryLine)
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                    
                    Text("· 부스 \(teamInfo.boothNumber)")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                }
            }
            
            Spacer()
        }
        .padding(14)
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
}
