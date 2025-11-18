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
    }

    private func toggleCategory(_ category: POICategory) {
        withAnimation {
            if selectedCategory == category {
                selectedCategory = nil
            } else {
                selectedCategory = category
            }
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
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundStyle(isSelected ? .teal : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .applyGlassEffect()
            .clipShape(.capsule)
        }
        .buttonStyle(.plain)
    }
}

extension View {
    @ViewBuilder
    func applyGlassEffect() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect()
        } else {
            self.background(.ultraThinMaterial).clipShape(.capsule)
        }
    }
}

#Preview {
    @Previewable @State var selectedCategory: POICategory? = nil
        POICategoryFilterView(selectedCategory: $selectedCategory)
}
