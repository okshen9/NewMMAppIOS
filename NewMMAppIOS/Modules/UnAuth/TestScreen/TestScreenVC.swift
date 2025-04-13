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
                        await copyInfo()
                    }
                },
                label: {
                    Text("Копировать аналитики")
                        .foregroundStyle(Color.blue)
                })
            Button(
                action: {
                    Task {
                        await testReq()
                    }
                },
                label: {
                    Text("Проверить пользователя")
                        .foregroundStyle(Color.headerText)
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
                    Text("Очистить токен платформы (jwt)")
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
                    Text("Очистить авторизацию TG")
                        .foregroundStyle(.red)
                })
        }
        .withToast()
    }
    
    func testReq() async {
        do {
            let me = try await ServiceBuilder.shared.getProfileMe()
            print("Это я = \(me)")
        }
        catch {
            print("Ошибка testReq: \(error)")
        }
    }

    func copyInfo() async {
        do {
            UIPasteboard.general.string = ToastManager.shared.analyticStack.joined(separator: "\n")

            await ToastManager.shared.show(.init(message: "Успешно скопировано", icon: "checkmark.circle", duration: 2))
        }
        catch {
            await ToastManager.shared.show(.init(message: "ошибка копирования", icon: "xmark", duration: 2))
            print("Ошибка testReq: \(error)")
        }
    }

    
    func deletChashJWT() {
        UserRepository.shared.clearAuth()
    }
    
    func deletChashTg() {
        UserRepository.shared.clearAll()
        clearWebViewCache()
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
