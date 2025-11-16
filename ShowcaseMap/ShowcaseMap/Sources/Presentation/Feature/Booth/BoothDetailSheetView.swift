//
//  BoothDetailSheetView.swift
//  ShowcaseMap
//
//  Created by 딘은딘딘 on 11/16/25.
//

import SwiftUI
import SwiftData

struct BoothDetailSheetView: View {
    let teamInfo: TeamInfo
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    Button {
                        shareAction()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .frame(width: 40, height: 40)
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Text(teamInfo.name)
                            .font(.system(size: 17, weight: .semibold))
                        Text("부스 · Team \(String(format: "%02d", Int(teamInfo.boothNumber) ?? 0))")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .frame(width: 40, height: 40)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 8)

                BoothDetailView(teamInfo: teamInfo)
            }
            .environment(\.modelContext, modelContext)
        }
    }

    private func shareAction() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return
        }

        let activityVC = UIActivityViewController(
            activityItems: ["부스 정보: \(teamInfo.name)"],
            applicationActivities: nil
        )

        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = window
            popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        rootViewController.present(activityVC, animated: true)
    }
}
