//
//  RequestBuilder+Auth.swift
//  MMApp
//
//  Created by artem on 18.02.2025.
//

import Foundation

/// Создание сервис реквеста
extension APIFactory: AuthRequestProtocol {
    
    /// /user/auth/telegram/callback
    func sendTGTokenRequest(model: AuthQueryModel) throws -> URLRequest {
        let helper = AuthRequestHelper.sendTGToken(model)
        let url = try urlBuilder.buildURL(path: helper.path)

        let urlRequest = try requestBuilder.buildURLRequest(
            url: url,
            query: helper.query,
            method: helper.method,
            tokenNeccessity: .notNeeded
        )
        return urlRequest
    }
    
    /// user-profile/me
    func getProfileMeRequest() throws -> URLRequest {
            let helper = AuthRequestHelper.getUserMe
            let url = try urlBuilder.buildURL(path: helper.path)
            let urlRequest = try requestBuilder.buildURLRequest(
                url: url,
                query: helper.query,
                method: helper.method,
                tokenNeccessity: .mandatory)
        return urlRequest
    }
    
    /// user-profile/me
    func refreshJWTRequest(refreshModel: RefreshBodyModel) throws -> URLRequest {
        let helper = AuthRequestHelper.authuserRefreshJWT
        let url = try urlBuilder.buildURL(path: helper.path)
        let urlRequest = try requestBuilder.buildJSONParamsRequest(
            url: url,
            bodyModel: refreshModel,
            method: helper.method,
            tokenNeccessity: .refreshToken)
        return urlRequest
    }
    
    func createProfileRequest(profileData: CreateUserProfileBodyModel) throws -> URLRequest {
        let helper = AuthRequestHelper.createProfile
        let url = try urlBuilder.buildURL(path: helper.path)
        let urlRequest = try requestBuilder.buildJSONParamsRequest(
            url: url,
            bodyModel: profileData,
            query: helper.query,
            method: helper.method,
            tokenNeccessity: .mandatory)
        return urlRequest
    }

    func patchMe(profileData: EditProfileBodyDTO) throws -> URLRequest {
        let helper = AuthRequestHelper.patchMe
        let url = try urlBuilder.buildURL(path: helper.path)
        let urlRequest = try requestBuilder.buildJSONParamsRequest(
            url: url,
            bodyModel: profileData,
            query: helper.query,
            method: helper.method,
            tokenNeccessity: .mandatory)
        return urlRequest
    }

    func getUserProfile(externalId: Int) throws -> URLRequest {
        let helper = AuthRequestHelper.getUserProfile(externalId)
        let url = try urlBuilder.buildURL(path: helper.path)
        let urlRequest = try requestBuilder.buildURLRequest(
            url: url,
            query: helper.query,
            method: helper.method,
            tokenNeccessity: .mandatory)
        return urlRequest
    }

    
}
