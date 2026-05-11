import Foundation

class URLValidator {
    static func isValidURL(_ string: String) -> Bool {
        let urlString = string.trimmingCharacters(in: .whitespaces)
        guard !urlString.isEmpty else { return false }

        var urlToValidate = urlString
        if !urlToValidate.lowercased().hasPrefix("http://") && !urlToValidate.lowercased().hasPrefix("https://") {
            urlToValidate = "https://" + urlToValidate
        }

        guard let url = URL(string: urlToValidate) else { return false }
        return url.host != nil
    }

    static func normalizeURL(_ string: String) -> String {
        let trimmed = string.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return "" }

        if trimmed.lowercased().hasPrefix("http://") || trimmed.lowercased().hasPrefix("https://") {
            return trimmed
        }
        return "https://" + trimmed
    }

    static func extractDomain(from url: String) -> String {
        if let url = URL(string: url), let host = url.host {
            return host.replacingOccurrences(of: "www.", with: "")
        }
        return ""
    }
}

class ClipboardService {
    static func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
    }

    static func getFromClipboard() -> String? {
        return UIPasteboard.general.string
    }
}
