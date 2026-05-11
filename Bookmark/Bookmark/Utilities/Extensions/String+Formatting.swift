import Foundation

extension String {
    var isValidURL: Bool {
        return URLValidator.isValidURL(self)
    }

    func normalizedURL() -> String {
        return URLValidator.normalizeURL(self)
    }

    func extractDomain() -> String {
        return URLValidator.extractDomain(from: self)
    }
}
