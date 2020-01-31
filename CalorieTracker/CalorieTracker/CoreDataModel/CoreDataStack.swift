//
//  CoreDataStack.swift
//  CalorieTracker
//
//  Created by Lambda_School_Loaner_219 on 1/31/20.
//  Copyright © 2020 Lambda_School_Loaner_219. All rights reserved.
//

import Foundation
import Foundation
import CoreData

class CoreDataStack{
    static let shared = CoreDataStack()
    
    var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name:"CalorieTracker")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var mainContext: NSManagedObjectContext  {
        return container.viewContext
    }
    
    func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext){
        context.performAndWait {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
                context.reset()
            }
        }
    }
}
