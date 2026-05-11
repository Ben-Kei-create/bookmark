import Foundation
import Combine

enum BookmarkSortOption: String, CaseIterable, Identifiable {
    case dateCreatedNewest = "Newest First"
    case dateCreatedOldest = "Oldest First"
    case alphabetical = "A–Z"
    case lastModified = "Last Modified"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dateCreatedNewest: return "arrow.down.circle"
        case .dateCreatedOldest: return "arrow.up.circle"
        case .alphabetical: return "textformat.abc"
        case .lastModified: return "clock"
        }
    }
}
