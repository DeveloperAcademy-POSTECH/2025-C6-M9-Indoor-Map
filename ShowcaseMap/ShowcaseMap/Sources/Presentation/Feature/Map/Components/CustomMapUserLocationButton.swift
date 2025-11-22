//
//  CustomMapUserLocationButton.swift
//  ShowcaseMap
//
//  Created by bishoe01 on 11/21/25.
//
import SwiftUI
import MapKit

struct CustomMapUserLocationButton: View {
    @Binding var trackingMode: LocationTrackingMode
    @Binding var mapCameraPosition: MapCameraPosition
    let levelSyncAction: () -> Void

    var body: some View {
        Button(action: {
            handleTap()
        }) {
            Image(systemName: iconName)
        }
        .buttonStyle(.plain)
        .foregroundStyle(iconColor)
    }

    private var iconName: String {
        switch trackingMode {
        case .idle:
            return "location"
        case .follow:
            return "location.fill"
        case .followWithHeading:
            return "location.north.line.fill"
        }
    }

    private var iconColor: Color {
        trackingMode == .idle ? .primary : .blue
    }

    private func handleTap() {
        switch trackingMode {
        case .idle:
            trackingMode = .follow
            mapCameraPosition = .userLocation(followsHeading: false, fallback: .automatic)
            levelSyncAction()
        case .follow:
            trackingMode = .followWithHeading
            mapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
            levelSyncAction()
        case .followWithHeading:
            trackingMode = .idle
            mapCameraPosition = .userLocation(followsHeading: false, fallback: .automatic)
        }
    }
}
