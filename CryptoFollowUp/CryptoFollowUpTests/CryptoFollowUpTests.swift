import Testing
@testable import CryptoFollowUp

struct CryptoFollowUpTests {

    @Test @MainActor
    func tokenBoostsViewModelLoadSuccess() async {
        let stub = StubTokenBoosts(result: .success([Self.sampleBoost]))
        let vm = TokenBoostsViewModel(tokenBoosts: stub)
        await vm.load()
        #expect(vm.boosts.count == 1)
        #expect(vm.boosts.first?.tokenAddress == "So111")
        #expect(vm.errorMessage == nil)
        #expect(vm.isLoading == false)
    }

    @Test @MainActor
    func tokenBoostsViewModelLoadFailure() async {
        let stub = StubTokenBoosts(result: .failure(URLError(.notConnectedToInternet)))
        let vm = TokenBoostsViewModel(tokenBoosts: stub)
        await vm.load()
        #expect(vm.boosts.isEmpty)
        #expect(vm.errorMessage != nil)
    }

    private static var sampleBoost: WelcomeElement {
        WelcomeElement(
            url: "https://dexscreener.com",
            chainID: .solana,
            tokenAddress: "So111",
            description: "Test",
            icon: nil,
            header: nil,
            openGraph: nil,
            totalAmount: 10,
            amount: 5,
            links: nil
        )
    }
}

private actor StubTokenBoosts: TokenBoostsProviding {
    private let result: Result<[WelcomeElement], Error>

    init(result: Result<[WelcomeElement], Error>) {
        self.result = result
    }

    func fetchLatestTokenBoosts() async throws -> [DexTokenBoost] {
        try result.get()
    }
}
