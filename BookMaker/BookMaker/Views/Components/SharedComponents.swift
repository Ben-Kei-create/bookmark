import SwiftUI

// MARK: - PrimaryGradientButton

struct PrimaryGradientButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.sm) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                }
                Text(title)
                    .font(AppTheme.Typography.subheadline(weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .foregroundColor(.white)
            .background(AppTheme.Gradients.primary)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
            .shadow(
                color: AppTheme.Colors.primaryBlue.opacity(0.35),
                radius: 10, x: 0, y: 5
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - SearchBarView

struct SearchBarView: View {
    @Binding var text: String
    let placeholder: String
    var onFilter: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .font(.system(size: 15))

                TextField(placeholder, text: $text)
                    .font(AppTheme.Typography.subheadline())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .submitLabel(.search)

                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .font(.system(size: 14))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm + 2)
            .background(AppTheme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)

            if let onFilter {
                Button(action: onFilter) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppTheme.Colors.primaryBlue)
                        .frame(width: 42, height: 42)
                        .background(AppTheme.Colors.cardBackground)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - FilterChip

struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(AppTheme.Typography.footnote(weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? .white : AppTheme.Colors.textPrimary)
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.xs + 2)
                .background(
                    isSelected
                        ? AnyShapeStyle(AppTheme.Colors.primaryBlue)
                        : AnyShapeStyle(AppTheme.Colors.cardBackground)
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(
                        isSelected ? Color.clear : AppTheme.Colors.divider,
                        lineWidth: 1.5
                    )
                )
                .shadow(
                    color: isSelected ? AppTheme.Colors.primaryBlue.opacity(0.25) : Color.black.opacity(0.04),
                    radius: 4, x: 0, y: 2
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.18), value: isSelected)
    }
}

// MARK: - TagChip

struct TagChip: View {
    let tag: String
    var onRemove: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(AppTheme.Typography.caption(weight: .medium))
                .foregroundColor(AppTheme.Colors.primaryBlue)

            if let onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primaryBlue.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, AppTheme.Spacing.xs)
        .background(AppTheme.Colors.lightBlue)
        .clipShape(Capsule())
    }
}

// MARK: - FormCard

struct FormCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - SectionLabel

struct SectionLabel: View {
    let text: String
    let icon: String

    var body: some View {
        Label(text, systemImage: icon)
            .font(AppTheme.Typography.footnote(weight: .semibold))
            .foregroundColor(AppTheme.Colors.textPrimary)
    }
}

// MARK: - PrivacyInfoCard

struct PrivacyInfoCard: View {
    @AppStorage("appLanguage") private var appLanguage = "en"

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.lightBlue)
                    .frame(width: 38, height: 38)
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 17))
                    .foregroundColor(AppTheme.Colors.primaryBlue)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(AppStrings.privateSecure)
                    .font(AppTheme.Typography.footnote(weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Text(AppStrings.bookmarksStayOnDevice)
                    .font(AppTheme.Typography.caption())
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }

            Spacer()
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.lightBlue.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
    }
}

// MARK: - DomainIconView

struct DomainIconView: View {
    let domain: String
    var size: CGFloat = 48

    private var initial: String {
        String(domain.prefix(1)).uppercased()
    }

    private var faviconURL: URL? {
        URL(string: "https://www.google.com/s2/favicons?domain=\(domain)&sz=128")
    }

    var body: some View {
        AsyncImage(url: faviconURL) { phase in
            switch phase {
            case .success(let image):
                ZStack {
                    RoundedRectangle(cornerRadius: size * 0.26, style: .continuous)
                        .fill(AppTheme.Colors.cardBackground)
                        .frame(width: size, height: size)
                        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 1)
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * 0.65, height: size * 0.65)
                }
            default:
                ZStack {
                    RoundedRectangle(cornerRadius: size * 0.26, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.Colors.primaryBlue, AppTheme.Colors.deepBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: size, height: size)
                    Text(initial)
                        .font(.system(size: size * 0.40, weight: .bold, design: .default))
                        .foregroundColor(.white)
                }
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - BookmarkGridCell

struct BookmarkGridCell: View {
    let entity: BookmarkEntity

    private var faviconURL: URL? {
        URL(string: "https://www.google.com/s2/favicons?domain=\(entity.domain)&sz=128")
    }

    private var initial: String {
        String(entity.domain.prefix(1)).uppercased()
    }

    var body: some View {
        GeometryReader { geo in
            let size = geo.size.width
            AsyncImage(url: faviconURL) { phase in
                switch phase {
                case .success(let image):
                    ZStack {
                        RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                            .fill(AppTheme.Colors.cardBackground)
                            .shadow(color: Color.black.opacity(0.10), radius: 6, x: 0, y: 2)
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: size * 0.60, height: size * 0.60)
                    }
                default:
                    ZStack {
                        RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.Colors.primaryBlue, AppTheme.Colors.deepBlue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: AppTheme.Colors.primaryBlue.opacity(0.30), radius: 6, x: 0, y: 2)
                        Text(initial)
                            .font(.system(size: size * 0.38, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(width: size, height: size)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - SectionHeaderLabel

struct SectionHeaderLabel: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(AppTheme.Typography.caption(weight: .semibold))
            .foregroundColor(AppTheme.Colors.textSecondary)
            .tracking(0.5)
    }
}

// MARK: - FlowLayout

struct FlowLayout: Layout {
    var spacing: CGFloat = AppTheme.Spacing.sm

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let totalHeight = rows.reduce(0.0) { acc, row in
            acc + (row.map { $0.size.height }.max() ?? 0)
        } + max(0, CGFloat(rows.count - 1)) * spacing
        return CGSize(width: proposal.width ?? 0, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            let rowHeight = row.map { $0.size.height }.max() ?? 0
            for item in row {
                item.subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(item.size))
                x += item.size.width + spacing
            }
            y += rowHeight + spacing
        }
    }

    private struct SubviewItem {
        let subview: LayoutSubview
        let size: CGSize
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[SubviewItem]] {
        let maxWidth = proposal.width ?? 0
        var rows: [[SubviewItem]] = [[]]
        var rowWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width > maxWidth, !rows[rows.count - 1].isEmpty {
                rows.append([])
                rowWidth = 0
            }
            rows[rows.count - 1].append(SubviewItem(subview: subview, size: size))
            rowWidth += size.width + spacing
        }
        return rows
    }
}

// MARK: - ShareSheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uvc: UIActivityViewController, context: Context) {}
}
