//
//  UserDefaultsStorege.swift
//  MMApp
//
//  Created by artem on 26.01.2025.
//


import Foundation

extension UserRepository {
    enum UserDefaultsStorege: String {
        /// String
        case roles = "userRoles"
        /// Id
        case externalId = "externalId"
		/// nameStand
		case nameStend = "AppMasterMindNameStend"
        
        @discardableResult
        func save<T: Codable>(value: T) -> Bool {
            UserDefaultsStorege.saveToDefaults(key: self.rawValue, value: value)
        }
        
        func getData<T: Codable>(_: T.Type) -> T? {
            UserDefaultsStorege.getFromDefaults(key: self.rawValue, T.self)
        }
        
        @discardableResult
        static func saveToDefaults<T: Codable>(key: String, value: T) -> Bool {
            UserDefaults.standard.set(value, forKey: key)
            return UserDefaults.standard.synchronize()
        }
        
        static func getFromDefaults<T: Codable>(key: String, _: T.Type = String.self) -> T? {
            let defaults = UserDefaults.standard
            switch T.self {
            case is String.Type: return defaults.string(forKey: key) as? T
            case is Int.Type: return defaults.integer(forKey: key) as? T
            case is Bool.Type: return defaults.bool(forKey: key) as? T
            case is Double.Type: return defaults.double(forKey: key) as? T
            case is Data.Type: return defaults.data(forKey: key) as? T
            case is [String].Type: return defaults.stringArray(forKey: key) as? T
            default:
                precondition(false, "Unsupported type \(T.self) for UserDefaults")
                return nil
            }
        }
        
        func clearDefaults() {
            UserDefaults.standard.removeObject(forKey: self.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
}
