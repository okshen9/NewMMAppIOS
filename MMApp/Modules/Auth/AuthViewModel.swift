//
//  AuthViewModel.swift
//  MMApp
//
//  Created by artem on 06.01.2025.
//

import Foundation

class AuthViewModel {
    private let apiFactory = APIFactory.global
    
    func validateWebRequest(url: URL?, httpBody: Data?) -> Bool {
        print("Neshko VAlWEb URL: \(url)")
        print("Neshko VAlWEb httpBody: \(httpBody)")
        guard
            let urlComponents = url?.absoluteString.components(
                separatedBy: Constants.tgAuthResult
            ),
            let tgKey = urlComponents[safe: 1],
            !tgKey.isEmpty
        else {
            return false
        }
        print("Neshko weEnd \(tgKey)")
        let tgKeyTemp = tgKey//Constants.kirilTgData
        KeyChainStorage.tgData.save(value: tgKeyTemp)
        Task {
            let test = await getProfile(tgToken: tgKeyTemp)
            print("Neshko profile \(tgKeyTemp)")
        }
        return true
    }
    
    /// Return: true - грузим новые данные, false - данные имеются
    func chekSavedKey() -> Bool {
        guard let tgData = KeyChainStorage.tgData.getData() else {
            return true
        }
        Task {
//            let test = await getProfile(tgToken: Constants.kirilTgData)
            print("Neshko profile \(tgData)")
        }
        return false
    }
    
    func getProfile(tgToken: String) async -> AuthTGRequestModel? {
        
        return await apiFactory.sendTGToken(tgToken: tgToken)
    }
}

extension AuthViewModel {
    enum Constants {
        static let queryParamQuestion = "#"
        static let tgAuthResult = "tgAuthResult="
//        static let kirilTgData = "eyJpZCI6MTIzNDU2NywiZmlyc3RfbmFtZSI6IkpvaG4iLCJsYXN0X25hbWUiOiJEb2VlIiwidXNlcm5hbWUiOiJqb2huZG9lIiwicGhvdG9fdXJsIjoiaHR0cHM6XC9cL3QubWVcL2lcL3VzZXJwaWNcLzMyMFwveXJDSERfSFJIRFZrdHBRaExIZURRNlRzWVAtMVNnbGR5dEFLWEJIbHV4MC5qcGciLCJhdXRoX2RhdGUiOiAxNjE3MTgxMTkyLCJoYXNoIjoiMWZmMmY0ZDJiNjBkMDY4YTZiN2VmNzRkYTYyZDljYjgxNzk5NDE2ZjJlMTg2MDY3ZDJhNzFkYmQ3Y2Y3NDc4YSJ9"
    }
}

