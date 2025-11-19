//
//  CategoryGridView.swift
//  ShowcaseMap
//
//  Created by bishoe01 on 11/19/25.
//

import SwiftUI

struct CategoryGridView: View {
    @Binding var selectedCategory: POICategory?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var sortedCategories: [AmenityCategory] {
        // 엘베 계단 제거
        let visibleCategories = AmenityCategory.allCases.filter { $0 != .elevator && $0 != .stairs }
        return visibleCategories
    }

    private var layout: DeviceLayout {
        DeviceLayout(isIPad: horizontalSizeClass == .regular)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: layout.listSpacing) {
            Text("편의 시설")
                .font(layout.isIPad ? .title2 : .title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color.primary)

            VStack(alignment: .leading, spacing: layout.itemSpacing) {
                ForEach(sortedCategories) { category in
                    if let poiCategory = category.toPOICategory {
                        Button {
                            if selectedCategory == poiCategory {
                                selectedCategory = nil
                            } else {
                                selectedCategory = poiCategory
                            }
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

                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }

                        .padding(.horizontal, layout.horizontalListPadding)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selectedCategory == poiCategory ? Color.quatFill : Color.clear)
                        )

                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private struct DeviceLayout {
    let isIPad: Bool

    var listSpacing: CGFloat {
        isIPad ? 16 : 12
    }

    var itemSpacing: CGFloat {
        isIPad ? 0 : 10
    }

    var horizontalListPadding: CGFloat {
        isIPad ? 8 : 12
    }
}

#Preview {
    CategoryGridView(selectedCategory: .constant(nil))
        .padding()
}
