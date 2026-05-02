import SwiftUI

struct AppCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppSpacing.md)
            .background(AppColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
            .shadow(color: Color.primary.opacity(0.06), radius: 10, x: 0, y: 4)
    }
}

extension View {
    func appCard() -> some View {
        modifier(AppCardModifier())
    }
}
