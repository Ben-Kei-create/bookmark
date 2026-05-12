import UIKit
import SwiftUI
import CoreData
import UniformTypeIdentifiers

class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        extractSharedURL { [weak self] url, title in
            DispatchQueue.main.async {
                self?.presentShareView(url: url, title: title)
            }
        }
    }

    private func extractSharedURL(completion: @escaping (String, String) -> Void) {
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else {
            completion("", "")
            return
        }

        for item in items {
            for provider in (item.attachments ?? []) {
                if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    provider.loadItem(forTypeIdentifier: UTType.url.identifier) { data, _ in
                        let urlString = (data as? URL)?.absoluteString ?? ""
                        let titleString = item.attributedContentText?.string ?? ""
                        completion(urlString, titleString)
                    }
                    return
                }
                if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                    provider.loadItem(forTypeIdentifier: UTType.plainText.identifier) { data, _ in
                        let text = data as? String ?? ""
                        completion(text, "")
                    }
                    return
                }
            }
        }
        completion("", "")
    }

    private func presentShareView(url: String, title: String) {
        let shareView = ShareExtensionView(initialURL: url, initialTitle: title) { [weak self] in
            self?.extensionContext?.completeRequest(returningItems: nil)
        } onCancel: { [weak self] in
            self?.extensionContext?.cancelRequest(withError: NSError(
                domain: "BookMaker", code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Cancelled"]
            ))
        }

        let hostingVC = UIHostingController(rootView: shareView)
        hostingVC.view.backgroundColor = .clear

        addChild(hostingVC)
        view.addSubview(hostingVC.view)
        hostingVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        hostingVC.didMove(toParent: self)
    }
}
