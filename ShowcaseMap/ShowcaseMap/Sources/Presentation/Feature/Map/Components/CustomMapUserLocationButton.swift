//
//  CustomMapUserLocationButton.swift
//  ShowcaseMap
//
//  Created by bishoe01 on 11/21/25.
//
import MapKit
import SwiftUI

struct CustomMapUserLocationButton: View {
    @Binding var trackingMode: LocationTrackingMode
    @Binding var mapCameraPosition: MapCameraPosition
    @Binding var isOutOfBounds: Bool
    let levelSyncAction: () -> Void

    @State private var showAlert = false

    var body: some View {
        Button(action: {
            handleTap()
        }) {
            Image(systemName: iconName)
        }
        .buttonStyle(.plain)
        .foregroundStyle(iconColor)
        .alert("현재 위치 확인", isPresented: $showAlert) {
            Button("확인") {}
        } message: {
            Text("쇼케이스 영역 내에서 이용 가능합니다")
        }
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
            // C5로부터 멀리있을때 alert
            if isOutOfBounds {
                showAlert = true
                return
            }

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
