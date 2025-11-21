//
//  View+extension.swift
//  ShowcaseMap
//
//  Created by bishoe01 on 11/19/25.
//

import SwiftUI

extension View {
    func logoStrokeBorder(
        _ color: Color = Color.opaqueStroke,
        lineWidth: CGFloat = 1,
        cornerRadius: CGFloat = 0
    ) -> some View {
        self
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(color, lineWidth: lineWidth)
            )
    }

    func floatingButtonStyle() -> some View {
        self
            .frame(width: 48, height: 48)
            .buttonBorderShape(.circle)
            .clipShape(Circle())
            .applyGlassEffect()
            .contentShape(Rectangle())
    }
}
