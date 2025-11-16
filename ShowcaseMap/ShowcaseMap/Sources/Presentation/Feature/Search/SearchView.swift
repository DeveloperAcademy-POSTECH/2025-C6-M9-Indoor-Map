//
//  SearchView.swift
//  ShowcaseMap
//
//  Created by bishoe01 on 11/16/25.
//

import SwiftUI

struct SearchView: View {
    @State private var viewModel = SearchViewModel()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: layout.LazyVStackSpacing) {
                    // 편의시설
                    if viewModel.searchText.isEmpty || !viewModel.filteredAmenities.isEmpty {
                        Text("편의 시설")
                            .font(.title3)
                            .foregroundStyle(Color.primary)

                        VStack(alignment: .leading, spacing: layout.ListSpacing) {
                            ForEach(viewModel.filteredAmenities) { category in
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
                    if !viewModel.searchText.isEmpty {
                        if !viewModel.filteredTeamInfo.isEmpty {
                            Text("부스")
                                .font(.title3)
                                .foregroundStyle(Color.primary)
                                .padding(.top, viewModel.searchText.isEmpty || viewModel.filteredAmenities.isEmpty ? 0 : 8)

                            if layout.isIPad {
                                iPadBoothGridView
                            } else {
                                iPhoneBoothListView
                            }
                        } else if viewModel.filteredAmenities.isEmpty {
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
                .padding(.horizontal, layout.horizontalPadding)
                .safeAreaPadding(.bottom, 100)
            }
            .navigationTitle("검색")
            .navigationBarTitleDisplayMode(.automatic)
            .navigationDestination(for: TeamInfo.self) { teamInfo in
                BoothDetailView(teamInfo: teamInfo)
            }
            .task {
                await viewModel.fetchTeamInfo()
            }
        }
        .searchable(text: $viewModel.searchText)
    }

    @ViewBuilder
    private var iPadBoothGridView: some View {
        let columns = Array(
            repeating: GridItem(.flexible(), spacing: 32),
            count: 2
        )

        LazyVGrid(columns: columns, spacing: 40) {
            ForEach(viewModel.filteredTeamInfo) { teamInfo in
                NavigationLink(value: teamInfo) {
                    // TODO: 지도에서 부스 클릭된 것처럼 로직 연결
                    SearchBoothItemView(teamInfo: teamInfo, searchText: viewModel.searchText, isIPad: true)
                }
            }
        }
    }

    @ViewBuilder
    private var iPhoneBoothListView: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.filteredTeamInfo) { teamInfo in
                NavigationLink(value: teamInfo) {
                    // TODO: 지도에서 부스 클릭된 것처럼 로직 연결
                    SearchBoothItemView(teamInfo: teamInfo, searchText: viewModel.searchText, isIPad: false)
                }

                if teamInfo.id != viewModel.filteredTeamInfo.last?.id {
                    Divider()
                }
            }
        }
        .background(Color(.quaternarySystemFill))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// 부스 검색결과
struct SearchBoothItemView: View {
    let teamInfo: TeamInfo
    let searchText: String
    var isIPad: Bool = false

    var body: some View {
        let style = SearchBoothItemStyle(isIPad: isIPad)

        HStack(alignment: style.alignment, spacing: style.itemSpacing) {
            Image("appLogo")
                .resizable()
                .scaledToFit()
                .frame(width: style.logoSize, height: style.logoSize)
                .clipShape(RoundedRectangle(cornerRadius: style.logoRadius))

            VStack(alignment: .leading, spacing: 4) {
                Text(teamInfo.appName)
                    .font(style.titleFont)
                    .foregroundStyle(Color.primary)

                HStack(alignment: .center, spacing: 4) {
                    Text(teamInfo.categoryLine)
                        .foregroundStyle(style.categoryLineColor)

                    Image(systemName: "circle.fill")
                        .resizable()
                        .frame(width: 2, height: 2)
                        .foregroundStyle(style.categoryLineColor)

                    Text("부스 \(teamInfo.boothNumber)")
                        .foregroundStyle(isIPad ? Color.primary.opacity(0.6) : style.categoryLineColor)
                }
                .font(.subheadline)
                .multilineTextAlignment(.leading)

                if isIPad {
                    Spacer()

                    Text(teamInfo.appDescription)
                        .font(.callout)
                        .foregroundStyle(Color.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }

            Spacer()
        }
        .padding(style.contentPadding)
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
}

extension SearchView {
    private var layout: DeviceLayout {
        DeviceLayout(isIPad: horizontalSizeClass == .regular)
    }
}

private struct DeviceLayout {
    let isIPad: Bool

    var horizontalPadding: CGFloat {
        isIPad ? 32 : 15
    }

    var ListSpacing: CGFloat {
        isIPad ? 16 : 8
    }

    var LazyVStackSpacing: CGFloat {
        isIPad ? 16 : 12
    }
}

private struct SearchBoothItemStyle {
    let isIPad: Bool

    var logoSize: CGFloat {
        isIPad ? 120 : 50
    }

    var logoRadius: CGFloat {
        isIPad ? 38 : 16
    }

    var itemSpacing: CGFloat {
        isIPad ? 16 : 8
    }

    var alignment: VerticalAlignment {
        isIPad ? .top : .center
    }

    var contentPadding: CGFloat {
        isIPad ? 0 : 14
    }

    var titleFont: Font {
        isIPad ? .title2 : .headline
    }

    var categoryLineColor: Color {
        isIPad ? Color.teal : Color.secondary
    }
}
