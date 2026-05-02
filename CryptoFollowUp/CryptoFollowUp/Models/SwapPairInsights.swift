import Foundation

struct SwapPairInsights: Sendable, Equatable {
    var pairURL: URL?
    var headline: String
    var pairAddressTruncated: String
    var liquidityUsd: String?
    var volume24h: String?
    var priceChange24h: String?
    var txns24h: String?
    var fdv: String?
    var marketCap: String?
    var pairAge: String?
    var activeBoosts: String?
    var labels: String?
    var primaryWebsite: URL?
    var socialsSummary: String?
    var ordersPayToken: String?
    var ordersReceiveToken: String?
    var schemaVersion: String?
}
