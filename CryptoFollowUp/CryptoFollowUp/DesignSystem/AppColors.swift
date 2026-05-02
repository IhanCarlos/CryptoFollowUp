import SwiftUI
import UIKit

enum AppColor {
    static let background = Color(uiColor: UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.09, green: 0.09, blue: 0.12, alpha: 1)
            : UIColor(red: 0.97, green: 0.97, blue: 0.99, alpha: 1)
    })

    static let surface = Color(uiColor: UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.14, green: 0.14, blue: 0.18, alpha: 1)
            : UIColor.white
    })

    static let surfaceSecondary = Color(uiColor: UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.18, green: 0.18, blue: 0.22, alpha: 1)
            : UIColor(red: 0.94, green: 0.94, blue: 0.96, alpha: 1)
    })

    static let primaryLabel = Color(uiColor: .label)
    static let secondaryLabel = Color(uiColor: .secondaryLabel)
    static let tertiaryLabel = Color(uiColor: .tertiaryLabel)

    static let accent = Color("AccentColor")

    static let positive = Color(uiColor: .systemGreen)
    static let negative = Color(uiColor: .systemRed)
    static let warning = Color(uiColor: .systemOrange)
}
