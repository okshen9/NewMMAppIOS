//
//  AuthRequestProtocol.swift
//  MMApp
//
//  Created by artem on 18.02.2025.
//

import Foundation

protocol AuthRequestProtocol {
    /// /user/auth/telegram/callback
    func sendTGTokenRequest(model: AuthQueryModel) throws -> URLRequest
    
    /// user-profile/me
    func getProfileMeRequest() throws -> URLRequest
    
    /// user-profile/me
    func refreshJWTRequest(refreshModel: RefreshBodyModel) throws -> URLRequest
    
    /// POAST/user-profile
    func createProfileRequest(profileData: CreateUserProfileBodyModel) throws -> URLRequest
    
    /// GET /userprofile/{extId}
    func getUserProfile(externalId: Int) throws -> URLRequest

    /// PATCH/user-profile
    func patchMe(profileData: EditProfileBodyDTO) throws -> URLRequest
    
    /// удаляет аккаунт - выставляет роль драфт
    func drafthMe() throws -> URLRequest
}
