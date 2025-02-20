extension CoreDataManager {
    
    func fetchUserProfiles() -> [UserProfile] {
        let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch UserProfiles: \(error)")
            return []
        }
    }
    
    func fetchAuthRequests() -> [AuthTGRequest] {
        let request: NSFetchRequest<AuthTGRequest> = AuthTGRequest.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch AuthTGRequests: \(error)")
            return []
        }
    }
}
