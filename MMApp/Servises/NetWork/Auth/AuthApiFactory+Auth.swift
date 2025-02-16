//
//  AuthNetworkHelper.swift
//  MMApp
//
//  Created by artem on 07.01.2025.
//

import Foundation

extension APIFactory {
    
    /// /user/auth/telegram/callback
    func sendTGToken(authQueryModel: AuthQueryModel) async -> AuthTGRequestModel? {
        do {
            let helper = AuthRequestHelper.sendTGToken(authQueryModel)
            let url = try urlBuilder.buildURL(path: helper.path)
            let urlRequest = try requestBuilder.buildURLRequest(
                url: url,
                query: helper.query,
                method: helper.method)
            return try await dataTaskBuilder.buildDataTask(urlRequest).response
        }
        catch {
            print("Neshko \(error) sendTGToken")
            return nil
        }
    }
    
    /// user-profile/me
    func getProfileMe() async throws -> UserProfileResultDto? {
            let helper = AuthRequestHelper.getUserMe
            let url = try urlBuilder.buildURL(path: helper.path)
            let urlRequest = try requestBuilder.buildURLRequest(
                url: url,
                query: helper.query,
                method: helper.method,
                tokenNeccessity: .mandatory)
            let tempResult: UserProfileResultDto = try await dataTaskBuilder.buildDataTask(urlRequest).response
            return tempResult
    }
    
    /// user-profile/me
    func refreshJWT(refreshModel: RefreshBodyModel) async -> AuthTGRequestModel? {
        do {
            let helper = AuthRequestHelper.getUserMe
            let url = try urlBuilder.buildURL(path: helper.path)
            let urlRequest = try requestBuilder.buildJSONParamsRequest(
                url: url,
                bodyModel: refreshModel,
                method: helper.method,
                tokenNeccessity: .refreshToken)
            let tempResult: AuthTGRequestModel = try await dataTaskBuilder.buildDataTask(urlRequest).response
            return tempResult
        }
        catch {
            print("Neshko Error getMe")
            return nil
        }
    }
    
    func createProfile(profileData: CreateUserProfileBodyModel) async -> UserProfileResultDto? {
        do {
            let helper = AuthRequestHelper.createProfile
            let url = try urlBuilder.buildURL(path: helper.path)
            let urlRequest = try requestBuilder.buildJSONParamsRequest(
                url: url,
                bodyModel: profileData,
                query: helper.query,
                method: helper.method,
                tokenNeccessity: .mandatory)
            let tempResult: UserProfileResultDto = try await dataTaskBuilder.buildDataTask(urlRequest).response
            return tempResult
        }
        catch {
            print("Neshko Error createProfile")
            return nil
        }
    }
}

// Ошибки сети
enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingFailed
}


