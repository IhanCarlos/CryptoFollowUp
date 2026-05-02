import SwiftUI

enum AppTypography {
    static let largeTitle: Font = .system(.largeTitle, design: .rounded).weight(.bold)
    static let title: Font = .system(.title2, design: .rounded).weight(.semibold)
    static let headline: Font = .system(.headline, design: .rounded).weight(.semibold)
    static let subheadline: Font = .system(.subheadline, design: .default)
    static let body: Font = .system(.body, design: .default)
    static let callout: Font = .system(.callout, design: .default)
    static let caption: Font = .system(.caption, design: .default)
    static let caption2: Font = .system(.caption2, design: .default)
    static let captionMono: Font = .system(.caption, design: .monospaced)
    static let caption2Mono: Font = .system(.caption2, design: .monospaced)
}
