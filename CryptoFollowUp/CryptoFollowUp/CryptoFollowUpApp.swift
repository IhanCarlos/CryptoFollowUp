//
//  CryptoFollowUpApp.swift
//  CryptoFollowUp
//
//  Created by ihan carlos on 02/05/26.
//

import SwiftUI
import Firebase

@main
struct CryptoFollowUpApp: App {
    
    @StateObject private var session = SessionManager()
    
    @StateObject private var tokenBoostsViewModel = TokenBoostsViewModel(tokenBoosts: DexScreenerClient.shared)
    @StateObject private var swapViewModel = SwapViewModel(client: DexScreenerClient.shared)

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            
            if session.isLogged {
//                MainTabView(
//                    tokenBoostsViewModel: tokenBoostsViewModel,
//                    swapViewModel: swapViewModel
//                )
            } else {
                LoginView()
            }
        }
    }
}
