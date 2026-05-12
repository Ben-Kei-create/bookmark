import Foundation

enum BookmarkSortOption: String, CaseIterable, Identifiable {
    case dateCreatedNewest = "Newest First"
    case dateCreatedOldest = "Oldest First"
    case alphabetical = "A–Z"
    case lastModified = "Last Modified"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .dateCreatedNewest: return AppStrings.newestFirst
        case .dateCreatedOldest: return AppStrings.oldestFirst
        case .alphabetical:      return AppStrings.alphabetical
        case .lastModified:      return AppStrings.lastModified
        }
    }

    var icon: String {
        switch self {
        case .dateCreatedNewest: return "arrow.down.circle"
        case .dateCreatedOldest: return "arrow.up.circle"
        case .alphabetical:      return "textformat.abc"
        case .lastModified:      return "clock"
        }
    }
}
