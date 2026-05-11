import Foundation

struct Constants {
    struct App {
        static let name = "Bookmark"
        static let version = "1.0.0"
        static let minimumIOSVersion = "15.0"
    }

    struct UI {
        static let cornerRadius: CGFloat = 12
        static let spacing: CGFloat = 16
        static let padding: CGFloat = 16
    }

    struct URLs {
        static let supportEmail = "support@example.com"
        static let privacyPolicy = "https://example.com/privacy"
        static let termsOfService = "https://example.com/terms"
    }

    struct Bookmarks {
        static let maxTitleLength = 200
        static let maxDescriptionLength = 2000
    }
}
