import SwiftUI
import CoreData

struct ShareExtensionView: View {
    @State private var url: String
    @State private var title: String
    @State private var notes: String = ""
    @State private var errorMessage: String?
    @State private var isSaving = false

    let onComplete: () -> Void
    let onCancel: () -> Void

    private var context: NSManagedObjectContext? {
        SharedPersistence.shared?.container.viewContext
    }

    init(initialURL: String, initialTitle: String, onComplete: @escaping () -> Void, onCancel: @escaping () -> Void) {
        _url = State(initialValue: initialURL)
        _title = State(initialValue: initialTitle)
        self.onComplete = onComplete
        self.onCancel = onCancel
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button("キャンセル") { onCancel() }
                            .foregroundColor(.secondary)

                        Spacer()

                        Text("BookMakerに追加")
                            .font(.headline)

                        Spacer()

                        Button {
                            save()
                        } label: {
                            if isSaving {
                                ProgressView().controlSize(.small)
                            } else {
                                Text("保存")
                                    .fontWeight(.semibold)
                                    .foregroundColor(isValid ? .blue : .secondary)
                            }
                        }
                        .disabled(!isValid || isSaving)
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))

                    Divider()

                    // Form
                    VStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("URL")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(url)
                                .font(.footnote)
                                .foregroundColor(.blue)
                                .lineLimit(2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(10)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("タイトル")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("サイト名（省略可）", text: $title)
                                .font(.body)
                        }
                        .padding()
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(10)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("メモ")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("メモ（省略可）", text: $notes)
                                .font(.body)
                        }
                        .padding()
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(10)

                        if let error = errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .systemGroupedBackground))
                }
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
        }
    }

    private var isValid: Bool {
        !url.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func save() {
        guard let ctx = context else {
            print("❌ ShareExtensionView: context が nil (SharedPersistence.shared が初期化失敗)")
            errorMessage = "データベースに接続できませんでした"
            return
        }
        print("✅ ShareExtensionView: context 取得成功")

        isSaving = true

        let normalized = url.hasPrefix("http") ? url : "https://" + url
        print("✅ ShareExtensionView: 正規化 URL: \(normalized)")

        let request = NSFetchRequest<NSManagedObject>(entityName: "BookmarkEntity")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "url == %@", normalized),
            NSPredicate(format: "isArchived == false")
        ])
        request.fetchLimit = 1

        if (try? ctx.fetch(request).first) != nil {
            print("⚠️ ShareExtensionView: URL は既に登録済み")
            errorMessage = "このURLは既に登録済みです"
            isSaving = false
            return
        }

        let entity = NSEntityDescription.insertNewObject(forEntityName: "BookmarkEntity", into: ctx)
        entity.setValue(UUID(), forKey: "id")
        entity.setValue(normalized, forKey: "url")
        let finalTitle = title.trimmingCharacters(in: .whitespaces).isEmpty
            ? extractDomain(from: normalized)
            : title
        entity.setValue(finalTitle, forKey: "title")
        entity.setValue(notes, forKey: "descriptionText")
        entity.setValue(Date(), forKey: "dateCreated")
        entity.setValue(Date(), forKey: "lastModified")
        entity.setValue(false, forKey: "isArchived")
        entity.setValue(false, forKey: "isFavorite")
        entity.setValue("", forKey: "tags")
        print("✅ ShareExtensionView: エンティティ作成: \(finalTitle)")

        do {
            try ctx.save()
            print("✅ ShareExtensionView: Core Data 保存成功")
            onComplete()
        } catch {
            print("❌ ShareExtensionView: 保存エラー: \(error.localizedDescription)")
            errorMessage = "保存に失敗しました: \(error.localizedDescription)"
            isSaving = false
        }
    }

    private func extractDomain(from urlString: String) -> String {
        guard let host = URLComponents(string: urlString)?.host else { return urlString }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }
}
