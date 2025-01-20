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
    
    func sendTGToken(tgToken: String) async -> AuthTGRequestModel? {
        do {
            let helper = AuthRequestHelper.sendTGToken(tgToken)
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
    
    func neshkoRequest<T: Decodable>(_ urlRequest: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
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
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(NetworkError.decodingFailed))
            }
        }
        
        task.resume()
    }
}

// Ошибки сети
enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingFailed
}
