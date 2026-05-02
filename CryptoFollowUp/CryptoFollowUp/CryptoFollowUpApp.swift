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

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: tokenBoostsViewModel)
        }
    }
}
