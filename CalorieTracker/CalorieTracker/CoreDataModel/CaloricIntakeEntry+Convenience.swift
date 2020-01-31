//
//  CaloricIntakeEntry+Convenience.swift
//  CalorieTracker
//
//  Created by Lambda_School_Loaner_219 on 1/31/20.
//  Copyright © 2020 Lambda_School_Loaner_219. All rights reserved.
//

import Foundation
import CoreData

extension CaloricIntakeEntry {
    @discardableResult convenience init (calories: Float, time:Date, context:NSManagedObjectContext = CoreDataStack.shared.mainContext) {
       self.init(context:context)
        self.calories = calories
       self.time = time
    }
    
    @discardableResult convenience init?(caloricIntakeEntryRepresentation:CaloricIntakeEntryRepresentation,
                                         context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context:context)
        self.calories = calories
        self.time = time
    }
    
    var caloricIntakeEntryRepresentation: CaloricIntakeEntryRepresentation? {
        guard let time = time else {return nil}
        return caloricIntakeEntryRepresentation
        
    }
}
