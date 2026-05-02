import Combine
import Foundation
import SwiftUI

enum SwapViewError: LocalizedError {
    case noPairFound

    var errorDescription: String? {
        switch self {
        case .noPairFound:
            return "Nenhum par encontrado para esta pesquisa."
        }
    }
}

@MainActor
final class SwapViewModel: ObservableObject {
    @Published private(set) var payToken: SwapToken = .previewPay
    @Published private(set) var receiveToken: SwapToken = .previewReceive
    @Published private(set) var payAmount: String = "0.01"
    @Published private(set) var receiveAmount: String = "—"
    @Published private(set) var payBalance: String = "—"
    @Published private(set) var receiveBalance: String = "—"
    @Published private(set) var payValue: String = "—"
    @Published private(set) var receiveValue: String = "—"
    @Published private(set) var feeText: String = "Taxa: liga à carteira / DEX"
    @Published private(set) var rateText: String = "Cotação: a carregar…"
    @Published private(set) var walletAddress: String = "DexScreener"
    @Published private(set) var insights: SwapPairInsights?
    @Published private(set) var isLoading = false
    @Published private(set) var hasLoadedPair = false
    @Published private(set) var errorMessage: String?

    private let client: DexScreenerClient
    private let searchQueries: [String]
    private var pair: DexPair?
    private var payQuantity: Double = 0.01

    private let qtyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.numberStyle = .decimal
        f.maximumFractionDigits = 10
        f.minimumFractionDigits = 2
        f.usesGroupingSeparator = true
        f.groupingSeparator = ","
        return f
    }()

    private let usdFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.numberStyle = .decimal
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 2
        f.usesGroupingSeparator = true
        return f
    }()

    init(
        client: DexScreenerClient = .shared,
        searchQueries: [String] = ["WBNB USDT", "BNB USDT", "ETH USDC"]
    ) {
        self.client = client
        self.searchQueries = searchQueries
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        hasLoadedPair = false
        errorMessage = nil
        insights = nil
        defer { isLoading = false }

        do {
            var searchBest: DexPair?
            var schemaSearch: String?

            for q in searchQueries {
                let res = try await client.searchPairs(query: q)
                guard let best = res.pairs.max(by: { ($0.liquidity?.usd ?? 0) < ($1.liquidity?.usd ?? 0) }) else { continue }
                searchBest = best
                schemaSearch = res.schemaVersion
                break
            }

            guard var candidate = searchBest else { throw SwapViewError.noPairFound }

            let latestResponse = try? await client.fetchLatestPairs(chainId: candidate.chainId, pairId: candidate.pairAddress)
            if let p = latestResponse?.pairs?.first {
                candidate = p
            }

            let pair = candidate
            self.pair = pair

            let tokenRows: [DexPair] = (try? await client.fetchPairsForTokens(
                chainId: pair.chainId,
                tokenAddresses: "\(pair.baseToken.address),\(pair.quoteToken.address)"
            )) ?? []

            let quoteIconURL = Self.resolveQuoteIconURL(pair: pair, tokenRows: tokenRows)

            let ob = (try? await client.fetchOrders(chainId: pair.chainId, tokenAddress: pair.baseToken.address)) ?? []
            let oq = (try? await client.fetchOrders(chainId: pair.chainId, tokenAddress: pair.quoteToken.address)) ?? []

            hasLoadedPair = true
            walletAddress = "\(pair.chainId) · \(pair.dexId)"

            payToken = Self.mapToken(pair.baseToken, pair: pair, isBase: true, iconOverride: nil)
            receiveToken = Self.mapToken(pair.quoteToken, pair: pair, isBase: false, iconOverride: quoteIconURL)

            payBalance = "API: sem saldo de carteira"
            receiveBalance = "API: sem saldo de carteira"

            payAmount = formatQty(payQuantity)
            recalculateOutputs()

            insights = Self.buildInsights(
                pair: pair,
                schemaVersion: latestResponse?.schemaVersion ?? schemaSearch,
                ordersBase: ob,
                ordersQuote: oq
            )
        } catch {
            errorMessage = error.localizedDescription
            hasLoadedPair = false
            insights = nil
        }
    }

    func setPayAmount(decimal: Double) {
        payQuantity = max(0, decimal)
        let s = qtyFormatter.string(from: NSNumber(value: payQuantity)) ?? String(payQuantity)
        payAmount = s
        recalculateOutputs()
    }

    func refresh() async {
        await load()
    }

    private func recalculateOutputs() {
        guard let pair else { return }

        let rate = Double(pair.priceNative) ?? 0
        let baseUsd = Double(pair.priceUsd ?? "") ?? 0
        guard rate > 0, payQuantity > 0 else {
            receiveAmount = "—"
            payValue = "—"
            receiveValue = "—"
            rateText = "1 \(pair.baseToken.symbol) ≈ \(pair.priceNative) \(pair.quoteToken.symbol)"
            return
        }

        let receiveQty = payQuantity * rate
        let quoteUsd = baseUsd / rate

        receiveAmount = formatQty(receiveQty)
        let payUsdVal = payQuantity * baseUsd
        let recvUsdVal = receiveQty * quoteUsd

        payValue = formatUsd(payUsdVal)
        receiveValue = formatUsd(recvUsdVal)

        let feeUsd = payUsdVal * 0.003
        feeText = "Est. DEX ~0,3% · " + formatUsd(feeUsd)

        rateText = [
            "1 \(pair.baseToken.symbol) ≈ \(formatQty(rate)) \(pair.quoteToken.symbol)",
            "(≈ \(formatUsdPlain(baseUsd)) USD · \(pair.dexId))",
        ].joined(separator: " ")
    }

    private func formatQty(_ v: Double) -> String {
        qtyFormatter.string(from: NSNumber(value: v)) ?? String(v)
    }

    private func formatUsd(_ v: Double) -> String {
        usdFormatter.string(from: NSNumber(value: v)).map { "≈ \($0) USD" } ?? "≈ \(v) USD"
    }

    private func formatUsdPlain(_ v: Double) -> String {
        usdFormatter.string(from: NSNumber(value: v)) ?? String(format: "%.2f", v)
    }

    private static func resolveQuoteIconURL(pair: DexPair, tokenRows: [DexPair]) -> URL? {
        let target = pair.quoteToken.address.lowercased()
        for p in tokenRows where p.baseToken.address.lowercased() == target {
            if let s = p.info?.imageUrl, let u = URL(string: s) { return u }
        }
        return nil
    }

    private static func mapToken(
        _ ref: DexTokenRef,
        pair: DexPair,
        isBase: Bool,
        iconOverride: URL?
    ) -> SwapToken {
        let url: URL?
        if let iconOverride {
            url = iconOverride
        } else if isBase, ref.address.caseInsensitiveCompare(pair.baseToken.address) == .orderedSame {
            url = pair.info?.imageUrl.flatMap { URL(string: $0) }
        } else {
            url = nil
        }

        let mark = ref.symbol.isEmpty ? "?" : String(ref.symbol.prefix(1))
        return SwapToken(
            symbol: ref.symbol,
            name: ref.name,
            mark: mark,
            color: paletteColor(symbol: ref.symbol),
            iconURL: url
        )
    }

    private static func paletteColor(symbol: String) -> Color {
        let h = Double(abs(symbol.hashValue % 360)) / 360.0
        return Color(hue: h, saturation: 0.5, brightness: 0.88)
    }

    private static func buildInsights(
        pair: DexPair,
        schemaVersion: String?,
        ordersBase: [DexOrder],
        ordersQuote: [DexOrder]
    ) -> SwapPairInsights {
        let addr = pair.pairAddress
        let short: String
        if addr.count > 12 {
            short = "\(addr.prefix(6))…\(addr.suffix(4))"
        } else {
            short = addr
        }

        let liq = pair.liquidity?.usd.map { compactUsd($0) }
        let vol = pair.volume?["h24"].map { compactUsd($0) }
        let chg = pair.priceChange?["h24"].map { pct in
            let sign = pct > 0 ? "+" : ""
            return "\(sign)\(String(format: "%.2f", pct))% (24h)"
        }

        let txns24: String?
        if let t = pair.txns?["h24"] {
            txns24 = "\(t.buys) compras · \(t.sells) vendas (24h)"
        } else {
            txns24 = nil
        }

        let fdv = pair.fdv.map { compactUsd($0) }
        let mcap = pair.marketCap.map { compactUsd($0) }

        let age: String?
        if let raw = pair.pairCreatedAt {
            let seconds = raw > 1e12 ? raw / 1000 : raw
            let d = Date(timeIntervalSince1970: seconds)
            let f = RelativeDateTimeFormatter()
            f.locale = Locale(identifier: "pt_PT")
            f.unitsStyle = .abbreviated
            age = f.localizedString(for: d, relativeTo: Date())
        } else {
            age = nil
        }

        let boosts: String?
        if let n = pair.boosts?.active, n > 0 {
            boosts = "\(n) boost(s) ativo(s) no par"
        } else {
            boosts = nil
        }

        let labels = pair.labels?.filter { !$0.isEmpty }.joined(separator: ", ")
        let web = pair.info?.websites?.first.flatMap { URL(string: $0.url) }
        let socials = pair.info?.socials?.map { "\($0.platform): @\($0.handle)" }.joined(separator: " · ")

        return SwapPairInsights(
            pairURL: URL(string: pair.url),
            headline: "\(pair.chainId) · \(pair.dexId)",
            pairAddressTruncated: short,
            liquidityUsd: liq.map { "Liquidez · \($0)" },
            volume24h: vol.map { "Volume 24h · \($0)" },
            priceChange24h: chg,
            txns24h: txns24,
            fdv: fdv.map { "FDV · \($0)" },
            marketCap: mcap.map { "Market cap · \($0)" },
            pairAge: age.map { "Par criado · \($0)" },
            activeBoosts: boosts,
            labels: labels.map { "Etiquetas · \($0)" },
            primaryWebsite: web,
            socialsSummary: socials,
            ordersPayToken: formatOrdersLine(symbol: pair.baseToken.symbol, orders: ordersBase),
            ordersReceiveToken: formatOrdersLine(symbol: pair.quoteToken.symbol, orders: ordersQuote),
            schemaVersion: schemaVersion.map { "Schema API · \($0)" }
        )
    }

    private static func compactUsd(_ v: Double) -> String {
        if v >= 1_000_000_000 { return String(format: "$%.2fB", v / 1e9) }
        if v >= 1_000_000 { return String(format: "$%.2fM", v / 1e6) }
        if v >= 1_000 { return String(format: "$%.2fK", v / 1e3) }
        return String(format: "$%.2f", v)
    }

    private static func formatOrdersLine(symbol: String, orders: [DexOrder]) -> String {
        guard !orders.isEmpty else {
            return "Orders \(symbol): nenhum (API orders/v1)"
        }
        let parts = orders.map { o in
            "\(orderTypeLabel(o.type)) · \(orderStatusLabel(o.status))"
        }
        return "Orders \(symbol): " + parts.joined(separator: " | ")
    }

    private static func orderTypeLabel(_ t: DexOrderType) -> String {
        switch t {
        case .tokenProfile: return "perfil"
        case .communityTakeover: return "takeover"
        case .tokenAd: return "anúncio"
        case .trendingBarAd: return "trending bar"
        }
    }

    private static func orderStatusLabel(_ s: DexOrderStatus) -> String {
        switch s {
        case .processing: return "processamento"
        case .cancelled: return "cancelado"
        case .onHold: return "em espera"
        case .approved: return "aprovado"
        case .rejected: return "rejeitado"
        }
    }
}
