//
//  CategoryFilterView.swift
//  ShowcaseMap
//
//  Created by 딘은딘딘 on 11/15/25.
//

import SwiftUI

struct POICategoryFilterView: View {
    @Binding var selectedCategory: POICategory?

    private var sortedCategories: [POICategory] {
        // 엘베/계단은 항상 표시되므로 필터 버튼에서 제외
        let visibleCategories = POICategory.allCases.filter { $0 != .elevator && $0 != .stairs && $0 != .photobooth }
        return visibleCategories
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(self.sortedCategories) { category in
                    CategoryButton(
                        category: category,
                        isSelected: self.selectedCategory == category
                    ) {
                        self.toggleCategory(category)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    private func toggleCategory(_ category: POICategory) {
        withAnimation {
            if self.selectedCategory == category {
                self.selectedCategory = nil
            } else {
                self.selectedCategory = category
            }
        }
    }
}

struct CategoryButton: View {
    let category: POICategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: self.action) {
            HStack(spacing: 6) {
                Image(systemName: self.category.iconName)
                    .font(.system(size: 14))
                Text(self.category.rawValue)
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundStyle(self.isSelected ? .teal : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .applyGlassEffect()
            .clipShape(.capsule)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var selectedCategory: POICategory? = nil
    POICategoryFilterView(selectedCategory: $selectedCategory)
}
