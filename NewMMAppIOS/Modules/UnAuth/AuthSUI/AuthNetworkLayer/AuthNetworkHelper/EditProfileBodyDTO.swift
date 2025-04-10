//
//  EditProfileBodyDTO.swift
//  MMApp
//
//  Created by artem on 06.04.2025.
//

import Foundation

struct EditProfileBodyDTO: JSONRepresentable {
    var username: String?
    var fullName: String?
    var userProfileStatus: String?
    var userPaymentStatus: String?
    var isDeleted: Bool?
    var comment: String?
    var photoUrl: String?
    var location: String?
    var phoneNumber: String?
    var roles: [String]?
    var activitySphere: String?
    var authUserDto: AuthUserDtoResult?
    var biography: String?
}
