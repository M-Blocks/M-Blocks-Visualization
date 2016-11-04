//
//  CommandCell.swift
//  MBlocksVisualization
//
//  Created by Mateo Correa on 11/4/16.
//  Copyright © 2016 CSAIL. All rights reserved.
//

import Foundation
import UIKit


class CommandCell: UICollectionViewCell {
    var delegate = ViewScreen()
    @IBOutlet weak var commandButton: UIButton!
    
    @IBAction func sendCommand(_ sender: AnyObject) {
        delegate.sendCommand((sender.titleLabel??.text)!)
        print(sender.titleLabel??.text)
    }
    
}
