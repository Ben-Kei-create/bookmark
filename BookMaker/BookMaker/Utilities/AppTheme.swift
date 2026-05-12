import SwiftUI

struct AppTheme {

    // MARK: - Colors
    struct Colors {
        // Brand colors (same in both modes)
        static let primaryBlue  = Color(red: 0.04, green: 0.52, blue: 1.00)   // #0A84FF
        static let deepBlue     = Color(red: 0.00, green: 0.34, blue: 0.85)   // #0057D8
        static let cobalt       = Color(red: 0.00, green: 0.22, blue: 0.65)   // #003BA5
        static let errorRed     = Color(red: 0.95, green: 0.23, blue: 0.23)
        static let successGreen = Color(red: 0.20, green: 0.78, blue: 0.35)

        // Dynamic colors
        static let lightBlue = Color(UIColor { t in
            t.userInterfaceStyle == .dark
                ? UIColor(red: 0.10, green: 0.18, blue: 0.30, alpha: 1)   // dark tint
                : UIColor(red: 0.90, green: 0.95, blue: 1.00, alpha: 1)   // #E6F3FF
        })
        static let paleBackground = Color(UIColor { t in
            t.userInterfaceStyle == .dark
                ? UIColor(red: 0.06, green: 0.06, blue: 0.07, alpha: 1)   // #0F0F12
                : UIColor(red: 0.96, green: 0.98, blue: 1.00, alpha: 1)   // #F5FAFF
        })
        static let textPrimary = Color(UIColor { t in
            t.userInterfaceStyle == .dark
                ? UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1)   // #F2F2F7
                : UIColor(red: 0.07, green: 0.09, blue: 0.15, alpha: 1)   // #111827
        })
        static let textSecondary = Color(UIColor { t in
            t.userInterfaceStyle == .dark
                ? UIColor(red: 0.56, green: 0.56, blue: 0.58, alpha: 1)   // #8E8E93
                : UIColor(red: 0.54, green: 0.56, blue: 0.60, alpha: 1)   // #8A8F98
        })
        static let cardBackground = Color(UIColor { t in
            t.userInterfaceStyle == .dark
                ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)   // #1C1C1E
                : UIColor.white
        })
        static let divider = Color(UIColor { t in
            t.userInterfaceStyle == .dark
                ? UIColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1)   // #2C2C2E
                : UIColor(red: 0.93, green: 0.94, blue: 0.96, alpha: 1)
        })
    }

    // MARK: - Gradients
    struct Gradients {
        static let primary = LinearGradient(
            colors: [Colors.primaryBlue, Colors.deepBlue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        static let deep = LinearGradient(
            colors: [Colors.deepBlue, Colors.cobalt],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        static let softBlue = LinearGradient(
            colors: [Colors.lightBlue, Colors.paleBackground],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Spacing
    struct Spacing {
        static let xs:   CGFloat = 4
        static let sm:   CGFloat = 8
        static let md:   CGFloat = 12
        static let lg:   CGFloat = 16
        static let xl:   CGFloat = 24
        static let xxl:  CGFloat = 32
        static let xxxl: CGFloat = 48
    }

    // MARK: - Corner Radius
    struct Radius {
        static let sm:  CGFloat = 8
        static let md:  CGFloat = 12
        static let lg:  CGFloat = 16
        static let xl:  CGFloat = 20
        static let xxl: CGFloat = 28
        static let pill: CGFloat = 999
    }

    // MARK: - Typography
    struct Typography {
        static func largeTitle(weight: Font.Weight = .bold) -> Font {
            .system(size: 34, weight: weight, design: .default)
        }
        static func title(weight: Font.Weight = .bold) -> Font {
            .system(size: 26, weight: weight, design: .default)
        }
        static func title3(weight: Font.Weight = .semibold) -> Font {
            .system(size: 20, weight: weight, design: .default)
        }
        static func body(weight: Font.Weight = .regular) -> Font {
            .system(size: 17, weight: weight, design: .default)
        }
        static func subheadline(weight: Font.Weight = .regular) -> Font {
            .system(size: 15, weight: weight, design: .default)
        }
        static func footnote(weight: Font.Weight = .regular) -> Font {
            .system(size: 13, weight: weight, design: .default)
        }
        static func caption(weight: Font.Weight = .regular) -> Font {
            .system(size: 12, weight: weight, design: .default)
        }
    }
}

// MARK: - View Modifiers

extension View {
    func appCardStyle(padding: CGFloat = AppTheme.Spacing.md) -> some View {
        self
            .padding(padding)
            .background(AppTheme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 3)
    }

    func appPrimaryButtonStyle() -> some View {
        self
            .font(AppTheme.Typography.subheadline(weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.Colors.primaryBlue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
    }

    func appSecondaryButtonStyle() -> some View {
        self
            .font(AppTheme.Typography.subheadline(weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.Colors.lightBlue)
            .foregroundColor(AppTheme.Colors.primaryBlue)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
    }

    func appInputStyle() -> some View {
        self
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.paleBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm, style: .continuous))
    }
}
