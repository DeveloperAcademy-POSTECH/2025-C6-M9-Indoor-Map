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
                    .font(.system(size: 16, weight: .medium))
            }
            //.foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .modifier(GlassButtonModifier(isSelected: isSelected))
    }
}

struct GlassButtonModifier: ViewModifier {
    let isSelected: Bool
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .buttonStyle(.glass(.clear))
                .clipShape(Capsule())
//                .foregroundColor(
//                    Color.primary
//                )
                .foregroundStyle(
                    isSelected
                    ? Color.teal
                    : Color.primary
                    )
//                .overlay(
//                    Capsule()
//                        .fill(isSelected ? Color.teal.opacity(0.50) : Color.clear)
//                )
        } else {
            content
                .background(
                    Capsule()
                        .fill(isSelected ? Color.teal : Color(uiColor: .systemGray5))
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.teal : Color.clear, lineWidth: 1)
                )
                .clipShape(Capsule())
        }
    }
}

#Preview {
    POICategoryFilterView(selectedCategory: .constant(.restroom))
}
