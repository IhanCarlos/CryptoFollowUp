import SwiftUI

struct SwapToken: Equatable {
    var symbol: String
    var name: String
    var mark: String
    var color: Color
    var iconURL: URL?
    
    init(symbol: String, name: String = "", mark: String, color: Color, iconURL: URL? = nil) {
        self.symbol = symbol
        self.name = name
        self.mark = mark
        self.color = color
        self.iconURL = iconURL
    }
    
    static func == (lhs: SwapToken, rhs: SwapToken) -> Bool {
        lhs.symbol == rhs.symbol
        && lhs.name == rhs.name
        && lhs.mark == rhs.mark
        && lhs.iconURL == rhs.iconURL
    }
}

struct SwapCardView: View {
    let payToken: SwapToken
    let receiveToken: SwapToken
    let payAmount: String
    let receiveAmount: String
    let payBalance: String
    let receiveBalance: String
    let payValue: String
    let receiveValue: String
    
    var body: some View {
        ZStack {
            VStack(spacing: AppSpacing.md) {
                SwapInputCard(
                    title: "You Pay",
                    token: payToken,
                    amount: payAmount,
                    balance: payBalance,
                    value: payValue,
                    showsMaxButton: true
                )
                .shadow(color: Color.black.opacity(0.07), radius: 14, x: 0, y: 6)
                
                SwapInputCard(
                    title: "You Receive",
                    token: receiveToken,
                    amount: receiveAmount,
                    balance: receiveBalance,
                    value: receiveValue,
                    showsMaxButton: false
                )
                .shadow(color: Color.black.opacity(0.07), radius: 14, x: 0, y: 6)
            }
            
            SwapDirectionButton()
        }
        .padding(.vertical, AppSpacing.md)
    }
}

private struct SwapInputCard: View {
    let title: String
    let token: SwapToken
    let amount: String
    let balance: String
    let value: String
    let showsMaxButton: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(alignment: .top) {
                Text(title)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.secondaryLabel)
                
                    .padding(10)
                
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "wallet.pass")
                    Text(balance)
                }
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.secondaryLabel)
                
                if showsMaxButton {
                    Button("Max") {}
                        .buttonStyle(.plain)
                        .font(AppTypography.caption.weight(.semibold))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, 6)
                        .background(Color.black, in: Capsule())
                }
            }
            
            HStack(alignment: .center, spacing: AppSpacing.md) {
                HStack(spacing: AppSpacing.sm) {
                    TokenBadge(token: token)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: AppSpacing.xs) {
                            Text(token.symbol)
                                .font(AppTypography.headline)
                                .foregroundStyle(AppColor.primaryLabel)
                            Image(systemName: "chevron.down")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(AppColor.secondaryLabel)
                        }
                        if !token.name.isEmpty {
                            Text(token.name)
                                .font(AppTypography.caption2)
                                .foregroundStyle(AppColor.tertiaryLabel)
                                .lineLimit(1)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                    Text(amount)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColor.primaryLabel)
                        .multilineTextAlignment(.trailing)
                    
                    Text("≈ \(value)")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.secondaryLabel)
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.swapCard, style: .continuous))
    }
}

private struct TokenBadge: View {
    let token: SwapToken
    private let badgeSize: CGFloat = 36
    
    var body: some View {
        if token.iconURL != nil {
            TokenIconView(url: token.iconURL, size: badgeSize, circular: true)
        } else {
            Circle()
                .fill(token.color)
                .frame(width: badgeSize, height: badgeSize)
                .overlay {
                    Text(token.mark)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                }
        }
    }
}

private struct SwapDirectionButton: View {
    var body: some View {
        Circle()
            .fill(Color(red: 0.96, green: 0.96, blue: 0.97))
            .frame(width: 44, height: 44)
            .overlay {
                Circle()
                    .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
            }
            .overlay {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(AppColor.primaryLabel)
            }
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
}

#Preview("Swap Card") {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 0.97, green: 0.97, blue: 0.99),
                Color(red: 0.90, green: 0.93, blue: 1.00),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        SwapCardView(
            payToken: SwapToken(
                symbol: "BNB",
                name: "Wrapped BNB",
                mark: "◎",
                color: Color(red: 0.96, green: 0.73, blue: 0.15),
                iconURL: URL(string: "https://tokens.pancakeswap.finance/images/0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c.png")
            ),
            receiveToken: SwapToken(
                symbol: "USDT",
                name: "Tether USD",
                mark: "T",
                color: Color(red: 0.16, green: 0.72, blue: 0.52),
                iconURL: URL(string: "https://tokens.pancakeswap.finance/images/0x55d398326f99059fF775485246999027B3197955.png")
            ),
            payAmount: "0.01",
            receiveAmount: "6.7345108344",
            payBalance: "52.34 BNB",
            receiveBalance: "187.52 USDT",
            payValue: "6,247.70 USD",
            receiveValue: "28,197.64 USD"
        )
        .padding(AppSpacing.md)
    }
}
