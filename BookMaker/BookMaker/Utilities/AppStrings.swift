import SwiftUI

struct AppStrings {
    @AppStorage("appLanguage") static var appLanguage = "en"

    static var isJapanese: Bool { appLanguage == "ja" }

    // MARK: - App
    static var appName: String { "BookMaker" }
    static var appSubtitle: String { isJapanese ? "あなたのプライベートブックマークマネージャー" : "Your private bookmark manager" }

    // MARK: - Tabs
    static var bookmarks: String { isJapanese ? "BookMarks" : "BookMarks" }
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
//    static var languageLabel: String { isJapanese ? "言語" : "Language" }
    static var english: String { "English" }
    static var japanese: String { "日本語" }
    static var about: String { isJapanese ? "について" : "About" }
    static var version: String { isJapanese ? "バージョン" : "Version" }
    static var contactSupport: String { isJapanese ? "サポートに連絡" : "Contact Support" }
    static var generalSection: String { isJapanese ? "一般" : "General" }
    static var appearanceSection: String { isJapanese ? "言語" : "AppLanguageearance" }
    static var dataSection: String { isJapanese ? "データ" : "Data" }
    static var openLinksIn: String { isJapanese ? "リンクを開く方法" : "Open Links In" }
    static var exportBookmarks: String { isJapanese ? "エクスポート" : "Export Bookmarks" }
    static var importBookmarks: String { isJapanese ? "インポート" : "Import Bookmarks" }
    static var clearAllBookmarks: String { isJapanese ? "すべて削除" : "Clear All Bookmarks" }
    static var clearAllConfirmTitle: String { isJapanese ? "本当に削除しますか？" : "Clear All Bookmarks?" }
    static var clearAllConfirmMessage: String { isJapanese ? "すべてのブックマークが完全に削除されます。この操作は取り消せません。" : "This will permanently delete all bookmarks and cannot be undone." }
    static var privacyPolicy: String { isJapanese ? "プライバシーポリシー" : "Privacy Policy" }

    // MARK: - Empty State
    static var emptyHeadline1: String { isJapanese ? "ブックマークを、" : "Your bookmarks," }
    static var emptyHeadline2: String { isJapanese ? "いつでも手元に。" : "always within reach." }
    static var emptyDescription: String {
        isJapanese
            ? "お気に入りのサイトを保存して、整理して、いつでもアクセス。すべてデバイスに安全に保存されます。"
            : "Save your favorite sites, organize them with ease, and access them anytime — all stored privately on your device."
    }
    static var emptyTip: String {
        isJapanese
            ? "ヒント：ブックマークの ＋ をタップしてお気に入りに追加できます。"
            : "Tip: Tap ＋ on any bookmark to mark it as a favorite."
    }

    // MARK: - Privacy & Form
    static var privateSecure: String { isJapanese ? "プライベート・セキュア" : "Private & Secure" }
    static var bookmarksStayOnDevice: String {
        isJapanese ? "すべてのブックマークはデバイスに保存されます。" : "Your bookmarks stay on your device."
    }
    static var folder: String { isJapanese ? "フォルダ" : "Folder" }
    static var addTags: String { isJapanese ? "タグを追加…" : "Add tags…" }
    static var add: String { isJapanese ? "追加" : "Add" }
    static var pressReturnToSaveTag: String {
        isJapanese ? "Enterキーまたは追加ボタンでタグを保存" : "Press return or tap Add to save a tag."
    }

    // MARK: - Sort Options
    static var newestFirst: String { isJapanese ? "新しい順" : "Newest First" }
    static var oldestFirst: String { isJapanese ? "古い順" : "Oldest First" }
    static var alphabetical: String { isJapanese ? "A ～ Z" : "A–Z" }
    static var lastModified: String { isJapanese ? "最近編集した順" : "Last Modified" }
}
