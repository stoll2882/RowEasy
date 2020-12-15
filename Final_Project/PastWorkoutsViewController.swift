//
//  PastWorkoutsViewController.swift
//  Final_Project
//  Sam Toll
//  CPSC 315
//  December 14th, 2020
//
//  Created by Sam Toll on 11/29/20.
//

import Foundation
import UIKit
import CoreData

class PastWorkoutsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var workouts = [Workout]()
    
    @IBOutlet weak var tableView: UITableView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.tableView.delegate = self
        self.tableView.dataSource = self
        loadWorkouts()
        tableView.reloadData()
    }
    
    // function to retrive current directory path
    func getDirectoryPath() -> NSURL {
        let documentDirectoryPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString)
        let url = NSURL(string: documentDirectoryPath as String)!
        return url
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return workouts.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let workout = workouts[row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath) as! WorkoutCell
        
        cell.update(with: workout)
        
        cell.showsReorderControl = true
        
        return cell
    }
    
    // READ of CRUD
    func loadWorkouts() {
        // we need to make a "request" to get the Category objects
        // via the persistent container
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        // with a sql SELECT statement we usually specify a WHERE clause if we want to filter rows from the table we are selecting from
        // if we want to filter, we need to add a "predicate" to our request... we will do this later for Items
        do {
            workouts = try context.fetch(request)
            print("workouts are listed here: \(workouts)")
        }
        catch {
            print("Error loading categories \(error)")
        }
        tableView.reloadData()
    }
    
    // function to execute upon run of segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            // segue to go to detail view / controller
            if identifier == "DetailSegue" {
                if let workoutDetailVC = segue.destination as? WorkoutDetailViewController {
                    if let indexPath = tableView.indexPathForSelectedRow {
                        let workout = workouts[indexPath.row]
                        workoutDetailVC.workoutOptional = workout
                        tableView.deselectRow(at: indexPath, animated: true)
                    }
                }
            }
        }
    }
    
//    @IBAction func unwindToPastWorkoutsViewController(segue: UIStoryboardSegue) {
//        // grab the trip!!
//        if let identifier = segue.identifier {
//            // if save button is pressed...
//            if identifier == "SaveUnwindSegue" {
//                if let connectedVC = segue.source as? ConnectedViewController {
//                    if let workout = connectedVC.workoutOptional {
//                        // get the currently selected index path
//                        if let indexPath = tableView.indexPathForSelectedRow {
//                            workouts[indexPath.row] = workout
//                            tableView.deselectRow(at: indexPath, animated: true)
//                        }
//                        else {
//                            workouts.append(workout)
//                        }
//                        // force update the table view and save trips
//                        tableView.reloadData()
//                        saveWorkouts()
//                    }
//                }
//            // if cancel button is pressed
//            } else if identifier == "NoSaveUnwindSegue" {
//                print("cancel pressed")
//            }
//        }
//    }
//
    func saveWorkouts() {
        // we want to save the context "to disk" (db)
        do {
            try context.save() // like git commit
        }
        catch {
            print("Error saving workouts \(error)")
        }
        tableView.reloadData()
    }
    
    // executes when edit is pressed to change edit mode
    // (to edit mode if not on edit mode, and vice versa)
    @IBAction func editButtonPressed(_sender: UIBarButtonItem) {
        let newEditingMode = !tableView.isEditing
        tableView.setEditing(newEditingMode, animated: true)
    }
    
    
    // function to run when a row is deleted
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(workouts[indexPath.row])
            workouts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        saveWorkouts()
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let workout = workouts.remove(at: sourceIndexPath.row)
        workouts.insert(workout, at: destinationIndexPath.row)
        
        tableView.reloadData()
    }
    
}
