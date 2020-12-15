//
//  ConnectedPeripheral.swift
//  Final_Project
//  Sam Toll
//  CPSC 315
//  December 14th, 2020
//
//  Created by Sam Toll on 11/27/20.
//

import Foundation
import CoreBluetooth
import UIKit

// class to store current connected peripheral and central manager - as well as model number, serial number, and concept2 (name) of current
// connected peripheral in case use of that information is neccessary
class ConnectedPeripheral: NSObject {
    
    public static var connectedPeripheral: CBPeripheral!
    public static var centralManager: CBCentralManager!
    
    public static var modelNumber: CBCharacteristic?
    public static var serialNumber: CBCharacteristic?
    public static var concept2: CBCharacteristic?
}
