//
//  TgCalbackModelDTO.swift
//  MMApp
//
//  Created by artem on 26.01.2025.
//

import Foundation

struct TgCalbackModelDTO {
    let id: Int?
    let firstName: String?
    let authDate: String?
    let lastName: String?
    let userName: String?
    let photoUrl: String?
    
    init(_ items: [URLQueryItem]) {
        self.id = Int(items.first(where: {$0.name == "id" })?.value ?? .empty)
        self.firstName = items.first(where: {$0.name == "first_name" })?.value
        self.authDate = items.first(where: {$0.name == "auth_date" })?.value
        self.lastName = items.first(where: {$0.name == "last_name" })?.value
        self.userName = items.first(where: {$0.name == "username" })?.value
        self.photoUrl = items.first(where: {$0.name == "photo_url" })?.value
    }
}
