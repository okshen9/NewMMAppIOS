//
//  UserRepository.swift
//  MMApp
//
//  Created by artem on 08.02.2025.
//

import Foundation
import WebKit

actor UserRepository {
    static let shared = UserRepository()

    struct Snapshot {
        var nameStend: String?
        var authUser: AuthTGRequestModel?
        var userProfile: UserProfileResultDto?
        var tgData: String?
        var jwt: String?
        var refreshJWT: String?
        var externalId: Int?
        var roles: [String]?
    }

    private static let snapshotLock = NSLock()
    private static var _snapshot = Snapshot()

    nonisolated static var snapshot: Snapshot {
        snapshotLock.lock()
        defer { snapshotLock.unlock() }
        return _snapshot
    }

    private init() {}

    private func updateSnapshot(_ update: (inout Snapshot) -> Void) {
        Self.snapshotLock.lock()
        update(&Self._snapshot)
        Self.snapshotLock.unlock()
    }

    private var _nameStend: String?
    var nameStend: String? {
        if let nameStend = _nameStend ?? UserDefaultsStorege.nameStend.getData(String.self) {
            _nameStend = nameStend
            updateSnapshot { $0.nameStend = nameStend }
            return nameStend
        }
        return nil
    }
    func setNameStend(_ newValue: String) {
        _nameStend = newValue
        updateSnapshot { $0.nameStend = newValue }
        UserDefaultsStorege.nameStend.save(value: newValue)
    }
    func clearNameStend() {
        UserDefaultsStorege.nameStend.clearDefaults()
        _nameStend = nil
        updateSnapshot { $0.nameStend = nil }
    }

    // MARK: - authUser
    private(set) var authUser: AuthTGRequestModel?
    func setAuthUser(_ newValue: AuthTGRequestModel?) {
        authUser = newValue
        updateSnapshot { $0.authUser = newValue }

        if let jwt = newValue?.jwt {
            setJWT(jwt)
        } else {
            clearJWT()
        }

        if let refreshJWT = newValue?.refreshToken {
            setRefreshJWT(refreshJWT)
        } else {
            clearRefreshJWT()
        }
        setRoles(newValue?.authUserDto?.roles?.map { $0.rawValue })
    }

    // MARK: - UserProfile
    private(set) var userProfile: UserProfileResultDto?
    func setUserProfile(_ newValue: UserProfileResultDto?) {
        userProfile = newValue
        updateSnapshot { $0.userProfile = newValue }
        setExternalId(newValue?.externalId)
    }

    // MARK: - tgData
    private var _tgData: String?
    var tgData: String? {
        if let tgData = _tgData ?? KeyChainStorage.tgData.getData() {
            _tgData = tgData
            updateSnapshot { $0.tgData = tgData }
            return tgData
        }
        return nil
    }
    func setTGData(_ newValue: String?) {
        _tgData = newValue
        updateSnapshot { $0.tgData = newValue }
        if let tgData = newValue {
            KeyChainStorage.tgData.save(value: tgData)
        } else {
            KeyChainStorage.deleteAllKeychain()
        }
    }
    func getUrlPhotoFromTGData() -> String? {
        guard let tgData else { return nil }
        let tgJsonObject = tgData.dicFromData64() ?? [:]
        let photoString = tgJsonObject.first(where: { $0.key == "photo_url" })?.value
        return photoString as? String
    }

    // MARK: - JWT
    private var _jwt: String?
    var jwt: String? {
        if let jwt = _jwt ?? KeyChainStorage.jwtToken.getData() {
            _jwt = jwt
            updateSnapshot { $0.jwt = jwt }
            return jwt
        }
        return nil
    }
    func setJWT(_ newValue: String) {
        _jwt = newValue
        updateSnapshot { $0.jwt = newValue }
        KeyChainStorage.jwtToken.save(value: newValue)
    }
    func clearJWT() {
        KeyChainStorage.deleteAllJWTKeychain()
        _jwt = nil
        updateSnapshot { $0.jwt = nil }
    }

    // MARK: - JWT Refresh
    private var _refreshJWT: String?
    var refreshJWT: String? {
        if let jwt = _refreshJWT ?? KeyChainStorage.refreshToken.getData() {
            _refreshJWT = jwt
            updateSnapshot { $0.refreshJWT = jwt }
            return jwt
        }
        return nil
    }
    func setRefreshJWT(_ newValue: String) {
        KeyChainStorage.refreshToken.save(value: newValue)
        _refreshJWT = newValue
        updateSnapshot { $0.refreshJWT = newValue }
    }
    func clearRefreshJWT() {
        KeyChainStorage.deleteAllJWTKeychain()
        _refreshJWT = nil
        updateSnapshot { $0.refreshJWT = nil }
    }

    // MARK: - Roles and External ID
    private var _externalId: Int?
    var externalId: Int? {
        if let externalId = _externalId ?? UserDefaultsStorege.externalId.getData(Int.self) {
            _externalId = externalId
            updateSnapshot { $0.externalId = externalId }
            return externalId
        }
        return nil
    }

    func setExternalId(_ newValue: Int?) {
        _externalId = newValue
        updateSnapshot { $0.externalId = newValue }
        if let externalId = newValue {
            UserDefaultsStorege.externalId.save(value: externalId.toString)
        } else {
            UserDefaultsStorege.externalId.clearDefaults()
        }
    }

    private var _roles: [String]?
    var roles: [String]? {
        if let roles = _roles ?? UserDefaultsStorege.roles.getData([String].self) {
            _roles = roles
            updateSnapshot { $0.roles = roles }
            return _roles
        }
        return nil
    }

    func setRoles(_ newValue: [String]?) {
        _roles = newValue
        updateSnapshot { $0.roles = newValue }
        if let roles = newValue {
            UserDefaultsStorege.roles.save(value: roles)
        } else {
            UserDefaultsStorege.roles.clearDefaults()
        }
    }

    // MARK: - DELETE Repository
    func clearAll() {
        clearAuth()
        clearTGData()
        clearWebViewCache()
    }

    func clearAuth() {
        setExternalId(nil)
        setAuthUser(nil)
        setUserProfile(nil)
        clearJWT()
        clearRefreshJWT()
        setRoles(nil)
    }

    func clearTGData() {
        setTGData(nil)
    }

    func clearWebViewCache(completion: ((Bool) -> Void)? = nil) {
        Task {
            await MainActor.run {
                guard let dataStore = WKWebsiteDataStore.default() as? WKWebsiteDataStore else {
                    print("Ошибка: не удалось получить WKWebsiteDataStore")
                    completion?(false)
                    return
                }

                let websiteDataTypes = Set([
                    WKWebsiteDataTypeCookies,
                    WKWebsiteDataTypeDiskCache,
                    WKWebsiteDataTypeMemoryCache,
                    WKWebsiteDataTypeLocalStorage,
                    WKWebsiteDataTypeSessionStorage,
                    WKWebsiteDataTypeIndexedDBDatabases,
                    WKWebsiteDataTypeWebSQLDatabases
                ])

                let dateFrom = Date(timeIntervalSince1970: 0)
                dataStore.removeData(
                    ofTypes: websiteDataTypes,
                    modifiedSince: dateFrom
                ) {
                    print("All webview caches cleared.")
                    completion?(true)
                }
            }
        }
    }
}

extension UserRepository {
    func makeRefreshToken() async throws -> String {
        let networkService = ServiceBuilder.shared
        guard let refreshToken = refreshJWT,
              let authDTO = try await networkService.refreshJWT(
                refreshModel: .init(refreshToken: refreshToken)
              )
        else {
            throw APIError.failedRefreshToken
        }
        setAuthUser(authDTO)
        return authDTO.jwt
    }

    func makeRefreshAuthFormTG() async throws -> String {
        guard let tgData else {
            throw APIError.httpResponse
        }
        let networkService = ServiceBuilder.shared
        let authTGRequestModel = try await networkService.sendTGToken(model: .init(tgData: tgData))
        setAuthUser(authTGRequestModel)
        return authTGRequestModel.jwt
    }
}
