//
//  BluetoothViewController.swift
//  Final_Project
//
//  Created by Sam Toll on 11/27/20.
//

import Foundation
import UIKit
import CoreBluetooth

class BluetoothViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CBPeripheralDelegate, CBCentralManagerDelegate {
    
    private var peripherals: Array<CBPeripheral> = Array<CBPeripheral>()
    public var services: [CBService]? = nil
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ConnectedPeripheral.centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let peripheral = peripherals[row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                
        cell.textLabel?.text = peripheral.name
        
        return cell
    }
    
    // If we're powered on, start scanning
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            ConnectedPeripheral.centralManager.scanForPeripherals(withServices: [RowerPeripheral.serviceNumberIdentifier])
        } else {
            print("Bluetooth not available")
        }
    }
    
    // Handles the result of the scan
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Name: \(peripheral.name ?? "no name")")
        print("Identifier: \(peripheral.identifier.uuidString)")
        peripherals.append(peripheral)
        print(peripheral)
        tableView.reloadData()
    }
    
    @IBAction func connectClicked() {
        if let indexPath = tableView.indexPathForSelectedRow {
            ConnectedPeripheral.connectedPeripheral = peripherals[indexPath.row]
            ConnectedPeripheral.centralManager.stopScan()
            ConnectedPeripheral.centralManager.connect(ConnectedPeripheral.connectedPeripheral, options: nil)
        }
    }
    
    @IBAction func startClicked() {
        
    }
    
//    func updateView() {
//        let vc = ConnectedViewController()
//        vc.avgSplitLabel.text = ConnectedPeripheral.averageSplit
//        vc.currentSplitLabel.text = ConnectedPeripheral.currentSplit
//        vc.distanceLabel.text = ConnectedPeripheral.distance
//        vc.elapsedTimeLabel.text = ConnectedPeripheral.elapsedTime
//        vc.strokeRateLabel.text = "\(ConnectedPeripheral.strokeRate)"
//
//        navigationController?.pushViewController(vc, animated: true)
//    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        ConnectedPeripheral.connectedPeripheral.delegate = self
        if let indexPath = tableView.indexPathForSelectedRow {
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.textLabel?.text = "Connected to \(ConnectedPeripheral.connectedPeripheral.name ?? "no name")"
                tableView.deselectRow(at: indexPath, animated: true)

            }
        }
    }
    
    // Handles discovery event
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        if let services = peripheral.services {
//            for service in services {
//                peripheral.discoverCharacteristics([RowerPeripheral.serialNumberCharacteristic, RowerPeripheral.concept2Characteristic, RowerPeripheral.generalStatusCharacteristic, RowerPeripheral.generalStatusCharacteristic2], for: service)
//            }
//        }
//    }
//
//    func characteristicToString(_ value: Data?) -> String {
//        return String(decoding: value!, as: UTF8.self);
//    }
//
//    // Handling discovery of characteristics
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        if let characteristics = service.characteristics {
//            for characteristic in characteristics {
//                if characteristic.uuid == RowerPeripheral.generalStatusCharacteristic || characteristic.uuid == RowerPeripheral.generalStatusCharacteristic2 {
//                    peripheral.setNotifyValue(true, for: characteristic)
//                } else {
//                    peripheral.readValue(for: characteristic)
//                }
//            }
//        }
//    }
//
//    func get3ByteUInt(_ lower: UInt8, _ mid: UInt8, _ high: UInt8) -> UInt32 {
//        let inputArray = [0, high, mid, lower];
//        let data = Data(inputArray)
//        return UInt32(bigEndian: data.withUnsafeBytes { $0.pointee })
//    }
//
//    func get2ByteUInt(_ lower: UInt8, _ high: UInt8) -> UInt32 {
//        let inputArray = [0, 0, high, lower];
//        let data = Data(inputArray)
//        return UInt32(bigEndian: data.withUnsafeBytes { $0.pointee })
//    }
//
//    func getElapsedTime(_ lower: UInt8, _ mid: UInt8, _ high: UInt8) -> String {
//        let rawTime = get3ByteUInt(lower, mid, high);
//        let elapsedTime: Float = (Float(rawTime) * 0.01)
//        let minutes = UInt32(elapsedTime / 60)
//        let seconds = UInt32(elapsedTime) % 60
//        var timeString: String
//        if seconds < 10 {
//            timeString = "\(minutes):0\(seconds)"
//        } else {
//            timeString = "\(minutes):\(seconds)"
//        }
//        return timeString;
//    }
//
//    func getDistance(_ lower: UInt8, _ mid: UInt8, _ high: UInt8) -> String {
//        let rawDistance = get3ByteUInt(lower, mid, high);
//        let distance: Float = (Float(rawDistance) * 0.1)
//        let intDistance: UInt32 = UInt32(distance)
//        return "\(intDistance)"
//    }
//
//    func getSplit(_ lower: UInt8, _ high: UInt8) -> String {
//        let rawSplit = get2ByteUInt(lower, high)
//        let split: Float = (Float(rawSplit) * 0.01)
//
//        let minutes = Int(split / 60)
//        let seconds = Int(split) % 60
//        var splitString: String
//        if seconds < 10 {
//            splitString = "\(minutes):0\(seconds)"
//        } else {
//            splitString = "\(minutes):\(seconds)"
//        }
//        return splitString;
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        if characteristic.uuid == RowerPeripheral.serialNumberCharacteristic {
//            ConnectedPeripheral.serialNumber = characteristic
//            print("Serial #: \(characteristicToString(characteristic.value))")
//        } else if characteristic.uuid == RowerPeripheral.concept2Characteristic {
//            ConnectedPeripheral.concept2 = characteristic
//            print("Concept2: \(characteristicToString(characteristic.value))")
//        } else if characteristic.uuid == RowerPeripheral.generalStatusCharacteristic {
//            getGeneralRowingInformation(characteristic.value)
//        } else if characteristic.uuid == RowerPeripheral.generalStatusCharacteristic2 {
//            getGeneralRowingInformation2(characteristic.value)
//        }
//    }
//
//    func getGeneralRowingInformation(_ value: Data?) {
//        let sourceData = [UInt8] (value!)
//
//        let workoutState = sourceData[8]
//        let rowingState = sourceData[9]
//        let strokeState = sourceData[10]
//
//        let elapsedTime = getElapsedTime(sourceData[0], sourceData[1], sourceData[2])
//        let distance = getDistance(sourceData[3], sourceData[4], sourceData[5])
//
//        ConnectedPeripheral.elapsedTime = elapsedTime
//        ConnectedPeripheral.distance = "\(distance)"
//        updateView()
//
//        print("elapsedTime: \(elapsedTime)")
//        print("distance: \(distance)")
//        print("workoutState: \(workoutState)")
//        print("rowingState: \(rowingState)")
//        print("strokeState: \(strokeState)")
//    }
//
//    func getGeneralRowingInformation2(_ value: Data?) {
//        let sourceData = [UInt8] (value!)
//
//        let strokeRate = sourceData[5]
//        let currentSplit = getSplit(sourceData[7], sourceData[8])
//        let averageSplit = getSplit(sourceData[9], sourceData[10])
//
//        ConnectedPeripheral.strokeRate = strokeRate
//        ConnectedPeripheral.currentSplit = currentSplit
//        ConnectedPeripheral.averageSplit = averageSplit
//        updateView()
//
//        print("strokeRate: \(strokeRate)")
//        print("currentSplit: \(currentSplit)")
//        print("averageSplit: \(averageSplit)")
//    }
    
//     function to execute upon run of segues
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let identifier = segue.identifier {
//            // segue to go to detail view / controller
//            if identifier == "startRowSegue" {
//                if let _ = segue.destination as? ConnectedViewController {
//                    ConnectedPeripheral.connectedPeripheral.discoverServices(nil)
//                }
//            // segue to go add a trip view
//            }
//        }
//    }
}

//    // function to execute upon run of segues
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let identifier = segue.identifier {
//            // segue to go to detail view / controller
//            if identifier == "DetailSegue" {
//                if let _ = segue.destination as? ConnectedViewController {
//                    if let indexPath = tableView.indexPathForSelectedRow {
//                        RowerPeripheral.connectedPeripheral = peripherals[indexPath.row]
//                        RowerPeripheral.connectedPeripheral.delegate = self
//                        RowerPeripheral.centralManager.stopScan()
//                        RowerPeripheral.centralManager.connect(RowerPeripheral.connectedPeripheral, options: nil)
//                        tableView.deselectRow(at: indexPath, animated: true)
//                    }
//                }
//            // segue to go add a trip view
//            }
//        }
//    }
//}
//        let device = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as! NSString

