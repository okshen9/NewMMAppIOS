//
//  KeyChainStorage.swift
//  MMApp
//
//  Created by artem on 05.01.2025.
//

import Foundation

import Foundation

enum KeyChainStorage: String {
    case tgData = "tgData"
    case jwtToken = "jwtToken"
    
    func save(value: String) -> Bool {
        KeyChainStorage.saveToKeychain(key: self.rawValue, value: value)
    }
    
    func getData() -> String? {
        KeyChainStorage.getFromKeychain(key: self.rawValue)
    }
    
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
    
    func clearKeychain() {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword]
        
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess {
            print("Ключи успешно очищены")
        } else {
            print("Ошибка удаления ключей из Keychain: \(status)")
        }
    }
}

enum KeyChainError: Error {
    case failedToSave
}
