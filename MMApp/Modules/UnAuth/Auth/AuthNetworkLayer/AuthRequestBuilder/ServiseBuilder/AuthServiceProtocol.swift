//
//  AuthServiceProtocol.swift
//  MMApp
//
//  Created by artem on 18.02.2025.
//

import Foundation

/// Создание сервис реквеста
protocol AuthServiceProtocol {
    /// /user/auth/telegram/callback
    func sendTGToken(model: AuthQueryModel) async throws -> AuthTGRequestModel
    
    /// user-profile/me
    func getProfileMe() async throws -> UserProfileResultDto?
    
    /// user-profile/me
    func refreshJWT(refreshModel: RefreshBodyModel) async throws -> AuthTGRequestModel?
    
    /// /user-profile
    func createProfile(profileData: CreateUserProfileBodyModel) async throws -> UserProfileResultDto?
}
