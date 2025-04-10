//
//  WebView.swift
//  TestUISwift
//
//  Created by artem on 25.03.2025.
//

import WebKit
import SwiftUI

// MARK: - WebView
struct WebView: UIViewRepresentable {
    let url: URL
    private weak var navigationDelegate: WKNavigationDelegate?
    private weak var uiDelegate: WKUIDelegate?
    private let isScrollEnabled: Bool

    init(url: URL, isScrollEnabled: Bool = true, navigationDelegate: WKNavigationDelegate? = nil, uiDelegate: WKUIDelegate? = nil) {
        self.url = url
        self.navigationDelegate = navigationDelegate
        self.uiDelegate = uiDelegate
        self.isScrollEnabled = isScrollEnabled
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = navigationDelegate
        webView.uiDelegate = uiDelegate
        webView.scrollView.isScrollEnabled = isScrollEnabled
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject {

    }
}
