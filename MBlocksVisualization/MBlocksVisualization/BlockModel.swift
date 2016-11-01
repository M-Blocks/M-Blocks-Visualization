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
    
    var blockNumber: String?
    var xPos: Double = 0.0
    var yPos: Double = 0.0
    var zPos: Double = 0.0
    var xOri: Double = 0.0
    var yOri: Double = 0.0
    var zOri: Double = 0.0
    var color: String?
    var upFace: Int = 1
    var cOne: String?
    var cTwo: String?
    var cThree: String?
    var cFour: String?
    var cFive: String?
    var cSix: String?
    var lOne: Int = 0
    var lTwo: Int = 0
    var lThree: Int = 0
    var lFour: Int = 0
    var lFive: Int = 0
    var lSix: Int = 0
    var located = false
    
    var sceneNode: SCNNode?
    
    override init() {
        
    }
    // fix
    //construct with all parameters
    init(blockNumber: String, upFace: Int, cOne: String, cTwo: String, cThree: String, cFour: String, cFive: String, cSix: String, lOne: String, lTwo: String, lThree: String, lFour: String, lFive: String, lSix: String, color: String) {
        self.blockNumber = blockNumber
        self.upFace = upFace
        self.cOne = cOne
    }
    init(blockNumber: String, xPos: Double, yPos: Double, zPos: Double, xOri: Double, yOri: Double, zOri: Double, color: String) {
        self.blockNumber = blockNumber
        self.xPos = xPos
        self.yPos = yPos
        self.zPos = zPos
        self.xOri = xOri
        self.yOri = yOri
        self.zOri = zOri
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
        //return String(describing: cubeNumber)
        return "Cube Number: \(self.blockNumber!), x: \(self.xPos), y: \(self.yPos), z: \(self.zPos)"
    }
    
    // FIX THE NUMBERS
    func setXZOri() {
        resetOri()
        if self.upFace == 1 {
            self.xOri = 270.degreesToRadians
        } else if self.upFace == 2 {
            self.zOri = 90.degreesToRadians
        } else if self.upFace == 3 {
            self.xOri = 90.degreesToRadians
        } else if self.upFace == 4 {
            self.zOri = 270.degreesToRadians
        } else if self.upFace == 5 {
        } else if self.upFace == 6 {
            self.xOri = 180.degreesToRadians
        }
        
        if sceneNode != nil {
            sceneNode?.eulerAngles = SCNVector3(x: Float(self.xOri), y: Float(self.yOri), z: Float(self.zOri))
        }
    }
    
    func resetOri() {
        self.xOri = 0
        self.yOri = 0
        self.zOri = 0
    }
    
    func getDirFacing(side: Int) -> String {
        if side == upFace {
            return "posY"
        } else if side == faceDown() {
            return "negY"
        } else {
            let x = (relativeSideFaces().index(of: side)! * 90 + Int(yOri.radiansToDegrees)) % 360
            if (x == 0) || (x == 360) {
                return "posZ"
            } else if x == 90 {
                return "posX"
            } else if x == 180 {
                return "negZ"
            } else {
                return "negX"
            }
        }
    }
    
    /* PROB NOT USEFUL -> DELETE */
    func turnToFace(side: Int, dir: String) {
        if side == 1 {
            if upFace == 2 {
                if dir == "posX" {
                    self.xOri = 0
                    self.yOri = 180.degreesToRadians
                    self.zOri = 90.degreesToRadians
                } else if dir == "negX" {
                    
                } else if dir == "posZ" {
                    
                } else if dir == "negZ" {
                    
                }
            }
            
        }
        
    }
    
    func faceDown() -> Int {
        if upFace == 1 {
            return 3
        } else if upFace == 2 {
            return 4
        } else if upFace == 3 {
            return 1
        }  else if upFace == 4 {
            return 2
        } else if upFace == 5 {
            return 6
        } else {
            return 5
        }
    }
    
    func relativeSideFaces() -> [Int] {
        if self.upFace == 1 {
            return [6,2,5,4]
        } else if self.upFace == 2 {
            return [1,6,3,5]
        } else if self.upFace == 3 {
            return [5,2,6,4]
        } else if self.upFace == 4 {
            return [1,5,3,6]
        } else if self.upFace == 5 {
            return [1,2,3,4]
        } else {
            return [1,4,3,2]
        }
    }
    
    
}
