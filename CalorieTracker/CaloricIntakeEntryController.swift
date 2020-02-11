//
//  CalorieIntakeEntryController.swift
//  CalorieTracker
//
//  Created by Lambda_School_Loaner_219 on 1/31/20.
//  Copyright © 2020 Lambda_School_Loaner_219. All rights reserved.
//

import Foundation
import SwiftChart

class CaloricIntakeEntryController {
    var xAxisInput: Double = 0
    
    func createEntry(calories: Float, time:Date) {
      CaloricIntakeEntry(calories:calories, time:time)
        do {
            try CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
        } catch {
            print("Error saving entry: \(error)") // replace with debug description or NSLOG
        }
         
    }
                                                // x, and y for series
    func inputForSeries(for calories: Float) -> (Double, Double) {
        let input = (xAxisInput, Double(calories))
        xAxisInput += 1
        return input
    }
}
