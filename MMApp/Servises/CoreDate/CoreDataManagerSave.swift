extension CoreDataManager {
    
    func saveUserProfile(from dto: UserProfileResultDto) {
        let userProfile = UserProfile(context: context)
        userProfile.id = Int32(dto.id ?? 0)
        userProfile.externalId = Int32(dto.externalId ?? 0)
        userProfile.username = dto.username
        userProfile.fullName = dto.fullName
        userProfile.userProfileStatus = dto.userProfileStatus
        userProfile.userPaymentStatus = dto.userPaymentStatus
        userProfile.isDeleted = dto.isDeleted ?? false
        userProfile.creationDateTime = parseDate(dto.creationDateTime)
        userProfile.lastUpdatingDateTime = parseDate(dto.lastUpdatingDateTime)
        userProfile.phoneNumber = dto.phoneNumber
        userProfile.location = dto.location
        
        save()
    }
    
    func saveAuthTGRequest(from model: AuthTGRequestModel) {
        let authRequest = AuthTGRequest(context: context)
        authRequest.jwt = model.jwt
        authRequest.refreshToken = model.refreshToken
        authRequest.status = model.status
        
        if let authUserDto = model.authUserDto {
            let authUser = AuthUser(context: context)
            authUser.id = Int32(authUserDto.id ?? 0)
            authUser.telegramId = authUserDto.telegramId
            authUser.username = authUserDto.username
            authUser.roles = authUserDto.roles?.map { $0.rawValue }
            authUser.photoUrl = authUserDto.photoUrl
            
            authRequest.authUser = authUser
        }
        
        save()
    }
    
    private func parseDate(_ dateString: String?) -> Date? {
        guard let dateString else { return nil }
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString)
    }
}
