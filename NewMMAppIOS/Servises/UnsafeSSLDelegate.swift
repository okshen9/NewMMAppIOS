//
//  UnsafeSSLDelegate.swift
//  NewMMAppIOS
//
//  Created by artem on 03.05.2025.
//


import Foundation

class UnsafeSSLDelegate: NSObject, URLSessionDelegate {
    
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.host == "45.141.102.197" else {
            // Для других доменов — стандартная проверка
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        // Для нужного домена — пропускаем проверку SSL
        if let trust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: trust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}