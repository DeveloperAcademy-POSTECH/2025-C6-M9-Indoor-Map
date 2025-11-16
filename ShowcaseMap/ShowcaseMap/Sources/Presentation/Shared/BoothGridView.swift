//
//  BoothGridView.swift
//  ShowcaseMap
//
//  Created by bishoe01 on 11/16/25.
//

import SwiftUI

struct BoothGridView<Content: View>: View {
    let teamInfoList: [TeamInfo]
    let isIPad: Bool
    var searchText: String? = nil
    @ViewBuilder let content: (TeamInfo) -> Content

    private var columns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: 32),
            count: 2
        )
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 40) {
            ForEach(teamInfoList) { teamInfo in
                content(teamInfo)
            }
        }
    }
}

// 부스 아이템 뷰 (그리드 안에 들어가는)
struct BoothItemView: View {
    let teamInfo: TeamInfo
    var isIPad: Bool = false
    var searchText: String? = nil
    var showBoothNumber: Bool = false

    var body: some View {
        let style = BoothItemStyle(isIPad: isIPad)

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

                    if showBoothNumber {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .frame(width: 2, height: 2)
                            .foregroundStyle(style.categoryLineColor)

                        Text("부스 \(teamInfo.boothNumber)")
                            .foregroundStyle(isIPad ? Color.primary.opacity(0.6) : style.categoryLineColor)
                    }
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
        .contentShape(Rectangle())
    }
}

private struct BoothItemStyle {
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
