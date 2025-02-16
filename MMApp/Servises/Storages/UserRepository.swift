//
//  UserRepository.swift
//  MMApp
//
//  Created by artem on 08.02.2025.
//

import Foundation

final class UserRepository {
    
    var isLoggedIn: Bool {
        userAuthDTO != nil
    }
    
    private(set) var userProfileDTO: UserProfileResultDto?
    private(set) var userAuthDTO: AuthTGRequestModel?
    
    static let shared = UserRepository()
    
    func clear() {
        userProfileDTO = nil
        userAuthDTO = nil
    }
    
    func saveUserProfileDTO(_ dto: UserProfileResultDto) {
        userProfileDTO = dto
    }
    
    func saveUserAuthDTO(_ dto: AuthTGRequestModel) {
        userAuthDTO = dto
    }
}
