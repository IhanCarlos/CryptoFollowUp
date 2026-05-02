import SwiftUI

struct TokenIconView: View {
    let url: URL?
    var size: CGFloat = 48
    var circular: Bool = false

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            AppColor.surfaceSecondary
                            ProgressView()
                                .scaleEffect(0.7)
                                .tint(AppColor.accent)
                        }
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .modifier(TokenIconClipModifier(circular: circular))
    }

    private var placeholder: some View {
        ZStack {
            AppColor.surfaceSecondary
            Image(systemName: "photo")
                .font(.system(size: size * 0.35))
                .foregroundStyle(AppColor.tertiaryLabel)
        }
    }
}

private struct TokenIconClipModifier: ViewModifier {
    let circular: Bool

    func body(content: Content) -> some View {
        if circular {
            content
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .strokeBorder(AppColor.secondaryLabel.opacity(0.2), lineWidth: 0.5)
                }
        } else {
            content
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                        .strokeBorder(AppColor.secondaryLabel.opacity(0.2), lineWidth: 0.5)
                }
        }
    }
}

#Preview {
    TokenIconView(url: URL(string: "https://cdn.dexscreener.com/cms/images/zCdk2o2rkqr1zULB?width=64&height=64&fit=crop&quality=95&format=auto"))
        .padding()
}

#Preview("Circle") {
    TokenIconView(
        url: URL(string: "https://cdn.dexscreener.com/cms/images/zCdk2o2rkqr1zULB?width=64&height=64&fit=crop&quality=95&format=auto"),
        size: 36,
        circular: true
    )
    .padding()
}
