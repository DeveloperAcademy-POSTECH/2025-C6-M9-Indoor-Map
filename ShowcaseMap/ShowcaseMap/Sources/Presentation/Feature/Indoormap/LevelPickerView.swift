//
//  LevelPickerView.swift
//  ShowcaseMap
//
//  Created by 딘은딘딘 on 11/16/25.
//

import SwiftUI

struct LevelPickerSwiftUI: View {
    let levels: [Level]
    @Binding var selectedIndex: Int

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
            ForEach(Array(levelNames.enumerated()), id: \.offset) { index, name in
                Button(action: {
                    selectedIndex = index
                }) {
                    Text(name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(selectedIndex == index ? Color("LevelPickerSelected") : Color.clear)
                }

                if index < levelNames.count - 1 {
                    Divider()
                        .background(Color(UIColor.separator))
                }
            }
        }
        .background(.ultraThinMaterial)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 1)
        .frame(width: 60)
    }
}
