//
//  UserInfoViewModel.swift
//  MMApp
//
//  Created by artem on 29.12.2024.
//

import Foundation
import Combine

class UserInfoViewModel {
    // MARK: - Input
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var occupation: String = ""
    @Published var city: String = ""
    
    // MARK: - Output
    @Published private(set) var isFormValid: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Publishers.CombineLatest4($firstName, $lastName, $occupation, $city)
            .map { firstName, lastName, occupation, city in
                return !firstName.isEmpty && !lastName.isEmpty && !occupation.isEmpty && !city.isEmpty
            }
            .assign(to: &$isFormValid)
    }
}
