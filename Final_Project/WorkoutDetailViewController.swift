//
//  WorkoutDetailViewController.swift
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

// TripDeatilViewController class, inherits from UIViewController
class WorkoutDetailViewController: UIViewController {
    
    // current trip optional
    var workoutOptional: Workout? = nil
    
    // outlets to labels on TripDetailView edited as details change for each trip
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var averageSplit: UILabel!
    @IBOutlet weak var totalTime: UILabel!
    @IBOutlet var averageStrokeRate: UILabel!
    @IBOutlet weak var distance: UILabel!
    
    // when view is loaded...
    override func viewDidLoad() {
        super.viewDidLoad()
        displayWorkout()
        // Do any additional setup after loading the view.
    }
    
    // function to display the details of whichever trip was clicked on
    func displayWorkout() {
        if let workout = workoutOptional {
            // change destination and number label
            
            averageSplit.text = "Average Split: \(workout.avgSplit ?? "None") avg /500m"
            totalTime.text = "Time: \(workout.totalTime ?? "none")"
            distance.text = "Distance: \(Int32(workout.distance)) m"
            averageStrokeRate.text = "Stroke Rate: \(workout.avgStrokeRate) s/m"

            // create date formatter to format dates
            let dateFormatter = DateFormatter();
            dateFormatter.dateStyle = .short;
            
            // get the fromatted dates
            if let date = workout.date {
                let formattedDate = dateFormatter.string(from: date)
                dateLabel.text = "\(formattedDate)"
            } else {
                dateLabel.text = "no date"
            }
            // change label text to the formatted dates
        }
    }
    
    // function to retrieve current directory path
    func getDirectoryPath() -> NSURL {
        let documentDirectoryPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString)
        let url = NSURL(string: documentDirectoryPath as String)!
        return url
    }
}
