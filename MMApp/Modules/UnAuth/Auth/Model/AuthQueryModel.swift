//
//  AuthQueryModel.swift
//  MMApp
//
//  Created by artem on 07.01.2025.
//

import Foundation

struct AuthQueryModel: QueryItemsRepresentable {
    
    var tgQueryitems = [URLQueryItem]()
    
    init(tgData: String) {
        let tgJsonObject = tgData.dicFromData64() ?? [:]
        tgJsonObject.forEach({
            tgQueryitems.appendOptinal(key: $0.key, value: $0.value)
        })
    }
    
    func queryItems() -> [URLQueryItem] {
        return tgQueryitems
    }
    
    func getTgCallBackModelDTO() -> TgCalbackModelDTO {
        return TgCalbackModelDTO(tgQueryitems)
    }
    
    /// ТГ токен
//    let id: Int?
//    let firstName: String?
//    let hash: String?
//    let authDate: String?
//    let lastName: String?
//    let userName: String?
//    let photoUrl: String?

//    func queryItems() -> [URLQueryItem] {
//        var items = [URLQueryItem]()
//
//        items.appendOptinal(key: Constants.id, value: id?.toString)
//        items.appendOptinal(key: Constants.firstName, value: firstName)
//        items.appendOptinal(key: Constants.hash, value: hash)
//        items.appendOptinal(key: Constants.authDate, value: authDate)
//        items.appendOptinal(key: Constants.lastName, value: lastName)
//        items.appendOptinal(key: Constants.userName, value: userName)
//        items.appendOptinal(key: Constants.photoUrl, value: photoUrl)
//
//        return items
//    }
}

//private extension AuthQueryModel {
//    // MARK: - Constants
//
//    enum Constants {
//        static let id = "id"
//        static let firstName = "first_name"
//        static let hash = "hash"
//        static let authDate = "auth_date"
//        static let lastName = "last_name"
//        static let userName = "username"
//        static let photoUrl = "photo_url"
//    }
//}

fileprivate extension Array<URLQueryItem> {
    mutating func appendOptinal(key: String, value: Any?) {
        if let value = value as? String {
            self.append(URLQueryItem(name: key, value: value))
        } else if let valueInt = value as? Int {
            let valueStr = String(valueInt)
            self.append(URLQueryItem(name: key, value: valueStr))
        }
    }
}
