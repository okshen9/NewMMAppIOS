//
//  CoreDataManager.swift
//  MMApp
//
//  Created by artem on 19.02.2025.
//


import CoreData
import SwiftUI

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer
    
    init() {
        persistentContainer = NSPersistentContainer(name: "YourModelName")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data loading error: \(error)")
            }
        }
    }
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Core Data save error: \(error)")
            }
        }
    }
}
