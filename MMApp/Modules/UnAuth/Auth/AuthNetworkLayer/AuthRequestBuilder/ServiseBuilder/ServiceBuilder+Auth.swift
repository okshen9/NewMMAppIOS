//
//  ServiceBuilder+Auth.swift
//  MMApp
//
//  Created by artem on 18.02.2025.
//

import Foundation

/// Создание сервис реквеста
extension ServiceBuilder: AuthServiceProtocol {
    
    
    /// /user/auth/telegram/callback
    func sendTGToken(model: AuthQueryModel) async throws -> AuthTGRequestModel {
        try await performRequest {
            try apiFactory.sendTGTokenRequest(model: model)
        }
    }
    
    /// user-profile/me
    func getProfileMe() async throws -> UserProfileResultDto? {
        try await performRequest {
            try apiFactory.getProfileMeRequest()
        }
    }
    
    /// user-profile/me
    func refreshJWT(refreshModel: RefreshBodyModel) async throws -> AuthTGRequestModel? {
        try await performRequest(
            makeRequest: {
                try apiFactory.refreshJWTRequest(refreshModel: refreshModel)
            },
            allowRetry: false)
    }
    
    /// /user-profile
    func createProfile(profileData: CreateUserProfileBodyModel) async throws -> UserProfileResultDto? {
        try await performRequest {
            try apiFactory.createProfileRequest(profileData: profileData)
        }
    }
    
    func getUserProfile(externalId: Int) async throws -> UserProfileResultDto? {
        try await performRequest {
            try apiFactory.getUserProfile(externalId: externalId)
        }
    }
}
