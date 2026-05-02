import Foundation

enum DexScreenerError: Error, Sendable {
    case invalidURL
    case httpStatus(Int)
    case decoding(Error)
}

protocol TokenBoostsProviding: Sendable {
    func fetchLatestTokenBoosts() async throws -> [DexTokenBoost]
}

actor DexScreenerClient: TokenBoostsProviding {
    static let defaultBaseURL = URL(string: "https://api.dexscreener.com")!
    static let shared = DexScreenerClient()

    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    init(baseURL: URL = DexScreenerClient.defaultBaseURL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        self.decoder = d
    }

    func fetchLatestTokenProfiles() async throws -> [DexTokenProfile] {
        try await get("token-profiles/latest/v1")
    }

    func fetchRecentTokenProfileUpdates() async throws -> [DexTokenProfile] {
        try await get("token-profiles/recent-updates/v1")
    }

    func fetchLatestCommunityTakeovers() async throws -> [DexCommunityTakeover] {
        try await get("community-takeovers/latest/v1")
    }

    func fetchLatestAds() async throws -> [DexLatestAd] {
        try await get("ads/latest/v1")
    }

    func fetchLatestTokenBoosts() async throws -> [DexTokenBoost] {
        try await get("token-boosts/latest/v1")
    }

    func fetchTopTokenBoosts() async throws -> [DexTokenBoost] {
        try await get("token-boosts/top/v1")
    }

    func fetchOrders(chainId: String, tokenAddress: String) async throws -> [DexOrder] {
        let path = "orders/v1/\(chainId)/\(tokenAddress)"
        let envelope: DexOrdersEnvelope = try await get(path)
        return envelope.orders
    }

    func fetchLatestPairs(chainId: String, pairId: String) async throws -> DexLatestPairsResponse {
        try await get("latest/dex/pairs/\(chainId)/\(pairId)")
    }

    func searchPairs(query: String) async throws -> DexSearchResponse {
        var c = URLComponents(url: baseURL.appendingPathComponent("latest/dex/search"), resolvingAgainstBaseURL: false)!
        c.queryItems = [URLQueryItem(name: "q", value: query)]
        guard let url = c.url else { throw DexScreenerError.invalidURL }
        return try await get(url: url)
    }

    func fetchTokenPairs(chainId: String, tokenAddress: String) async throws -> [DexPair] {
        try await get("token-pairs/v1/\(chainId)/\(tokenAddress)")
    }

    func fetchPairsForTokens(chainId: String, tokenAddresses: String) async throws -> [DexPair] {
        try await get("tokens/v1/\(chainId)/\(tokenAddresses)")
    }

    func fetchTrendingMetas() async throws -> [DexTrendingMeta] {
        try await get("metas/trending/v1")
    }

    func fetchMeta(slug: String) async throws -> DexMetaDetail {
        try await get("metas/meta/v1/\(slug)")
    }

    private func get<T: Decodable>(_ path: String) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        return try await get(url: url)
    }

    private func get<T: Decodable>(url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw DexScreenerError.httpStatus(-1)
        }
        guard (200 ... 299).contains(http.statusCode) else {
            throw DexScreenerError.httpStatus(http.statusCode)
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw DexScreenerError.decoding(error)
        }
    }
}
