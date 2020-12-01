//
//  ConnectedPeripheral.swift
//  Final_Project
//
//  Created by Sam Toll on 11/27/20.
//

import Foundation
import CoreBluetooth
import UIKit

class ConnectedPeripheral: NSObject {
    
    public static var connectedPeripheral: CBPeripheral!
    public static var centralManager: CBCentralManager!
    
    public static var modelNumber: CBCharacteristic?
    public static var serialNumber: CBCharacteristic?
    public static var concept2: CBCharacteristic?
    
}
