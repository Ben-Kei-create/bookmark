import Foundation
import UIKit

struct URLValidator {
    static func isValidURL(_ string: String) -> Bool {
        let trimmed = string.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }

        var urlString = trimmed
        if !urlString.lowercased().hasPrefix("http://") && !urlString.lowercased().hasPrefix("https://") {
            urlString = "https://" + urlString
        }

        guard let url = URL(string: urlString) else { return false }
        return url.host != nil
    }

    static func normalizeURL(_ string: String) -> String {
        let trimmed = string.trimmingCharacters(in: .whitespaces)
        if trimmed.lowercased().hasPrefix("http://") || trimmed.lowercased().hasPrefix("https://") {
            return trimmed
        }
        return "https://" + trimmed
    }

    static func extractDomain(from urlString: String) -> String {
        guard let url = URL(string: urlString), let host = url.host else { return urlString }
        return host.replacingOccurrences(of: "www.", with: "", options: .anchored)
    }
}

struct ClipboardService {
    static func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
    }

    static func getFromClipboard() -> String? {
        UIPasteboard.general.string
    }
}
