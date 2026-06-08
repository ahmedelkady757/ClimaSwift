//
//  OfflineBannerView.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 08/06/2026.
//

import SwiftUI

/// Animated sticky banner displayed at the top of the screen when the
/// device has no internet connection.
struct OfflineBannerView: View {

    let isOffline: Bool

    var body: some View {
        VStack {
            if isOffline {
                HStack(spacing: 10) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 15, weight: .semibold))

                    Text("No Internet Connection")
                        .font(.system(size: 14, weight: .semibold))

                    Spacer()

                    Text("Offline")
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.25))
                        .clipShape(Capsule())
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.85, green: 0.18, blue: 0.18),
                            Color(red: 0.95, green: 0.40, blue: 0.10)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: Color.black.opacity(0.30), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal:   .move(edge: .top).combined(with: .opacity)
                    )
                )
            }

            Spacer()
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.75), value: isOffline)
        .ignoresSafeArea(edges: .top)
        .allowsHitTesting(false)
    }
}

#Preview {
    ZStack {
        Color.blue.ignoresSafeArea()
        OfflineBannerView(isOffline: true)
    }
}
