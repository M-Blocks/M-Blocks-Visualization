//
//  BlockNode.swift
//  MBlocksVisualization
//
//  Created by Mateo Correa on 9/21/16.
//  Copyright © 2016 CSAIL. All rights reserved.
//

import Foundation
import SceneKit.SCNNode

class BlockNode: SCNNode {
    
    var block: BlockModel?
    
    
    func getBlock() -> BlockModel {
        if block == nil {
            return BlockModel()
        }
        return block!
    }
    
    func setBlock(block: BlockModel) {
        
    }
}
