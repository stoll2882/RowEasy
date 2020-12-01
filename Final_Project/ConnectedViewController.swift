//
//  ConnectedViewController.swift
//  Final_Project
//
//  Created by Sam Toll on 11/27/20.
//

import Foundation
import UIKit
import CoreBluetooth
import CoreData

class ConnectedViewController: UIViewController, CBPeripheralDelegate {
    
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var strokeRateLabel: UILabel!
    @IBOutlet weak var currentSplitLabel: UILabel!
    @IBOutlet weak var avgSplitLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var workoutOptional: Workout?
    var notifyOn: Bool = false
    
    var dateVal: Date?
    var avgSplitVal: String = ""
    var totalTimeVal: String = ""
    var distanceVal: Int32 = 0
    var avgStrokeRateVal: Int32 = 0
    
    // add context and current directory for addtripviewcontroller
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    override func viewDidLoad() {
        ConnectedPeripheral.connectedPeripheral.delegate = self
        ConnectedPeripheral.connectedPeripheral.discoverServices(nil)
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print(documentsDirectoryURL)
    }
    
    // Handles discovery event
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics([RowerPeripheral.serialNumberCharacteristic, RowerPeripheral.concept2Characteristic, RowerPeripheral.generalStatusCharacteristic, RowerPeripheral.generalStatusCharacteristic2, RowerPeripheral.endWorkoutSummaryCharacteristic], for: service)
            }
        }
    }
    
    func characteristicToString(_ value: Data?) -> String {
        return String(decoding: value!, as: UTF8.self);
    }

    // Handling discovery of characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == RowerPeripheral.generalStatusCharacteristic || characteristic.uuid == RowerPeripheral.generalStatusCharacteristic2 || characteristic.uuid == RowerPeripheral.endWorkoutSummaryCharacteristic {
                    peripheral.setNotifyValue(true, for: characteristic)
                    notifyOn = true
                } else {
                    peripheral.readValue(for: characteristic)
                }
            }
        }
    }

    func get3ByteUInt(_ lower: UInt8, _ mid: UInt8, _ high: UInt8) -> UInt32 {
        let inputArray = [0, high, mid, lower];
        let data = Data(inputArray)
        return UInt32(bigEndian: data.withUnsafeBytes { $0.pointee })
    }

    func get2ByteUInt(_ lower: UInt8, _ high: UInt8) -> UInt32 {
        let inputArray = [0, 0, high, lower];
        let data = Data(inputArray)
        return UInt32(bigEndian: data.withUnsafeBytes { $0.pointee })
    }
    
    func getElapsedTime(_ lower: UInt8, _ mid: UInt8, _ high: UInt8) -> String {
        let rawTime = get3ByteUInt(lower, mid, high);
        let elapsedTime: Float = (Float(rawTime) * 0.01)
        let minutes = UInt32(elapsedTime / 60)
        let seconds = UInt32(elapsedTime) % 60
        var timeString: String
        if seconds < 10 {
            timeString = "\(minutes):0\(seconds)"
        } else {
            timeString = "\(minutes):\(seconds)"
        }
        return timeString;
    }
    
    func getDistance(_ lower: UInt8, _ mid: UInt8, _ high: UInt8) -> UInt32 {
        let rawDistance = get3ByteUInt(lower, mid, high);
        let distance: Float = (Float(rawDistance) * 0.1)
        let intDistance: UInt32 = UInt32(distance)
        return intDistance
    }
    
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
            }
        }
    }

    func getGeneralRowingInformation(_ value: Data?) {
        let sourceData = [UInt8] (value!)

        let workoutState = sourceData[8]
        checkWorkoutState(state: workoutState)
        
        let rowingState = sourceData[9]
        let strokeState = sourceData[10]

        let elapsedTime = getElapsedTime(sourceData[0], sourceData[1], sourceData[2])
        let distance = getDistance(sourceData[3], sourceData[4], sourceData[5])
        
        totalTimeVal = elapsedTime
        distanceVal = Int32(distance)

        elapsedTimeLabel.text = elapsedTime
        distanceLabel.text = "\(distance)"

        print("elapsedTime: \(elapsedTime)")
        print("distance: \(distance)")
        print("workoutState: \(workoutState)")
        print("rowingState: \(rowingState)")
        print("strokeState: \(strokeState)")
    }
    
    func checkWorkoutState(state: UInt8) {
        if state == 10 || state == 11 {
            endWorkout()
        }
    }
    
    func endWorkout() {
        self.setCurrentDate()
        workoutOptional = createNewWorkout()
        do {
            try self.context.save()
        } catch let error as NSError {
            print("Error saving workout: \(error)")
        }
        notifyOn = false
        self.navigationController?.popViewController(animated: true)
    }
    
    func stopNotify() {
        
    }
    
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
    
    func getGeneralRowingInformation3(_ value: Data?) {
        let sourceData = [UInt8] (value!)

        let strokeRate = sourceData[5]
        let currentSplit = getSplit(sourceData[7], sourceData[8])
        let averageSplit = getSplit(sourceData[9], sourceData[10])

        strokeRateLabel.text = "\(strokeRate)"
        currentSplitLabel.text = currentSplit
        avgSplitLabel.text = averageSplit
    }
    
    func getEndSummaryCharacteristic(_ value: Data?) {
        let sourceData = [UInt8] (value!)
        
        let avgStrokeRate = sourceData[10]
        avgStrokeRateVal = Int32(avgStrokeRate)
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
    
//    // function to execute as preparing for each segue
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//        if let identifier = segue.identifier {
//            // if save button pressed
//            if identifier == "SaveUnwindSegue" {
//                // set current trip optional to field values if they exist
//                workoutOptional = createNewWorkout()
//            // if cancel button pressed
//            } else if identifier == "cancelUnwindSegue" {
//                return
//            }
//        }
//    }
}
