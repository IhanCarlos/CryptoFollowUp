//
//  DexModels.swift
//  CryptoFollowUp
//
//  Created by Arthur Ferreira on 02/05/26.
//

import Foundation

enum ChainID: Codable, Hashable, Sendable {
    case ethereum
    case solana
    case xrpl
    case other(String)

    var rawValue: String {
        switch self {
        case .ethereum: return "ethereum"
        case .solana: return "solana"
        case .xrpl: return "xrpl"
        case .other(let id): return id
        }
    }

    init(from decoder: Decoder) throws {
        let s = try decoder.singleValueContainer().decode(String.self)
        switch s {
        case "ethereum": self = .ethereum
        case "solana": self = .solana
        case "xrpl": self = .xrpl
        default: self = .other(s)
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(rawValue)
    }
}

enum TypeEnum: String, Codable, Hashable, Sendable {
    case telegram
    case twitter
}

struct Link: Codable, Hashable, Sendable {
    let url: String
    let type: TypeEnum?
    let label: String?

    enum CodingKeys: String, CodingKey {
        case url, type, label
    }

    init(url: String, type: TypeEnum?, label: String?) {
        self.url = url
        self.type = type
        self.label = label
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        url = try c.decode(String.self, forKey: .url)
        label = try c.decodeIfPresent(String.self, forKey: .label)
        if let raw = try c.decodeIfPresent(String.self, forKey: .type) {
            type = TypeEnum(rawValue: raw)
        } else {
            type = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(url, forKey: .url)
        try c.encodeIfPresent(label, forKey: .label)
        try c.encodeIfPresent(type?.rawValue, forKey: .type)
    }
}

struct DexTokenProfile: Codable, Hashable, Sendable {
    var url: String
    var chainId: String
    var tokenAddress: String
    var icon: String?
    var header: String?
    var openGraph: String?
    var description: String?
    var links: [Link]?
}

struct DexCommunityTakeover: Codable, Hashable, Sendable {
    var url: String
    var chainId: String
    var tokenAddress: String
    var icon: String?
    var header: String?
    var openGraph: String?
    var description: String?
    var links: [Link]?
    var claimDate: Date
}

struct DexLatestAd: Codable, Hashable, Sendable {
    var url: String
    var chainId: String
    var tokenAddress: String
    var date: Date
    var type: String
    var durationHours: Double?
    var impressions: Double?
}

struct WelcomeElement: Codable, Hashable, Sendable {
    let url: String
    let chainID: ChainID
    let tokenAddress: String
    let description: String?
    let icon: String?
    let header: String?
    let openGraph: String?
    let totalAmount: Int
    let amount: Int
    let links: [Link]?

    enum CodingKeys: String, CodingKey {
        case url
        case chainID = "chainId"
        case tokenAddress, description, icon, header, openGraph, totalAmount, amount, links
    }
}

typealias Welcome = [WelcomeElement]

typealias DexTokenBoost = WelcomeElement

enum DexOrderType: String, Codable, Sendable {
    case tokenProfile
    case communityTakeover
    case tokenAd
    case trendingBarAd
}

enum DexOrderStatus: String, Codable, Sendable {
    case processing
    case cancelled
    case onHold = "on-hold"
    case approved
    case rejected
}

struct DexOrder: Codable, Hashable, Sendable {
    var chainId: String?
    var tokenAddress: String?
    var type: DexOrderType
    var status: DexOrderStatus
    var paymentTimestamp: Double
}

struct DexOrdersEnvelope: Codable, Hashable, Sendable {
    var orders: [DexOrder]
}

struct DexTokenRef: Codable, Hashable, Sendable {
    var address: String
    var name: String
    var symbol: String
}

struct DexTxnBucket: Codable, Hashable, Sendable {
    var buys: Int
    var sells: Int
}

struct DexPairLiquidity: Codable, Hashable, Sendable {
    var usd: Double?
    var base: Double?
    var quote: Double?
}

struct DexPairWebsite: Codable, Hashable, Sendable {
    var url: String
}

struct DexPairSocial: Codable, Hashable, Sendable {
    var platform: String
    var handle: String
}

struct DexPairInfo: Codable, Hashable, Sendable {
    var imageUrl: String?
    var websites: [DexPairWebsite]?
    var socials: [DexPairSocial]?
}

struct DexPairBoosts: Codable, Hashable, Sendable {
    var active: Int?
}

struct DexPair: Codable, Hashable, Sendable {
    var chainId: String
    var dexId: String
    var url: String
    var pairAddress: String
    var labels: [String]?
    var baseToken: DexTokenRef
    var quoteToken: DexTokenRef
    var priceNative: String
    var priceUsd: String?
    var txns: [String: DexTxnBucket]?
    var volume: [String: Double]?
    var priceChange: [String: Double]?
    var liquidity: DexPairLiquidity?
    var fdv: Double?
    var marketCap: Double?
    var pairCreatedAt: Double?
    var info: DexPairInfo?
    var boosts: DexPairBoosts?
}

struct DexLatestPairsResponse: Codable, Hashable, Sendable {
    var schemaVersion: String
    var pairs: [DexPair]?
}

struct DexSearchResponse: Codable, Hashable, Sendable {
    var schemaVersion: String
    var pairs: [DexPair]
}

struct DexMetaIcon: Codable, Hashable, Sendable {
    var type: String
    var value: String
}

struct DexMetaTimeframeStats: Codable, Hashable, Sendable {
    var m5: Double?
    var h1: Double?
    var h6: Double?
    var h24: Double?
}

struct DexTrendingMeta: Codable, Hashable, Sendable {
    var description: String
    var icon: DexMetaIcon
    var name: String
    var slug: String
    var marketCap: Double
    var liquidity: Double
    var volume: Double
    var tokenCount: Int
    var marketCapChange: DexMetaTimeframeStats
    var marketCapDelta: DexMetaTimeframeStats
}

struct DexMetaDetail: Codable, Hashable, Sendable {
    var description: String
    var icon: DexMetaIcon
    var name: String
    var slug: String
    var marketCap: Double
    var liquidity: Double
    var volume: Double
    var tokenCount: Int
    var marketCapChange: DexMetaTimeframeStats
    var marketCapDelta: DexMetaTimeframeStats
    var pairs: [DexPair]
}

enum DexMedia {
    static func tokenIconURL(from raw: String?) -> URL? {
        guard let raw = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else { return nil }
        if raw.hasPrefix("http://") || raw.hasPrefix("https://") {
            return URL(string: raw)
        }
        let encoded = raw.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? raw
        return URL(string: "https://cdn.dexscreener.com/cms/images/\(encoded)?width=128&height=128&fit=crop&quality=95&format=auto")
    }
}

extension WelcomeElement {
    var tokenIconURL: URL? { DexMedia.tokenIconURL(from: icon) }
}

extension DexTokenProfile {
    var tokenIconURL: URL? { DexMedia.tokenIconURL(from: icon) }
}
