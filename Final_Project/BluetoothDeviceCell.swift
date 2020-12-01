//
//  BluetoothDeviceCell.swift
//  Final_Project
//
//  Created by Sam Toll on 11/27/20.
//

import UIKit
import Foundation
import CoreBluetooth


class BluetoothDeviceCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var UUIDLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func update(with peripheral: CBPeripheral) {
        nameLabel.text = peripheral.name
        UUIDLabel.text = "\(peripheral.description)UUID"
    }
}
