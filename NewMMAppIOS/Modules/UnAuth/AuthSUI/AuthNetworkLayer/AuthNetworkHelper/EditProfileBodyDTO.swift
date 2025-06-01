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
    var activitySphere: String?
    var biography: String?
    var forUserHideThisExtIdUsersEvents: [Int]?
    
    init(username: String? = nil, fullName: String? = nil, userProfileStatus: String? = nil, userPaymentStatus: String? = nil, isDeleted: Bool? = nil, comment: String? = nil, photoUrl: String? = nil, location: String? = nil, phoneNumber: String? = nil, activitySphere: String? = nil, biography: String? = nil, forUserHideThisExtIdUsersEvents: [Int]? = nil) {
        self.username = username
        self.fullName = fullName
        self.userProfileStatus = userProfileStatus
        self.userPaymentStatus = userPaymentStatus
        self.isDeleted = isDeleted
        self.comment = comment
        self.photoUrl = photoUrl
        self.location = location
        self.phoneNumber = phoneNumber
        self.activitySphere = activitySphere
        self.biography = biography
        self.forUserHideThisExtIdUsersEvents = forUserHideThisExtIdUsersEvents
    }
    
    init(_ from: UserProfileResultDto) {
        self.username = from.username
        self.fullName = from.fullName
        self.userProfileStatus = from.userProfileStatus
        self.userPaymentStatus = from.userPaymentStatus
        self.isDeleted = from.isDeleted
        self.comment = from.comment
        self.photoUrl = from.photoUrl
        self.location = from.location
        self.phoneNumber = from.phoneNumber
        self.activitySphere = from.activitySphere
        self.biography = from.biography
        self.forUserHideThisExtIdUsersEvents = from.forUserHideThisExtIdUsersEvents
    }
}
