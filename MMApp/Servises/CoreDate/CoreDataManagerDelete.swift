//
//  CoreDataManagerDelete.swift
//  MMApp
//
//  Created by artem on 19.02.2025.
//

import CoreData

extension CoreDataManager {
    func deleteAll<T: NSManagedObject>(_ type: T.Type) {
        let fetchRequest = T.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            save()
        } catch {
            print("Failed to delete objects: \(error)")
        }
    }
}
