import Foundation
import UIKit
import WebKit
import Contacts

class WebViewController: UIViewController {
    var webView: WKWebView!

    var url: URL?

    override func viewDidLoad() {
        super.viewDidLoad()

        webView = WKWebView(frame: view.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(webView)

        if let url = self.url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        webView.navigationDelegate = self
    }
    
    func closeWebView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveToken(_ token: String) {
        GalaxySDK.shared.saveTokenAndPlayerId(token: token)
    }

    func fetchContacts() {
        requestContactsAccess { granted in
            if granted {
                
                let store = CNContactStore()
                let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
                var contacts: [CNContact] = []
                
                let request = CNContactFetchRequest(keysToFetch: keysToFetch)
                do {
                    try store.enumerateContacts(with: request) { (contact, stop) in
                        contacts.append(contact)
                    }
                } catch {
                    print("Error fetching contacts: \(error)")
                }
                
                let contactsJSON = self.createContactsJSON(contacts: contacts)
                GalaxySDK.shared.uploadContacts(contactsObject: contactsJSON)
            }
        }
    }
    
    func createContactsJSON(contacts: [CNContact]) -> [String: Any] {
        var contactsArray: [[String: Any]] = []

        for contact in contacts {
            let fullName = "\(contact.givenName) \(contact.familyName)"
            if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                let contactDict: [String: Any] = [
                    "name": fullName,
                    "phone_number": phoneNumber
                ]
                contactsArray.append(contactDict)
            }
        }

        let contactsJSON: [String: Any] = [
            "contacts": contactsArray
        ]

        return contactsJSON
    }

    func requestContactsAccess(completion: @escaping (_ granted: Bool) -> Void) {
        let store = CNContactStore()

        store.requestAccess(for: .contacts) { granted, error in
            if let error = error {
                print("Error requesting access to contacts: \(error)")
            }
            completion(granted)
        }
    }

}


extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let urlString = webView.url?.absoluteString {
            if urlString.contains("close_window") {
                closeWebView()
            } else if urlString.contains("save_token") {
                if let components = URLComponents(string: urlString), let token = components.queryItems?.first(where: { $0.name == "token" })?.value {
                    saveToken(token)
                }
            } else if urlString.contains("request_contacts") {
                fetchContacts()
            }
        }
    }
}
