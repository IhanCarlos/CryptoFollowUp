//
//  CryptoFollowUpApp.swift
//  CryptoFollowUp
//
//  Created by ihan carlos on 02/05/26.
//

import SwiftUI

@main
struct CryptoFollowUpApp: App {
    @StateObject private var tokenBoostsViewModel = TokenBoostsViewModel(tokenBoosts: DexScreenerClient.shared)
    @StateObject private var swapViewModel = SwapViewModel(client: DexScreenerClient.shared)

    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView(viewModel: tokenBoostsViewModel)
                    .tabItem {
                        Label("Boosts", systemImage: "flame.fill")
                    }

                SwapScreenView(viewModel: swapViewModel)
                    .tabItem {
                        Label("Swap", systemImage: "arrow.left.arrow.right")
                    }
            }
            .tint(AppColor.accent)
        }
    }
}
