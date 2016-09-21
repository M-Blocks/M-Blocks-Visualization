//
//  BlockModel.swift
//  MBlocksVisualization
//
//  Created by Mateo Correa on 9/21/16.
//  Copyright © 2016 CSAIL. All rights reserved.
//

import Foundation
import SceneKit

class BlockModel: NSObject {
    
    //properties
    
    var cubeNumber: String?
    var xPos: String?
    var yPos: String?
    var zPos: String?
    var xOri: String?
    var yOri: String?
    var zOri: String?
    var color: String?
    var cubeType: String?
    var xPosGoal: String?
    var yPosGoal: String?
    var zPosGoal: String?
    var xOriGoal: String?
    var yOriGoal: String?
    var zOriGoal: String?
    
    var sceneNode: SCNNode?
    
    //empty constructor
    
    override init()
    {
        
    }
    
    //construct with all parameters
    init(cubeNumber: String, xPos: String, yPos: String, zPos: String, xOri: String, yOri: String, zOri: String, color: String, cubeType: String, xPosGoal: String, yPosGoal: String, zPosGoal: String, xOriGoal: String, yOriGoal: String, zOriGoal: String) {
        self.cubeNumber = cubeNumber
        self.xPos = xPos
        self.yPos = yPos
        self.zPos = zPos
        self.xOri = xOri
        self.yOri = yOri
        self.zOri = zOri
        self.color = color
        self.cubeType = cubeType
        self.xPosGoal = xPosGoal
        self.yPosGoal = yPosGoal
        self.zPosGoal = zPosGoal
        self.xOriGoal = xOriGoal
        self.yOriGoal = yOriGoal
        self.zOriGoal = zOriGoal
    }
    
    func setNode(node: SCNNode) {
        sceneNode = node
    }
    
    func getNode() -> SCNNode {
        if sceneNode != nil {
            return sceneNode!
        }
        return SCNNode()
    }
    
    
    //prints object's current state
    override var description: String {
        return "Cube Number: \(cubeNumber), x: \(xPos), y: \(yPos), z: \(zPos)"
    }
    
    
}
