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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 16) {
            // 닫기 버튼

            HStack {
                Spacer()
                if horizontalSizeClass == .compact {
                    SheetIconButton(systemName: "xmark") {
                        dismiss()
                    }
                }
            }

            VStack(spacing: 2) {
                Text(amenityData.title)
                    .font(.title)
                    .foregroundStyle(Color.primary)
                    .bold()

                Text("편의시설")
                    .font(.callout)
                    .foregroundStyle(Color.secondary)
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
            id: UUID(),
            coordinate: .init(latitude: 36.014267, longitude: 129.325778),
            title: "화장실",
            category: .restroom
        )
    )
}
