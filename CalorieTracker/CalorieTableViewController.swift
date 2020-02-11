//
//  CalorieTableViewController.swift
//  CalorieTracker
//
//  Created by Lambda_School_Loaner_219 on 1/31/20.
//  Copyright © 2020 Lambda_School_Loaner_219. All rights reserved.
//

import UIKit
import SwiftChart
import CoreData

class CalorieTableViewController: UITableViewController {

    @IBOutlet private var chartView: Chart!
    
    //MARK: - PROPERTIES
    var chartHasLoaded = false
    let chartSeries = ChartSeries([])
    let calorieController = CaloricIntakeEntryController()
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter 
    }
    
    lazy var fetchResultsController: NSFetchedResultsController<CaloricIntakeEntry> = {
     let fetchRequest: NSFetchRequest<CaloricIntakeEntry> = CaloricIntakeEntry.fetchRequest()
     fetchRequest.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
     let moc = CoreDataStack.shared.mainContext
     let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
     
     frc.delegate = self
     do {
         try frc.performFetch()
     } catch {
         print("error during fetching: \(error.localizedDescription)")
     }
     return frc
 }()
    
    private func presentCalorieEntryAlert() {
        let alert = UIAlertController(title: "Add Calorie Intake",
                                      message: "Enter amount of calories in the field",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField { textField in
            textField.placeholder = "Calories"
        }
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { _ in
            if let caloriesString = alert.textFields?.first?.text,
                !caloriesString.isEmpty,
                let calories = Float(caloriesString) {
                self.calorieController.createEntry(calories: calories, time: Date())
                let data = self.calorieController.inputForSeries(for: calories)
                self.chartSeries.data.append(data)
                NotificationCenter.default.post(name: .calorieEntryAdded, object: self)
                self.dismiss(animated: true)
            }
        }))
        
        self.present(alert, animated: true)
        
        
    }
               
    
    
    
    
    override func viewDidLoad() {
           super.viewDidLoad()
           NotificationCenter.default.addObserver(self, selector: #selector(updateViews), name: .calorieEntryAdded, object: nil)
           updateViews()
       }
       
       @objc func updateViews() {
           tableView.reloadData()
           
           chartSeries.area = true
           chartSeries.color = ChartColors.redColor()
           if !chartHasLoaded {
               loadFromCoreData()
           }
       
           chartView.add(chartSeries)
          
       }
       
       
       private func loadFromCoreData() {
           guard let entries = fetchResultsController.fetchedObjects else { return }
           for entry in entries {
               let data = self.calorieController.inputForSeries(for: entry.calories)
               self.chartSeries.data.append(data)
           }
           chartHasLoaded = true
       }
       
       @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        presentCalorieEntryAlert()
       }

    // MARK: - Table view data source

  

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
       fetchResultsController.sections?[section].numberOfObjects ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChartCell", for: indexPath)

        cell.textLabel?.text = "calories: \(fetchResultsController.object(at: indexPath).calories)"
        
        let dateString = dateFormatter.string(from: fetchResultsController.object(at: indexPath).time ?? Date())
        cell.detailTextLabel?.text = dateString 
        

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

        }

extension CalorieTableViewController: NSFetchedResultsControllerDelegate {
func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
tableView.beginUpdates()
}
func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
tableView.endUpdates()
}
func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
didChange sectionInfo: NSFetchedResultsSectionInfo,
atSectionIndex sectionIndex: Int,
for type: NSFetchedResultsChangeType) {
switch type {
case .insert:
tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
case .delete:
tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
default:
break
}
}
func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
didChange anObject: Any,
at indexPath: IndexPath?,
for type: NSFetchedResultsChangeType,
newIndexPath: IndexPath?) {
switch type {
case .insert:
guard let newIndexPath = newIndexPath else { return }
tableView.insertRows(at: [newIndexPath], with: .automatic)
case .update:
guard let indexPath = indexPath else { return }
tableView.reloadRows(at: [indexPath], with: .automatic)
case .move:
guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { return }
tableView.deleteRows(at: [oldIndexPath], with: .automatic)
tableView.insertRows(at: [newIndexPath], with: .automatic)
case .delete:
guard let indexPath = indexPath else { return }
tableView.deleteRows(at: [indexPath], with: .automatic)
default:
break
}
}
}

extension Notification.Name {
    static var calorieEntryAdded = Notification.Name("calorieEntryAdded")
}
