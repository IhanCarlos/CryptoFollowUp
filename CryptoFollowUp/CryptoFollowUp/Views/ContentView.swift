import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: TokenBoostsViewModel

    var body: some View {
        NavigationStack {
            Group {
                if let message = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Não foi possível carregar",
                        systemImage: "wifi.exclamationmark",
                        description: Text(message)
                    )
                    .foregroundStyle(AppColor.secondaryLabel)
                } else if viewModel.isLoading, viewModel.boosts.isEmpty {
                    ProgressView()
                        .tint(AppColor.accent)
                } else if viewModel.boosts.isEmpty {
                    ContentUnavailableView(
                        "Sem boosts",
                        systemImage: "flame",
                        description: Text("Puxa para atualizar.")
                    )
                    .foregroundStyle(AppColor.secondaryLabel)
                } else {
                    List(viewModel.boosts, id: \.self) { item in
                        HStack(alignment: .center, spacing: AppSpacing.sm) {
                            TokenIconView(url: item.tokenIconURL)
                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                Text(item.tokenAddress)
                                    .font(AppTypography.captionMono)
                                    .foregroundStyle(AppColor.primaryLabel)
                                    .lineLimit(1)
                                Text(item.description ?? "—")
                                    .font(AppTypography.subheadline)
                                    .foregroundStyle(AppColor.primaryLabel)
                                Text(item.chainID.rawValue)
                                    .font(AppTypography.caption2)
                                    .foregroundStyle(AppColor.tertiaryLabel)
                            }
                        }
                        .padding(.vertical, AppSpacing.xs)
                        .listRowBackground(AppColor.surface)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColor.background)
            .navigationTitle("Token boosts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if viewModel.isLoading, !viewModel.boosts.isEmpty {
                    ProgressView()
                        .tint(AppColor.accent)
                }
            }
            .task { await viewModel.load() }
            .refreshable { await viewModel.refresh() }
        }
        .tint(AppColor.accent)
    }
}

#Preview {
    ContentView(viewModel: TokenBoostsViewModel(tokenBoosts: PreviewTokenBoostsProvider()))
}
