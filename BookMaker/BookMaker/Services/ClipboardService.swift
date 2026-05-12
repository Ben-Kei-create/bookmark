import UIKit

struct ClipboardService {
    static func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
    }

    static func getFromClipboard() -> String? {
        UIPasteboard.general.string
    }
}
