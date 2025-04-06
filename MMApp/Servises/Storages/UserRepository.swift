//
//  UserRepository.swift
//  MMApp
//
//  Created by artem on 08.02.2025.
//

import Foundation
import WebKit

//actor
class UserRepository {
    static let shared = UserRepository()
    
    // MARK: - authUser
    private(set) var authUser: AuthTGRequestModel?
    func setAuthUser(_ newValue: AuthTGRequestModel?) {
        authUser = newValue
        guard let newValue = newValue
        else {
            print("Neshko error setAuthUser")
            return
        }

        let jwt = KeyChainStorage.jwtToken.save(value: newValue.jwt)
        let ref = KeyChainStorage.refreshToken.save(value: newValue.refreshToken)
        
        print("Neshko Refresh jwt: \(jwt) Refresh ref: \(ref)")
    }
    
    // MARK: - UserProfile
    private(set) var userProfile: UserProfileResultDto?
    func setUserProfile(_ newValue: UserProfileResultDto?) {
        userProfile = newValue
        setExternalId(newValue?.externalId)
    }
    
    // MARK: - tgData
    private var _tgData: String?
    var tgData: String? {
        get {
            if let tgData = _tgData ?? KeyChainStorage.tgData.getData() {
                _tgData = tgData
                return tgData
            }
            return nil
        }
    }
    
    func setTGData(_ newValue: String?) {
        _tgData = newValue
        if let tgData = newValue {
            KeyChainStorage.tgData.save(value: tgData)
        } else {
            KeyChainStorage.deleteAllKeychain()
        }
    }


    // MARK: - JWT
    private var _jwt: String?
    var jwt: String? {
        get {
            if let jwt = _jwt ?? KeyChainStorage.jwtToken.getData() {
                _jwt = jwt
                return jwt
            }
            return nil
        }
    }
    
    func setJWT(_ newValue: String?) {
        _jwt = newValue
        if let jwt = newValue {
            KeyChainStorage.jwtToken.save(value: jwt)
        } else {
            KeyChainStorage.deleteAllJWTKeychain()
        }
    }
    
    private var _refreshJWT: String?
    var refreshJWT: String? {
        get {
            if let jwt = _refreshJWT ?? KeyChainStorage.refreshToken.getData() {
                _refreshJWT = jwt
                return jwt
            }
            return nil
        }
    }
    
    func setRefreshJWT(_ newValue: String?) {
        _refreshJWT = newValue
        if let jwt = newValue {
            KeyChainStorage.refreshToken.save(value: jwt)
        } else {
            KeyChainStorage.deleteAllJWTKeychain()
        }
    }
    
    // MARK: - Token Refresh
    func makeRefreshToken() async throws -> String {
        let networkService = ServiceBuilder.shared
        print("Old JWT: \(String(describing: jwt))")
        guard let refreshToken = refreshJWT,
//              let authUser = authUser?.authUserDto,
//              let userProfile = userProfile,
//              let refreshToken = self.authUser?.refreshToken,
//              let userId = userProfile.externalId,
//              let roles = authUser.roles,
              let authDTO = try await networkService.refreshJWT (
                refreshModel: .init(
//                    roles: roles,
//                    authUserId: userId,
                    refreshToken: refreshToken
                )
              )
        else {
            throw APIError.failedRefreshToken
        }
        print("New JWT from refresh: \(String(describing: authDTO.jwt))")
        setAuthUser(authDTO)
        print("New JWT from keychain: \(String(describing: jwt))")
        return authDTO.jwt
    }


    // MARK: - Roles and External ID
    private var _externalId: Int?
    var externalId: Int? {
        get {
            if let externalId = _externalId ?? UserDefaultsStorege.externalId.getData(Int.self) {
                _externalId = externalId
                return externalId
            }
            return nil
        }
    }
    
    func setExternalId(_ newValue: Int?) {
        _externalId = newValue
        if let externalId = newValue {
            UserDefaultsStorege.externalId.save(value: externalId.toString)
        } else {
            UserDefaultsStorege.externalId.clearDefaults()
        }
    }
    
    private var _roles: [String]?
    var roles: [String]? {
        get {
            if let roles = _roles ?? UserDefaultsStorege.roles.getData([String].self) {
                _roles = roles
                return _roles
            }
            return nil
        }
    }
    
    func setRoles(_ newValue: [String]?) {
        _roles = newValue
        if let roles = newValue {
            UserDefaultsStorege.roles.save(value: roles)
        } else {
            UserDefaultsStorege.roles.clearDefaults()
        }
    }


    // MARK: - Clear
    func clearAll() {
        clearAuth()
        clearTGData()
        clearWebViewCache()
    }
    
    func clearAuth() {
        setExternalId(nil)
        setAuthUser(nil)
        setUserProfile(nil)
        setJWT(nil)
        setRefreshJWT(nil)
        setRoles(nil)
    }
    
    func clearTGData() {
        setTGData(nil)
    }

    func clearWebViewCache() {
        let websiteDataTypes = Set([
            WKWebsiteDataTypeCookies,
            WKWebsiteDataTypeDiskCache,
            WKWebsiteDataTypeMemoryCache,
            WKWebsiteDataTypeLocalStorage,
            WKWebsiteDataTypeSessionStorage,
            WKWebsiteDataTypeIndexedDBDatabases,
            WKWebsiteDataTypeWebSQLDatabases
        ])

        let dateFrom = Date(timeIntervalSince1970: 0) // Удалить данные с самого начала времени

        WKWebsiteDataStore.default().removeData(
            ofTypes: websiteDataTypes,
            modifiedSince: dateFrom
        ) {
            print("All webview caches cleared.")
        }
    }
}
