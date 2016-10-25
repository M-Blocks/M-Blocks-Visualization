//
//  NewPositionCalculator.swift
//  MBlocksVisualization
//
//  Created by Mateo Correa on 10/20/16.
//  Copyright © 2016 CSAIL. All rights reserved.
//

import Foundation


class NewPositionCalculator: NSObject {
    
    var blocks: [String: BlockModel]! = [String: BlockModel]()
    
    let rotations = [1:[180,90,0,270],
                     2:[270,180,90,0],
                     3:[0,270,180,90],
                     4:[90,0,270,180]]
    let first: BlockModel?
    var setBase = false
    
    init() {
        
    }
    
    
    func position(block: BlockModel) {
        if !setBase {
            
            block.xPos = 0.0
            block.yPos = 0.0
            block.zPos = 0.0
            block.setXZOri()
            block.yOri = 0
            block.located = true
            
            recursivelyLocateConnections(block: block)
            
        } else {
            
            
            let sides = ["cOne", "cTwo", "cThree", "cFour", "cFive", "cSix"]
            var connectedSides = NSMutableArray()
            
            for side in sides {
                if (block.value(forKey: side) as! String) != "" {
                    connectedSides.add(block.value(forKey: side) as! String)
                }
            }
            // CONTINUE IN THIS PLACE SOMWHERE ABOVE THIS
            // Check its neighbors (break once it finds one)
            
            // If neighbor is located
                // use it to locate X
            // Else
                // don't do anything
        }
    }
    
    func locate(block: BlockModel, relativeTo: BlockModel) {
        
    }
    
    func recursivelyLocateConnections(block: BlockModel) {
        
    }
}
