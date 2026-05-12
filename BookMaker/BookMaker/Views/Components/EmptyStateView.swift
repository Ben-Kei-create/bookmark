import SwiftUI

struct EmptyStateView: View {
    let action: () -> Void
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: AppTheme.Spacing.xl) {
                illustration
                    .scaleEffect(appeared ? 1 : 0.92)
                    .opacity(appeared ? 1 : 0)

                headlineBlock
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)

                VStack(spacing: AppTheme.Spacing.sm) {
                    PrimaryGradientButton("Add Your First Bookmark", icon: "plus", action: action)
                    tipCard
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
            }
            .padding(.horizontal, AppTheme.Spacing.xl)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.78).delay(0.05)) {
                appeared = true
            }
        }
    }

    // MARK: - Illustration

    private var illustration: some View {
        ZStack {
            // Outer pale ring
            Circle()
                .fill(AppTheme.Colors.lightBlue.opacity(0.5))
                .frame(width: 136, height: 136)

            // Inner gradient circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppTheme.Colors.lightBlue,
                            AppTheme.Colors.primaryBlue.opacity(0.18)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 60
                    )
                )
                .frame(width: 108, height: 108)

            // Bookmark icon
            Image(systemName: "bookmark.fill")
                .font(.system(size: 52, weight: .semibold))
                .foregroundStyle(AppTheme.Gradients.primary)
                .symbolRenderingMode(.hierarchical)

            // Decorative sparkles
            sparkle(offset: CGSize(width: 52, height: -42), size: 10, opacity: 0.55)
            sparkle(offset: CGSize(width: -50, height: -28), size: 7, opacity: 0.38)
            sparkle(offset: CGSize(width: 38, height: 50), size: 8, opacity: 0.42)
        }
    }

    @ViewBuilder
    private func sparkle(offset: CGSize, size: CGFloat, opacity: Double) -> some View {
        Image(systemName: "sparkle")
            .font(.system(size: size))
            .foregroundColor(AppTheme.Colors.primaryBlue)
            .opacity(opacity)
            .offset(offset)
    }

    // MARK: - Headline

    private var headlineBlock: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            VStack(spacing: 2) {
                Text("Your bookmarks,")
                    .font(AppTheme.Typography.title(weight: .bold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Text("always within reach.")
                    .font(AppTheme.Typography.title(weight: .bold))
                    .foregroundColor(AppTheme.Colors.primaryBlue)
            }
            .multilineTextAlignment(.center)

            Text("Save your favorite sites, organize them with ease, and access them anytime — all stored privately on your device.")
                .font(AppTheme.Typography.subheadline())
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
    }

    // MARK: - Tip

    private var tipCard: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.Colors.primaryBlue)
            Text("Tip: Tap ⭐ on any bookmark to mark it as a favorite.")
                .font(AppTheme.Typography.caption(weight: .medium))
                .foregroundColor(AppTheme.Colors.textSecondary)
            Spacer()
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.lightBlue.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
    }
}

#Preview {
    EmptyStateView {}
        .background(AppTheme.Colors.paleBackground)
}
