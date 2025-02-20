//
//  KeyChainStorage.swift
//  MMApp
//
//  Created by artem on 05.01.2025.
//

import Foundation
import Security

enum KeyChainStorage: String, CaseIterable {
    case tgData = "tgData"
    case jwtToken = "jwtToken"
    case refreshToken = "refreshToken"
    
    @discardableResult
    func save(value: String) -> Bool {
        KeyChainStorage.saveToKeychain(key: self.rawValue, value: value)
    }
    
    func getData() -> String? {
        KeyChainStorage.getFromKeychain(key: self.rawValue)
    }
    
    @discardableResult
    static func saveToKeychain(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecSuccess {
            print("status: \(status)")
        }
        
        // Удаляем старую запись, если она существует
        SecItemDelete(query as CFDictionary)

        // Добавляем новую запись
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }

    
    static func getFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]

        var result: AnyObject?
        if SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
           let data = result as? Data,
           let value = String(data: data, encoding: .utf8) {
            return value
        }

        return nil
    }
    
    // MARK: Удаление ключей
    func deleteKeychainItem() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: self.rawValue
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess {
            print("Успешно удалено из Keychain")
        } else if status == errSecItemNotFound {
            print("Элемент не найден в Keychain")
        } else {
            print("Ошибка при удалении из Keychain: \(status)")
        }
    }
    
    static func deleteAllJWTKeychain() {
        KeyChainStorage.jwtToken.deleteKeychainItem()
        KeyChainStorage.refreshToken.deleteKeychainItem()
    }
    
    static func deleteAllKeychain() {
        KeyChainStorage.allCases.forEach({ $0.deleteKeychainItem() })
    }
}

enum KeyChainError: Error {
    case failedToSave
}
