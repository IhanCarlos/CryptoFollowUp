import Combine
import Foundation

@MainActor
final class TokenBoostsViewModel: ObservableObject {
    @Published private(set) var boosts: [WelcomeElement] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let tokenBoosts: TokenBoostsProviding

    init(tokenBoosts: TokenBoostsProviding = DexScreenerClient.shared) {
        self.tokenBoosts = tokenBoosts
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            boosts = try await tokenBoosts.fetchLatestTokenBoosts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refresh() async {
        isLoading = false
        await load()
    }
}

#if DEBUG
actor PreviewTokenBoostsProvider: TokenBoostsProviding {
    func fetchLatestTokenBoosts() async throws -> [DexTokenBoost] {
        [
            WelcomeElement(
                url: "https://dexscreener.com",
                chainID: .solana,
                tokenAddress: "So11111111111111111111111111111111111111112",
                description: "Preview",
                icon: "zCdk2o2rkqr1zULB",
                header: nil,
                openGraph: nil,
                totalAmount: 20,
                amount: 10,
                links: nil
            ),
        ]
    }
}
#endif
