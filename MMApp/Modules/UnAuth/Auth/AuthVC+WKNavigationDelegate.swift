//
//  AuthVC+WKNavigationDelegate.swift
//  MMApp
//
//  Created by artem on 13.01.2025.
//

import Foundation
import WebKit
import SwiftUI

extension AuthVC: WKNavigationDelegate {

    
    /// - MARK: WebView
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = webView.url else { return }
        decisionHandler(.allow)
        
        guard let tgKey = viewModel.validateWebRequest(url: navigationAction.request.url,
                                                       httpBody: navigationAction.request.httpBody),
              !tgKey.isEmpty
        else {
            return
        }
        // если tgData имеется
        webView.isHidden = true
        Task {
            viewModel.telegramCallBack(tgKey: tgKey)
        }
    }
    
    
    func webView(
        _ webView: WKWebView,
        didFinish navigation: WKNavigation!
    ) {
        print("Neshko web didFinish \(navigation) \(webView.url)")
    }

    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        print("Neshko web didFail1 \(error) \(webView.url)")
    }
    
    
    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: any Error
    ) async {
        print(" +++ Neshko web didFail2 \(error) \(webView.url)")
        guard let userInfo = (error as? NSError)?.userInfo["NSErrorFailingURLKey"]
        else { return }
        
        let urlComponents = (userInfo as? URL)?.absoluteString.components(
            separatedBy: Constants.tgAuthResult
        )
        
        guard
            let urlComponents,
            let tgKey = urlComponents[safe: 1]
        else {
            print(" === Neshko Error")
            return
        }
        let user = await viewModel.getAuthProfile(authQueryModel: AuthQueryModel(tgData: tgKey))
        print("BackView \(user)")
    }
    
    func clearWebViewCache() {
        let websiteDataTypes = Set([
            WKWebsiteDataTypeCookies,
            WKWebsiteDataTypeDiskCache,
            WKWebsiteDataTypeMemoryCache,
            WKWebsiteDataTypeLocalStorage,
            WKWebsiteDataTypeSessionStorage,
            WKWebsiteDataTypeIndexedDBDatabases,
            WKWebsiteDataTypeWebSQLDatabases
        ])
        
        let dateFrom = Date(timeIntervalSince1970: 0) // Удалить данные с самого начала времени

        WKWebsiteDataStore.default().removeData(
            ofTypes: websiteDataTypes,
            modifiedSince: dateFrom
        ) {
            print("All webview caches cleared.")
        }
    }
}
