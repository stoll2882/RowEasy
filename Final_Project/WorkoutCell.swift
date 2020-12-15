//
//  WorkoutCell.swift
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

// class that represents one completed workout cell
class WorkoutCell: UITableViewCell {
    
    // fields on the table view cell
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet weak var metersLabel: UILabel!
    
    // show table view cell of a certain trip
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    // function to update the table view and add a table view cell for each trip
    func update(with workout: Workout) {
        // set labels for each trip
        // create date formatter to format dates
        let dateFormatter = DateFormatter();
        dateFormatter.dateStyle = .short;
        
        // get the fromatted dates
        if let date = workout.date {
            let formattedDate = dateFormatter.string(from: date)
            dateLabel.text = "Date: \(formattedDate)"
        } else {
            dateLabel.text = "no date"
        }
        
        // change label text to the formatted dates
        metersLabel.text = "\(workout.distance)m"
    }
    
    // function to get current directory path
    func getDirectoryPath() -> NSURL {
        let documentDirectoryPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString)
        let url = NSURL(string: documentDirectoryPath as String)!
        return url
    }
}
