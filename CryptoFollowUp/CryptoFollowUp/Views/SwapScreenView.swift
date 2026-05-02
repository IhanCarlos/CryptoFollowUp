import SwiftUI

struct SwapScreenView: View {
    @ObservedObject var viewModel: SwapViewModel
    @State private var swapCompleted = false

    private let notificationCount = 8

    var body: some View {
        ZStack {
            SwapScreenBackground()

            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    SwapScreenHeader(walletAddress: viewModel.walletAddress, notificationCount: notificationCount)

                    Text("Swap")
                        .font(AppTypography.largeTitle)
                        .foregroundStyle(AppColor.primaryLabel)
                        .frame(maxWidth: .infinity)

                    if let message = viewModel.errorMessage {
                        Text(message)
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColor.negative)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppSpacing.md)
                    }

                    Group {
                        if viewModel.isLoading, !viewModel.hasLoadedPair {
                            ProgressView()
                                .tint(AppColor.accent)
                                .frame(height: 200)
                        } else {
                            SwapCardView(
                                payToken: viewModel.payToken,
                                receiveToken: viewModel.receiveToken,
                                payAmount: viewModel.payAmount,
                                receiveAmount: viewModel.receiveAmount,
                                payBalance: viewModel.payBalance,
                                receiveBalance: viewModel.receiveBalance,
                                payValue: viewModel.payValue,
                                receiveValue: viewModel.receiveValue
                            )
                        }
                    }
                    .padding(.horizontal, AppSpacing.md)

                    SwapDetailsSection(feeText: viewModel.feeText, rateText: viewModel.rateText)
                        .padding(.horizontal, AppSpacing.md)

                    if let ins = viewModel.insights {
                        SwapPairInsightsCard(insights: ins)
                            .padding(.horizontal, AppSpacing.md)
                    }

                    SlideToSwapBar(isComplete: $swapCompleted, onCommit: {})
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.bottom, AppSpacing.xl)
                }
                .padding(.top, AppSpacing.sm)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.load() }
        .refreshable { await viewModel.refresh() }
    }
}

private struct SwapScreenBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.97, green: 0.97, blue: 0.99),
                Color(red: 0.90, green: 0.93, blue: 1.00),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

private struct SwapScreenHeader: View {
    let walletAddress: String
    let notificationCount: Int

    var body: some View {
        HStack(spacing: 0) {
            profileButton

            Spacer(minLength: AppSpacing.sm)

            walletPill

            Spacer(minLength: AppSpacing.sm)

            historyButton
        }
        .padding(.horizontal, AppSpacing.md)
    }

    private var profileButton: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 40))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(AppColor.secondaryLabel)

            Text("\(notificationCount)")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
                .padding(4)
                .background(Color.red, in: Circle())
                .offset(x: 4, y: -4)
        }
        .frame(width: 44, height: 44)
    }

    private var walletPill: some View {
        Button {} label: {
            HStack(spacing: AppSpacing.xs) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color(red: 0.2, green: 0.45, blue: 1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 28, height: 28)
                    .overlay {
                        Image(systemName: "cube.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }

                Text(walletAddress)
                    .font(AppTypography.callout.weight(.semibold))
                    .foregroundStyle(AppColor.primaryLabel)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Image(systemName: "chevron.down")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColor.secondaryLabel)
            }
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xs)
            .background(AppColor.surface, in: Capsule())
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    private var historyButton: some View {
        Button {} label: {
            Image(systemName: "doc.text.clock")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(AppColor.primaryLabel)
                .frame(width: 44, height: 44)
                .background(AppColor.surface, in: Circle())
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

private struct SwapDetailsSection: View {
    let feeText: String
    let rateText: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Button {} label: {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundStyle(AppColor.warning)
                    Text(feeText)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.secondaryLabel)
                    Image(systemName: "chevron.down")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(AppColor.tertiaryLabel)
                }
            }
            .buttonStyle(.plain)

            Button {} label: {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.caption)
                        .foregroundStyle(AppColor.secondaryLabel)
                    Text(rateText)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.secondaryLabel)
                }
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SwapPairInsightsCard: View {
    @Environment(\.openURL) private var openURL

    let insights: SwapPairInsights

    private var rows: [String] {
        [
            insights.liquidityUsd,
            insights.volume24h,
            insights.priceChange24h,
            insights.txns24h,
            insights.fdv,
            insights.marketCap,
            insights.pairAge,
            insights.activeBoosts,
            insights.labels,
            insights.socialsSummary,
            insights.ordersPayToken,
            insights.ordersReceiveToken,
            insights.schemaVersion,
        ].compactMap { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Mercado (DexScreener API)")
                .font(AppTypography.headline)
                .foregroundStyle(AppColor.primaryLabel)

            Text("\(insights.headline) · \(insights.pairAddressTruncated)")
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.secondaryLabel)

            if let u = insights.pairURL {
                Button {
                    openURL(u)
                } label: {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "safari")
                        Text("Abrir par no DexScreener")
                    }
                    .font(AppTypography.callout.weight(.semibold))
                    .foregroundStyle(AppColor.accent)
                }
                .buttonStyle(.plain)
            }

            if let w = insights.primaryWebsite {
                Button {
                    openURL(w)
                } label: {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "link")
                        Text("Website (token info)")
                    }
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.accent)
                }
                .buttonStyle(.plain)
            }

            Divider()
                .background(AppColor.secondaryLabel.opacity(0.3))

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                ForEach(Array(rows.enumerated()), id: \.offset) { _, line in
                    Text(line)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.secondaryLabel)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

private struct SlideToSwapBar: View {
    @Binding var isComplete: Bool
    var onCommit: () -> Void

    @State private var thumbOffset: CGFloat = 0

    private let thumbSize: CGFloat = 52
    private let trackHeight: CGFloat = 56
    private let horizontalPadding: CGFloat = 6

    var body: some View {
        GeometryReader { geo in
            let maxOffset = max(0, geo.size.width - thumbSize - horizontalPadding * 2)
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.black)

                HStack {
                    Spacer()
                    Image(systemName: "chevron.right.2")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.35))
                        .padding(.trailing, AppSpacing.md)
                }

                Text("Slide to Swap")
                    .font(AppTypography.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)

                slideThumb
                    .offset(x: horizontalPadding + min(thumbOffset, maxOffset))
                    .highPriorityGesture(
                        DragGesture(minimumDistance: 4)
                            .onChanged { g in
                                let x = min(max(0, g.translation.width), maxOffset)
                                thumbOffset = x
                            }
                            .onEnded { _ in
                                if thumbOffset > maxOffset * 0.72 {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                        thumbOffset = maxOffset
                                    }
                                    isComplete = true
                                    onCommit()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                                        withAnimation(.easeOut(duration: 0.25)) {
                                            thumbOffset = 0
                                        }
                                        isComplete = false
                                    }
                                } else {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        thumbOffset = 0
                                    }
                                }
                            }
                    )
            }
            .frame(height: trackHeight)
        }
        .frame(height: trackHeight)
    }

    private var slideThumb: some View {
        Circle()
            .fill(
                AngularGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.5, green: 0.9, blue: 1),
                        Color(red: 0.7, green: 0.5, blue: 1),
                        Color(red: 1, green: 0.6, blue: 0.8),
                        Color(red: 0.4, green: 0.95, blue: 0.9),
                        Color(red: 0.5, green: 0.9, blue: 1),
                    ]),
                    center: .center,
                    startAngle: .degrees(0),
                    endAngle: .degrees(360)
                )
            )
            .frame(width: thumbSize, height: thumbSize)
            .overlay {
                Image(systemName: "checkmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(AppColor.primaryLabel)
            }
            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 2)
    }
}

extension SwapToken {
    static var previewPay: SwapToken {
        SwapToken(
            symbol: "BNB",
            name: "Wrapped BNB",
            mark: "◎",
            color: Color(red: 0.96, green: 0.73, blue: 0.15),
            iconURL: URL(string: "https://tokens.pancakeswap.finance/images/0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c.png")
        )
    }

    static var previewReceive: SwapToken {
        SwapToken(
            symbol: "USDT",
            name: "Tether USD",
            mark: "T",
            color: Color(red: 0.16, green: 0.72, blue: 0.52),
            iconURL: URL(string: "https://tokens.pancakeswap.finance/images/0x55d398326f99059fF775485246999027B3197955.png")
        )
    }
}

#Preview("Swap Screen") {
    SwapScreenView(viewModel: SwapViewModel())
}
