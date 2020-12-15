//
//  Peripheral.swift
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

// Information helpful to users unfarmiliar with the bluetooth framework and / or rowing machine framework

// MARK: - What is a Peripheral?
// - a peripheral is an auxillary device used to provide information / get information to and from the computer (or another electronic device)
// - in this case the peripheral is the Concept2 rowing machine... providing information to our program in order to display live results
//   and save workouts

// MARK: - What is a Central Manager? What is the Different Between it and a Peripheral?
// - a central manager is an object that scans, discovers, connects to and manages peripherals
// - in other words - it would be hard to use a peripheral without a central manager
// - if it is powered on - it indicates that the central device (peripheral i.e. rowing machine) supports
//   bluetooth low energy and that bluetooth is on and available for use

// MARK: - What is a Rowing Machine / What Does it Do?
// - a rowing machine is a workout machine often used by Rowing athletic teams for training as well as individuals who want a good workout
// - when you start a workout it will display live results onto the screen that basically mimics what this app will show
// - it will save your workouts for you to view later... and looks just like the image I provide on my loading screen as well
//   as the screen to view past workouts

// MARK: - What is CoreBluetooth Framework in Swift and How Does it Work?
// - core bluetooth is a provided IOS Framework that allows a programmer to build Bluetooth Low Energy applications that communicate
//   with different hardware gadgets (in this case the rowing machine)

// RowerPeripheral class
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
    
    public static let strokeDataCharacteristic = CBUUID(string: "CE060035-43E5-11E4-916C-0800200C9A66")
    
    public static let endWorkoutSummaryCharacteristic = CBUUID(string: "CE060039-43E5-11E4-916C-0800200C9A66")
    
}
