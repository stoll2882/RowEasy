//
//  ConnectedViewController.swift
//  Final_Project
//  Sam Toll
//  CPSC 315
//  December 14th, 2020
//
//  Created by Sam Toll on 11/27/20.
//

import Foundation
import UIKit
import CoreBluetooth
import CoreData

class ConnectedViewController: UIViewController, CBPeripheralDelegate {
    
    // labels to be viewed on screen as rowing
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var strokeRateLabel: UILabel!
    @IBOutlet weak var currentSplitLabel: UILabel!
    @IBOutlet weak var avgSplitLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var driveTimeLabel: UILabel!
    @IBOutlet weak var recoveryTimeLabel: UILabel!
    
    // workout optional to hold final results after to workout if user wants to save
    var workoutOptional: Workout?
    // bool to tell code if it should keep updating values
    var notifyOn: Bool = false
    
    // values that are constantly changing and set by code as values sent by rowing machine change
    var dateVal: Date?
    var avgSplitVal: String = ""
    var totalTimeVal: String = ""
    var distanceVal: Int32 = 0
    var avgStrokeRateVal: Int32 = 0
    
    // add context and current directory for addtripviewcontroller
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    // set delegate to self and load view
    override func viewDidLoad() {
        ConnectedPeripheral.connectedPeripheral.delegate = self
        ConnectedPeripheral.connectedPeripheral.discoverServices(nil)
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print(documentsDirectoryURL)
    }
    
    // Handles discovery event
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // if discovered services... go through them and discover certain characteristics I want
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics([RowerPeripheral.serialNumberCharacteristic, RowerPeripheral.concept2Characteristic, RowerPeripheral.generalStatusCharacteristic, RowerPeripheral.generalStatusCharacteristic2, RowerPeripheral.endWorkoutSummaryCharacteristic, RowerPeripheral.strokeDataCharacteristic], for: service)
            }
        }
    }
    
    // function to turb a characteristic into a string
    func characteristicToString(_ value: Data?) -> String {
        return String(decoding: value!, as: UTF8.self);
    }

    // Handling discovery of characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // if discover characteristics go throguh them...
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                // if the characteristic is one that is constantly changing... set notify value so that we will get notified of the value every half second (500ms) - if we want that value to be different we can set it but 500ms is the default
                if characteristic.uuid == RowerPeripheral.generalStatusCharacteristic || characteristic.uuid == RowerPeripheral.generalStatusCharacteristic2 || characteristic.uuid == RowerPeripheral.endWorkoutSummaryCharacteristic || characteristic.uuid == RowerPeripheral.strokeDataCharacteristic {
                    peripheral.setNotifyValue(true, for: characteristic)
                    notifyOn = true
                } else { // otherwise, just read the value once
                    peripheral.readValue(for: characteristic)
                }
            }
        }
    }
    
    // function that takes in the array of bytes that the rowing machine sends us, and uses a data conversion to turn it into an int value
    // function for values that provide a low, mid, and high
    func get3ByteUInt(_ lower: UInt8, _ mid: UInt8, _ high: UInt8) -> UInt32 {
        let inputArray = [0, high, mid, lower];
        let data = Data(inputArray)
        return UInt32(bigEndian: data.withUnsafeBytes { $0.pointee })
    }
    // same as above function
    // function for values that just provide a low and a high
    func get2ByteUInt(_ lower: UInt8, _ high: UInt8) -> UInt32 {
        let inputArray = [0, 0, high, lower];
        let data = Data(inputArray)
        return UInt32(bigEndian: data.withUnsafeBytes { $0.pointee })
    }
    
    // function specifically to get and format the elapsed time
    func getElapsedTime(_ lower: UInt8, _ mid: UInt8, _ high: UInt8) -> String {
        // first get the raw time from the bytes to int function
        let rawTime = get3ByteUInt(lower, mid, high);
        // then since it comes back in 0.1 seconds we esentially divide by 100 to get actual seconds
        let elapsedTime: Float = (Float(rawTime) * 0.01)
        // we then seperate the seconds into minutes and seconds
        let minutes = UInt32(elapsedTime / 60)
        let seconds = UInt32(elapsedTime) % 60
        // we then format the time string how we want it to look
        var timeString: String
        if seconds < 10 {
            timeString = "\(minutes):0\(seconds)"
        } else {
            timeString = "\(minutes):\(seconds)"
        }
        return timeString;
    }
    
    // function to get and format the recovery time from the machine
    func getRecovery(_ lower: UInt8, _ high: UInt8) -> Float {
        let rawTime = get2ByteUInt(lower, high)
        let elapsedTime: Float = (Float(rawTime) * 0.01)
        return elapsedTime
    }
    
    // function to get the distance rowed (in meters)
    func getDistance(_ lower: UInt8, _ mid: UInt8, _ high: UInt8) -> UInt32 {
        let rawDistance = get3ByteUInt(lower, mid, high);
        let distance: Float = (Float(rawDistance) * 0.1)
        let intDistance: UInt32 = UInt32(distance)
        return intDistance
    }
    
    // function to return formatted split to the program
    func getSplit(_ lower: UInt8, _ high: UInt8) -> String {
        let rawSplit = get2ByteUInt(lower, high)
        let split: Float = (Float(rawSplit) * 0.01)

        let minutes = Int(split / 60)
        let seconds = Int(split) % 60
        var splitString: String
        if seconds < 10 {
            splitString = "\(minutes):0\(seconds)"
        } else {
            splitString = "\(minutes):\(seconds)"
        }
        return splitString;
    }
    
    // function that executes everytime a value updates if notify is on
    // we set notify value to true for certain characterisitcs - so this function esentially executes every 500ms when the values change and we are notified of those changes
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if notifyOn {
            if characteristic.uuid == RowerPeripheral.serialNumberCharacteristic {
                ConnectedPeripheral.serialNumber = characteristic
                print("Serial #: \(characteristicToString(characteristic.value))")
            } else if characteristic.uuid == RowerPeripheral.concept2Characteristic {
                ConnectedPeripheral.concept2 = characteristic
                print("Concept2: \(characteristicToString(characteristic.value))")
            } else if characteristic.uuid == RowerPeripheral.generalStatusCharacteristic {
                getGeneralRowingInformation(characteristic.value)
            } else if characteristic.uuid == RowerPeripheral.generalStatusCharacteristic2 {
                getGeneralRowingInformation2(characteristic.value)
            } else if characteristic.uuid == RowerPeripheral.endWorkoutSummaryCharacteristic {
                getEndSummaryCharacteristic(characteristic.value)
            } else if characteristic.uuid == RowerPeripheral.strokeDataCharacteristic {
                getStrokeDataInformation(characteristic.value)
            }
        }
    }
    
    // function to get the general rowing information characteristic (gives back an array of bytes)
    func getGeneralRowingInformation(_ value: Data?) {
        // turn data given into an array of UInt8's
        let sourceData = [UInt8] (value!)
        
        // get the workout state, and check it
        // if workout state is 10 or 11 it has been ended or terminated, and so we will set notify to false
        let workoutState = sourceData[8]
        checkWorkoutState(state: workoutState)
        
        // get rowing state and stroke state for reference
        let rowingState = sourceData[9]
        let strokeState = sourceData[10]
        
        // get elapsed time and distance and set those labels as well for the view and use of the user
        let elapsedTime = getElapsedTime(sourceData[0], sourceData[1], sourceData[2])
        let distance = getDistance(sourceData[3], sourceData[4], sourceData[5])
        
        totalTimeVal = elapsedTime
        distanceVal = Int32(distance)

        elapsedTimeLabel.text = elapsedTime
        distanceLabel.text = "\(distance)"
        
        // print values for debugging purposes
        print("elapsedTime: \(elapsedTime)")
        print("distance: \(distance)")
        print("workoutState: \(workoutState)")
        print("rowingState: \(rowingState)")
        print("strokeState: \(strokeState)")
    }
    
    // function to check the workout state, and end it if it has ended
    func checkWorkoutState(state: UInt8) {
        if state == 10 || state == 11 {
            endWorkout()
        }
    }
    
    // function to execute when the workout has ended - either by machine or by user
    func endWorkout() {
        // set the current date using setcurrentdate function and set the optional by creating a new workout with current values
        self.setCurrentDate()
        workoutOptional = createNewWorkout()
        // save the workout
        do {
            try self.context.save()
        } catch let error as NSError {
            print("Error saving workout: \(error)")
        }
        // set notify to false and pop back to bluetooth view controller incase user wants to start a new workout
        notifyOn = false
        self.navigationController?.popViewController(animated: true)
    }
    
    // get general rowing information characteristic 2 (second array of bytes)
    func getGeneralRowingInformation2(_ value: Data?) {
        let sourceData = [UInt8] (value!)

        let strokeRate = sourceData[5]
        let currentSplit = getSplit(sourceData[7], sourceData[8])
        let averageSplit = getSplit(sourceData[9], sourceData[10])
        
        avgSplitVal = averageSplit

        strokeRateLabel.text = "\(strokeRate)"
        currentSplitLabel.text = currentSplit
        avgSplitLabel.text = averageSplit

        print("strokeRate: \(strokeRate)")
        print("currentSplit: \(currentSplit)")
        print("averageSplit: \(averageSplit)")
    }
    
    // get general rowing information characteristic 3 (third array of bytes)
    func getGeneralRowingInformation3(_ value: Data?) {
        let sourceData = [UInt8] (value!)

        let strokeRate = sourceData[5]
        let currentSplit = getSplit(sourceData[7], sourceData[8])
        let averageSplit = getSplit(sourceData[9], sourceData[10])

        strokeRateLabel.text = "\(strokeRate)"
        currentSplitLabel.text = currentSplit
        avgSplitLabel.text = averageSplit
    }
    
    // get end summary information gotten when workout is over
    func getEndSummaryCharacteristic(_ value: Data?) {
        let sourceData = [UInt8] (value!)
        
        let avgStrokeRate = sourceData[10]
        avgStrokeRateVal = Int32(avgStrokeRate)
    }
    
    // function to get the recovery and drive time from the data 
    func getStrokeDataInformation(_ value: Data?) {
        let sourceData = [UInt8] (value!)
        
        let rawDriveTime = sourceData[7]
        let driveTime: Float = (Float(rawDriveTime) * 0.01)
        let formattedDriveTime = String(format: "%.2f", driveTime)
        driveTimeLabel.text = "\(formattedDriveTime)"
        
        let recoveryTime = getRecovery(sourceData[8], sourceData[9])
        let formattedRecoveryTime = String(format: "%.2f", recoveryTime)
        recoveryTimeLabel.text = "\(formattedRecoveryTime)"
    }
    
    // workout state is 1 when rowing, 11 when terminated and 10 when ended
    // rowing state is 0 when inactive, 1 when active
    // stroke state is 0 when waiting to accelerate, 4 when in recovery state, 2 when in driving state and 3 when dwelling after drive state
    @IBAction func endWorkoutPressed() {
        let alertController = UIAlertController(title: "End Workout", message: "Would you like to save your workout?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action -> Void in
            self.endWorkout()
        }))
        alertController.addAction(UIAlertAction(title: "No", style: .default, handler: { action -> Void in
            return
        }))
        // show the alert with present()
        present(alertController, animated: true)
        print("workout ended")
    }
    
    func setCurrentDate() {
        let date = Date()
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "MM/dd/yyyy";
        
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let year = calendar.component(.year, from: date)
        
        let dateString = "\(month)/\(day)/\(year)"
        let formattedDate = dateFormatter.date(from: dateString)
        dateVal = formattedDate
    }
    
    func executeSegue(identifier: String) {
        performSegue(withIdentifier: identifier, sender: self)
    }
    
    func createNewWorkout() -> Workout {
        let newWorkout = Workout(context: self.context)
        
        newWorkout.date = dateVal
        newWorkout.avgSplit = avgSplitVal
        newWorkout.distance = distanceVal
        newWorkout.totalTime = totalTimeVal
        newWorkout.avgStrokeRate = avgStrokeRateVal
        
        return newWorkout
    }
}
