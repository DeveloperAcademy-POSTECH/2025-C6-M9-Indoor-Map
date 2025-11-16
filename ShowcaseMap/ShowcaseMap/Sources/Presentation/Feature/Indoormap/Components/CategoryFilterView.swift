//
//  CategoryFilterView.swift
//  ShowcaseMap
//
//  Created by 딘은딘딘 on 11/15/25.
//

import SwiftUI

struct POICategoryFilterView: View {
    @Binding var selectedCategory: POICategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(POICategory.allCases) { category in
                    CategoryButton(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        toggleCategory(category)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(.ultraThinMaterial)
    }

    private func toggleCategory(_ category: POICategory) {
        if selectedCategory == category {
            selectedCategory = nil
        } else {
            selectedCategory = category
        }
    }
}

struct CategoryButton: View {
    let category: POICategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.iconName)
                    .font(.system(size: 14))

                Text(category.rawValue)
                    .font(.system(size: 14, weight: .medium))

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                }
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.blue : Color(uiColor: .systemGray5))
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
            )
        }
    }
}

#Preview {
    POICategoryFilterView(selectedCategory: .constant(.restroom))
}

