//
//  ParticlePeripheral.swift
//  Final_Project
//
//  Created by Sam Toll on 11/27/20.
//

import Foundation

import UIKit
import CoreBluetooth

class ParticlePeripheral: NSObject {
    
    // MARK: - Particle LED services and characteristics identifiers

    public static let particleLEDServiceUUID     = CBUUID.init(string: "CE060000-43E5-11E4-916C-0800200C9A66")
    public static let redLEDCharacteristicUUID   = CBUUID.init(string: "b4250401-fb4b-4746-b2b0-93f0e61122c6")
    public static let greenLEDCharacteristicUUID = CBUUID.init(string: "b4250402-fb4b-4746-b2b0-93f0e61122c6")
    public static let blueLEDCharacteristicUUID  = CBUUID.init(string: "b4250403-fb4b-4746-b2b0-93f0e61122c6")

}
