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
                } else if viewModel.isLoading, viewModel.boosts.isEmpty {
                    ProgressView()
                } else if viewModel.boosts.isEmpty {
                    ContentUnavailableView(
                        "Sem boosts",
                        systemImage: "flame",
                        description: Text("Puxa para atualizar.")
                    )
                } else {
                    List(viewModel.boosts, id: \.self) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.tokenAddress)
                                .font(.caption.monospaced())
                                .lineLimit(1)
                            Text(item.description ?? "—")
                                .font(.subheadline)
                            Text(item.chainID.rawValue)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Token boosts")
            .toolbar {
                if viewModel.isLoading, !viewModel.boosts.isEmpty {
                    ProgressView()
                }
            }
            .task { await viewModel.load() }
            .refreshable { await viewModel.refresh() }
        }
    }
}

#Preview {
    ContentView(viewModel: TokenBoostsViewModel(tokenBoosts: PreviewTokenBoostsProvider()))
}
