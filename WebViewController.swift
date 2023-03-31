import Foundation
import UIKit
import WebKit

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
                //request and upload contacts
            }
        }
    }
}
