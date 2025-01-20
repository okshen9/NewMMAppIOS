//
//  TokenStorage.swift
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
        saveToKeychain(key: self.rawValue, value: value)
    }
    
    func getData() -> String? {
        getFromKeychain(key: self.rawValue)
    }
    
    func saveToKeychain(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        ]

        // Удаляем старую запись, если она существует
        SecItemDelete(query as CFDictionary)

        // Добавляем новую запись
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }

    func getFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        ]

        var result: AnyObject?
        if SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
           let data = result as? Data,
           let value = String(data: data, encoding: .utf8) {
            return value
        }

        return nil
    }
}

enum KeyChainError: Error {
    case failedToSave
}
