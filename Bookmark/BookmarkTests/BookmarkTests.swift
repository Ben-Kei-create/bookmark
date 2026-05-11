import XCTest
import CoreData
@testable import Bookmark

final class BookmarkServiceTests: XCTestCase {
    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        context = PersistenceController(inMemory: true).container.viewContext
    }

    override func tearDownWithError() throws {
        context = nil
    }

    func testCreateBookmark() throws {
        try BookmarkService.create(
            url: "https://apple.com",
            title: "Apple",
            description: "Test bookmark",
            in: context
        )
        let bookmarks = try context.fetch(BookmarkEntity.fetchRequest())
        XCTAssertEqual(bookmarks.count, 1)
        XCTAssertEqual(bookmarks.first?.title, "Apple")
    }

    func testDuplicateURLThrows() throws {
        try BookmarkService.create(url: "https://apple.com", title: "Apple", description: "", in: context)
        XCTAssertThrowsError(
            try BookmarkService.create(url: "https://apple.com", title: "Apple 2", description: "", in: context)
        )
    }

    func testSoftDelete() throws {
        try BookmarkService.create(url: "https://apple.com", title: "Apple", description: "", in: context)

        let all = try context.fetch(BookmarkEntity.fetchRequest())
        try BookmarkService.delete(all.first!, in: context)

        let request = BookmarkEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isArchived == false")
        let active = try context.fetch(request)
        XCTAssertEqual(active.count, 0)
    }
}

final class URLValidatorTests: XCTestCase {
    func testValidURLs() {
        XCTAssertTrue(URLValidator.isValidURL("https://apple.com"))
        XCTAssertTrue(URLValidator.isValidURL("apple.com"))
        XCTAssertTrue(URLValidator.isValidURL("http://sub.domain.com/path"))
    }

    func testInvalidURLs() {
        XCTAssertFalse(URLValidator.isValidURL(""))
        XCTAssertFalse(URLValidator.isValidURL("not a url !!"))
    }

    func testNormalization() {
        XCTAssertEqual(URLValidator.normalizeURL("apple.com"), "https://apple.com")
        XCTAssertEqual(URLValidator.normalizeURL("https://apple.com"), "https://apple.com")
    }

    func testDomainExtraction() {
        XCTAssertEqual(URLValidator.extractDomain(from: "https://www.apple.com/mac"), "apple.com")
        XCTAssertEqual(URLValidator.extractDomain(from: "https://developer.apple.com"), "developer.apple.com")
    }

    func testSortOptions() {
        let bookmarks: [BookmarkEntity] = []
        XCTAssertEqual(BookmarkSortOption.allCases.count, 4)
        XCTAssertNotNil(BookmarkSortOption(rawValue: "Newest First"))
    }
}
