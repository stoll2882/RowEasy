//
//  Peripheral.swift
//  Final_Project
//
//  Created by Sam Toll on 11/27/20.
//

import Foundation
import CoreBluetooth
import UIKit

class RowerPeripheral: NSObject {
    
    // MARK: - Peripheral services and characteristics identifiers
    
    public static let serviceNumberIdentifier = CBUUID.init(string: "CE060000-43E5-11E4-916C-0800200C9A66")
    public static let controlServiceIdentifier = CBUUID.init(string: "CE060020-43E5-11E4-916C-0800200C9A66")
    public static let rowingServiceIdentifier = CBUUID.init(string: "CE060030-43E5-11E4-916C-0800200C9A66")
    
    public static let modelNumberCharacteristic = CBUUID.init(string: "CE060011-43E5-11E4-916C-0800200C9A66")
    public static let serialNumberCharacteristic = CBUUID.init(string: "CE060012-43E5-11E4-916C-0800200C9A66")
    public static let hardwareRevisionCharacteristic = CBUUID.init(string: "CE060013-43E5-11E4-916C-0800200C9A66")
    public static let firmwareRevisionCharacteristic = CBUUID.init(string: "CE060014-43E5-11E4-916C-0800200C9A66")
    public static let concept2Characteristic = CBUUID.init(string: "CE060015-43E5-11E4-916C-0800200C9A66")
    public static let ergMachineTypeCharacteristic = CBUUID.init(string: "CE060016-43E5-11E4-916C-0800200C9A66")
    public static let recieveCharacteristic = CBUUID.init(string: "CE060021-43E5-11E4-916C-0800200C9A66")
    public static let transmitCharacteristic = CBUUID.init(string: "CE060022-43E5-11E4-916C-0800200C9A66")
    
    public static let generalStatusCharacteristic = CBUUID(string: "CE060031-43E5-11E4-916C-0800200C9A66")
    
    public static let generalStatusCharacteristic2 = CBUUID(string: "CE060032-43E5-11E4-916C-0800200C9A66")
    
    public static let endWorkoutSummaryCharacteristic = CBUUID(string: "CE060039-43E5-11E4-916C-0800200C9A66")

    
}
