//
//  AuthNetworkHelper.swift
//  MMApp
//
//  Created by artem on 07.01.2025.
//

import Foundation



extension APIFactory {
//    var req2: URLRequest {
//        return URLRequest(url: URL("http://194.87.93.98:8080/user/auth/telegram/callback?id=165600121&first_name=Vitaliy&last_name=Baker&username=laggard_nc")!)
//    }
    
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
//            self.neshkoRequest(urlRequest, completion: { (result: Result<AuthTGRequestModel, Error>) in
//                switch result {
//                case .success(let user):
//                    print("User fetched successfully: \(user)")
////                    return user
//                case .failure(let error):
//                    print("Failed to fetch user: \(error.localizedDescription)")
////                    return nil
//                }
//            })
            
        }
        catch {
            print("Neshko Error sendTGToken")
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







//    func neshkoRequest<T: Decodable>(_ urlRequest: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        //            guard let url = endpoint.url else {
        //                completion(.failure(APIError.httpResponse))
        //                return
        //            }
        //
        //            var request = URLRequest(url: url)
        //            request.httpMethod = endpoint.method.rawValue
        //            request.allHTTPHeaderFields = endpoint.headers
        //
        //            if let parameters = endpoint.parameters {
        //                request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        //            }
//
//        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//
//            guard let data = data else {
//                completion(.failure(NetworkError.noData))
//                return
//            }
//
//            do {
//                let decodedData = try JSONDecoder().decode(T.self, from: data)
//                completion(.success(decodedData))
//            } catch {
//                completion(.failure(NetworkError.decodingFailed))
//            }
//        }
//
//        task.resume()
//    }
