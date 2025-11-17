//
//  LevelPickerView.swift
//  ShowcaseMap
//
//  Created by 딘은딘딘 on 11/15/25.
//

import SwiftUI

struct LevelPickerSwiftUI: View {
    let levels: [Level]
    @Binding var selectedIndex: Int
    @State private var isExpanded: Bool = false

    private var levelNames: [String] {
        levels.map { level in
            if let shortName = level.properties.shortName.bestLocalizedValue {
                return shortName
            } else {
                return "\(level.properties.ordinal)"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if isExpanded {
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        isExpanded = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(width: 40, height: 40)
                        .background(
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.4),
                                                Color.white.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                Circle()
                                    .strokeBorder(Color.white.opacity(0.5), lineWidth: 0.5)
                            }
                            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 2)
                            .shadow(color: .black.opacity(0.08), radius: 1, x: 0, y: 1)
                        )
                }
                .padding(.bottom, 8)

                VStack(spacing: 2) {
                    ForEach(Array(levelNames.enumerated()), id: \.offset) { index, name in
                        Button(action: {
                            selectedIndex = index
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                isExpanded = false
                            }
                        }) {
                            Text(name)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(selectedIndex == index ? Color.white.opacity(0.35) : Color.clear)
                                )
                        }
                    }
                }
                .padding(6)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(.ultraThinMaterial)
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.4),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.5), lineWidth: 0.5)
                    }
                    .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 2)
                    .shadow(color: .black.opacity(0.08), radius: 1, x: 0, y: 1)
                )
            } else {
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        isExpanded = true
                    }
                }) {
                    Text(levelNames[selectedIndex])
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(width: 40, height: 40)
                        .background(
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.4),
                                                Color.white.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                Circle()
                                    .strokeBorder(Color.white.opacity(0.5), lineWidth: 0.5)
                            }
                            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 2)
                            .shadow(color: .black.opacity(0.08), radius: 1, x: 0, y: 1)
                        )
                }
            }
        }
    }
}
