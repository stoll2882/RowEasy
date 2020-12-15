//
//  BluetoothViewController.swift
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

// controller of view that shows bluetooth options
class BluetoothViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CBPeripheralDelegate, CBCentralManagerDelegate {
    
    // peripheral options available
    private var peripherals: Array<CBPeripheral> = Array<CBPeripheral>()
    // service options available
    public var services: [CBService]? = nil
    
    // tableview used to display options
    @IBOutlet weak var tableView: UITableView!
    
    // function to execute when the view loads...
    override func viewDidLoad() {
        super.viewDidLoad()
        // set the delegate to self for the central manager in charge of the bluetooth functionality
        ConnectedPeripheral.centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        // Do any additional setup after loading the view.
    }
    
    // gives number of rows as the number of peripherals found available
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    //
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
            // make sure to only scan for rowing machines by making sure machines listed have the concept2 service number identifier
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
    
    // when connect is pressed... connect to the peripheral corresponding with table view row selected
    @IBAction func connectClicked() {
        if let indexPath = tableView.indexPathForSelectedRow {
            // set the connected peripheral to the table view row selected
            ConnectedPeripheral.connectedPeripheral = peripherals[indexPath.row]
            // stop the scan
            ConnectedPeripheral.centralManager.stopScan()
            // connect to the peripheral...
            ConnectedPeripheral.centralManager.connect(ConnectedPeripheral.connectedPeripheral, options: nil)
        }
    }
    
    // for display / debugging purposes...
    @IBAction func startClicked() {
        print("rowing workout started...")
    }
    
    // function that executes once peripheral is connected to central manager
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        ConnectedPeripheral.connectedPeripheral.delegate = self
        if let indexPath = tableView.indexPathForSelectedRow {
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.textLabel?.text = "Connected to \(ConnectedPeripheral.connectedPeripheral.name ?? "no name")"
                tableView.deselectRow(at: indexPath, animated: true)

            }
        }
    }
}
