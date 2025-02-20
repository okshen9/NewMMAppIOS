//
//  UserProfile.swift
//  MMApp
//
//  Created by artem on 19.02.2025.
//


// UserProfile+CoreDataProperties.swift
import CoreData

@objc(UserProfile)
public class UserProfile: NSManagedObject {}

extension UserProfile {
    @NSManaged public var id: Int32
    @NSManaged public var externalId: Int32
    @NSManaged public var username: String?
    @NSManaged public var fullName: String?
    @NSManaged public var userProfileStatus: String?
    @NSManaged public var userPaymentStatus: String?
    @NSManaged public var isDeletedTarget: Bool
    @NSManaged public var creationDateTime: Date?
    @NSManaged public var lastUpdatingDateTime: Date?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var location: String?
    
    @NSManaged public var userGroup: UserGroup?
    @NSManaged public var stream: Stream?
}

// UserGroup+CoreDataProperties.swift
@objc(UserGroup)
public class UserGroup: NSManagedObject {}

extension UserGroup {
    @NSManaged public var id: Int32
    @NSManaged public var title: String?
    @NSManaged public var groupOwner: Int32
    @NSManaged public var isDeletedTarget: Bool
    @NSManaged public var creationDateTime: Date?
    @NSManaged public var lastUpdatingDateTime: Date?
    @NSManaged public var streamDto: Int32
    
    @NSManaged public var stream: Stream?
}

// Stream+CoreDataProperties.swift
@objc(Stream)
public class Stream: NSManagedObject {}

extension Stream {
    @NSManaged public var id: Int32
    @NSManaged public var title: String?
    @NSManaged public var descriptionText: String?
    @NSManaged public var dateFrom: Date?
    @NSManaged public var dateTo: Date?
    @NSManaged public var isDeletedTarget: Bool
    @NSManaged public var creationDateTime: Date?
    @NSManaged public var lastUpdatingDateTime: Date?
}

// AuthTGRequest+CoreDataProperties.swift
@objc(AuthTGRequest)
public class AuthTGRequest: NSManagedObject {}

extension AuthTGRequest {
    @NSManaged public var jwt: String?
    @NSManaged public var refreshToken: String?
    @NSManaged public var status: String?
    
    @NSManaged public var authUser: AuthUser?
}

// AuthUser+CoreDataProperties.swift
@objc(AuthUser)
public class AuthUser: NSManagedObject {}

extension AuthUser {
    @NSManaged public var id: Int32
    @NSManaged public var telegramId: String?
    @NSManaged public var authDate: Date?
    @NSManaged public var hashTarget: String?
    @NSManaged public var lastName: String?
    @NSManaged public var firstName: String?
    @NSManaged public var username: String?
    @NSManaged public var enabled: Bool
    @NSManaged public var authStatus: String?
    @NSManaged public var roles: [String]?
    @NSManaged public var photoUrl: String?
}
