import SwiftUI

struct AppTheme {
    // MARK: - Colors
    struct Colors {
        static let primaryBlue = Color(red: 0.04, green: 0.52, blue: 1.0)      // #0A84FF
        static let deepBlue = Color(red: 0.0, green: 0.35, blue: 0.85)         // #0057D8
        static let lightBlue = Color(red: 0.90, green: 0.95, blue: 1.0)        // #E6F3FF
        static let paleBackground = Color(red: 0.96, green: 0.98, blue: 1.0)   // #F5FAFF
        static let textPrimary = Color(red: 0.07, green: 0.09, blue: 0.15)     // #111827
        static let textSecondary = Color(red: 0.54, green: 0.56, blue: 0.60)   // #8A8F98
        static let cardBackground = Color.white
        static let divider = Color(red: 0.93, green: 0.94, blue: 0.96)
    }

    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    // MARK: - Radius
    struct Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
    }

    // MARK: - Shadow
    struct Shadow {
        static let light = SwiftUI.Shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        static let medium = SwiftUI.Shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
    }

    // MARK: - Button Styles
    static func primaryButton() -> some View {
        AnyView(
            Text("")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(Colors.primaryBlue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
        )
    }

    // MARK: - Card Style
    static func cardStyle() -> some ShapeStyle {
        Color.white
    }
}

// MARK: - SwiftUI Modifiers
extension View {
    func appCardStyle() -> some View {
        self
            .background(AppTheme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    func appPrimaryButtonStyle() -> some View {
        self
            .font(.headline)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.Colors.primaryBlue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
    }

    func appSecondaryButtonStyle() -> some View {
        self
            .font(.headline)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.Colors.lightBlue)
            .foregroundColor(AppTheme.Colors.primaryBlue)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
    }
}
