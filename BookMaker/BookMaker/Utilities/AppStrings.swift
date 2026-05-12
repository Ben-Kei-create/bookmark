import SwiftUI

struct AppStrings {
    @AppStorage("appLanguage") static var appLanguage = "en"

    static var isJapanese: Bool { appLanguage == "ja" }

    // MARK: - Tabs
    static var bookmarks: String { isJapanese ? "ブックマーク" : "Bookmarks" }
    static var settings: String { isJapanese ? "設定" : "Settings" }

    // MARK: - Bookmark List
    static var searchPlaceholder: String { isJapanese ? "ブックマークを検索…" : "Search bookmarks…" }
    static var noBookmarks: String { isJapanese ? "ブックマークなし" : "No Bookmarks" }
    static var noBookmarksDescription: String {
        isJapanese ? "お気に入りのサイトを保存してアクセスしましょう。" : "Save your favorite sites to access them anytime."
    }
    static var addYourFirstBookmark: String { isJapanese ? "最初のブックマークを追加" : "Add Your First Bookmark" }
    static var today: String { isJapanese ? "今日" : "Today" }
    static var yesterday: String { isJapanese ? "昨日" : "Yesterday" }
    static var earlier: String { isJapanese ? "以前" : "Earlier" }
    static var all: String { isJapanese ? "すべて" : "All" }
    static var favorites: String { isJapanese ? "お気に入り" : "Favorites" }

    // MARK: - Bookmark Form
    static var newBookmark: String { isJapanese ? "新しいブックマーク" : "New Bookmark" }
    static var editBookmark: String { isJapanese ? "ブックマークを編集" : "Edit Bookmark" }
    static var addNewBookmark: String { isJapanese ? "新しいブックマークを追加" : "Add New Bookmark" }
    static var cancel: String { isJapanese ? "キャンセル" : "Cancel" }
    static var save: String { isJapanese ? "保存" : "Save" }
    static var websiteURL: String { isJapanese ? "ウェブサイトのURL" : "Website URL" }
    static var title: String { isJapanese ? "タイトル" : "Title" }
    static var titlePlaceholder: String { isJapanese ? "ウェブサイト名（オプション）" : "Website name (optional)" }
    static var leaveBlankForAutoFill: String {
        isJapanese ? "空にするとサイト名を自動で入力します" : "Leave blank to use the site name automatically"
    }
    static var notes: String { isJapanese ? "メモまたは説明" : "Notes or description" }
    static var notesPlaceholder: String { isJapanese ? "メモ（オプション）" : "Notes (optional)" }
    static var visibleWithoutOpening: String {
        isJapanese ? "リンクを開かずに表示されます" : "Visible without opening the link"
    }
    static var done: String { isJapanese ? "完了" : "Done" }
    static var paste: String { isJapanese ? "貼り付け" : "Paste" }
    static var validURLRequired: String { isJapanese ? "有効なURL（例: apple.com）を入力してください" : "Enter a valid URL (e.g. apple.com)" }
    static var duplicateURL: String { isJapanese ? "このURLは既にブックマークされています" : "This URL is already bookmarked" }

    // MARK: - Bookmark Detail
    static var openInSafari: String { isJapanese ? "Safariで開く" : "Open in Safari" }
    static var copyURL: String { isJapanese ? "URLをコピー" : "Copy URL" }
    static var copied: String { isJapanese ? "コピーしました！" : "Copied!" }
    static var share: String { isJapanese ? "共有" : "Share" }
    static var edit: String { isJapanese ? "編集" : "Edit" }
    static var delete: String { isJapanese ? "削除" : "Delete" }
    static var deleteBookmark: String { isJapanese ? "ブックマークを削除しますか？" : "Delete Bookmark?" }
    static var willBeRemoved: String { isJapanese ? "は削除されます。" : " will be removed." }
    static var added: String { isJapanese ? "追加日時" : "Added" }
    static var edited: String { isJapanese ? "編集日時" : "Edited" }

    // MARK: - Settings
    static var preferences: String { isJapanese ? "設定" : "Preferences" }
    static var defaultSort: String { isJapanese ? "デフォルトソート" : "Default Sort" }
    static var languageLabel: String { isJapanese ? "言語" : "Language" }
    static var english: String { "English" }
    static var japanese: String { "日本語" }
    static var about: String { isJapanese ? "について" : "About" }
    static var version: String { isJapanese ? "バージョン" : "Version" }
    static var contactSupport: String { isJapanese ? "サポートに連絡" : "Contact Support" }

    // MARK: - Sort Options
    static var newestFirst: String { isJapanese ? "最新順" : "Newest First" }
    static var oldestFirst: String { isJapanese ? "最古順" : "Oldest First" }
    static var alphabetical: String { isJapanese ? "A～Z" : "A–Z" }
    static var lastModified: String { isJapanese ? "最近編集" : "Last Modified" }
}
