//
//  TestScreenVC.swift
//  MMApp
//
//  Created by artem on 21.01.2025.
//

import SwiftUI
import Foundation
import WebKit

struct TestScreenVC: View {
    var body: some View {
        VStack {
            Button(
                action: {
                    Task {
                        await testReq()
                    }
                },
                label: {
                    Text("Проверить пользователя")
                })
            Button(
                action: {
                    Task {
                        Task {
                            await deletChashJWT()
                        }
                    }
                },
                label: {
                    Text("Удалить jwt")
                        .foregroundStyle(.red)
                })
            Button(
                action: {
                    Task {
                        Task {
                            await deletChashTg()
                        }
                    }
                },
                label: {
                    Text("Удалить TG")
                        .foregroundStyle(.red)
                })
        }
    }
    
    func testReq() async {
        do {
            let me = try await APIFactory.global.getProfileMe()
            print("Это я = \(me)")
        }
        catch {
            print("Ошибка testReq: \(error)")
        }
    }
    
    
    func deletChashJWT() {
        KeyChainStorage.jwtToken.clearKeychain()
        UserDefaultsStorege.role.clearDefaults()
    }
    
    func deletChashTg() {
        clearWebViewCache()
        KeyChainStorage.tgData.clearKeychain()
        UserDefaultsStorege.role.clearDefaults()
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

#Preview {
    TestScreenVC()
}
