//
//  AmenityDetailView.swift
//  ShowcaseMap
//
//  Created by bishoe01 on 11/19/25.
//

import CoreLocation
import SwiftUI

struct AmenityDetailView: View {
    let amenityData: MapMarkerData
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 16) {
            // 닫기 버튼
            HStack {
                Spacer()
                SheetIconButton(systemName: "xmark") {
                    dismiss()
                }
            }

            VStack(spacing: 12) {
                Text(amenityData.title)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(amenityData.category.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 26)
    }
}

#Preview {
    AmenityDetailView(
        amenityData: MapMarkerData(
            coordinate: .init(latitude: 36.014267, longitude: 129.325778),
            title: "화장실",
            category: .restroom
        )
    )
}
