//
//  UserDefaultsStorege.swift
//  MMApp
//
//  Created by artem on 26.01.2025.
//


import Foundation

enum UserDefaultsStorege: String {
    case role = "userRole"

    func save(value: String) -> Bool {
        UserDefaultsStorege.saveToDefaults(key: self.rawValue, value: value)
    }
    
    func getData() -> String? {
        UserDefaultsStorege.getFromDefaults(key: self.rawValue)
    }
    
    static func saveToDefaults(key: String, value: String) -> Bool {
        UserDefaults.standard.set(value, forKey: key)
        return UserDefaults.standard.synchronize()
    }

    static func getFromDefaults(key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }

    func clearDefaults() {
        UserDefaults.standard.removeObject(forKey: self.rawValue)
        UserDefaults.standard.synchronize()
    }
}