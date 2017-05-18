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
    var blockNumber = "0";
    var xPos: Double = 0.0
    var yPos: Double = 0.0
    var zPos: Double = 0.0
    var xOri: Double = 0.0
    var yOri: Double = 0.0
    var zOri: Double = 0.0
    var color: String = "green"
    var lOne: Int = 0
    var lTwo: Int = 0
    var lThree: Int = 0
    var lFour: Int = 0
    var lFive: Int = 0
    var lSix: Int = 0
    var upFace: Int = 0
    var highlighted = false
    var sceneNode: SCNNode?
    var positionQueue : [[Int]] = []
    
    override init() {
    }
    
    // fix: construct with all parameters
    init(blockNumber: String, color: String, xPos: Int, yPos: Int, zPos: Int, xOri: Int, yOri : Int, zOri: Int, lOne: String, lTwo: String, lThree: String, lFour: String, lFive: String, lSix: String, upFace: Int) {
        self.blockNumber = blockNumber
        self.upFace = upFace
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
    
    func setPivot(direction1: String, direction2: String = "none") {
        xPos += -pivot.x
        yPos += -pivot.y
        zPos += -pivot.z
        pivot.x = 0
        pivot.y = 0
        pivot.z = 0
        if (direction1 == "posX") || (direction2 == "posX") {
            xPos += 0.5
            pivot.x += 0.5
        } else if (direction1 == "negX") || (direction2 == "negX") {
            xPos -= 0.5
            pivot.x -= 0.5
        } else if (direction1 == "posY") || (direction2 == "posY") {
            yPos += 0.5
            pivot.y += 0.5
        } else if (direction1 == "negY") || (direction2 == "negY") {
            yPos -= 0.5
            pivot.y -= 0.5
        }  else if (direction1 == "posZ") || (direction2 == "posZ") {
            zPos += 0.5
            pivot.z += 0.5
        } else if (direction1 == "negZ") || (direction2 == "negZ") {
            zPos -= 0.5
            pivot.z -= 0.5
        }
        
        if (direction2 == "none") {
            if (cube on pos X side) {
                xPos += 0.5
                pivot.x += 0.5
            } else if (cube on neg X side) {
                xPos -= 0.5
                pivot.x -= 0.5
            } else if (cube on pos Y side) {
                yPos += 0.5
                pivot.y += 0.5
            } else if (cube on neg Y side) {
                yPos -= 0.5
                pivot.y -= 0.5
            }  else if (cube on pos Z side) {
                zPos += 0.5
                pivot.z += 0.5
            } else if (cube on neg Z side) {
                zPos -= 0.5
                pivot.z -= 0.5
            }
        }
    }

    //prints object's current state
    override var description: String {
        //return String(describing: cubeNumber)
        return "Cube Number: \(self.blockNumber), x: \(self.xPos), y: \(self.yPos), z: \(self.zPos)"
    }
    
    func getDirFacing(side: Int) -> String {
        if side == upFace {
            return "posY"
        } else if side == downFace() {
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
    
    func downFace() -> Int {
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
    
    func highlight(_ light: Bool = true) {
        let mat = self.sceneNode?.geometry!.materials
        
        self.highlighted = light
        let lights = [self.lOne, self.lTwo,self.lThree, self.lFour, self.lFive, self.lSix]
        for i in 0..<6 {
            let b = (light == true) ? 2.0 : CGFloat(Float(lights[i])/Float(128.0))
            mat?[i].diffuse.contents = UIColor(hue: getHue(), saturation: 1.0, brightness: b, alpha: 1.0)
            print(i)
        }
    }
    
    func getNeighboringPos(side: Int) -> [Double] {
        let s = self.getDirFacing(side: side)
        print(s)
        if s == "posY" {
            return [xPos, yPos + 1.0, zPos]
        } else if s == "negY" {
            return [xPos, yPos - 1.0, zPos]
        } else if s == "negX" {
            return [xPos - 1.0, yPos, zPos]
        } else if s == "posX" {
            return [xPos + 1.0, yPos, zPos]
        } else if s == "posZ" {
            return [xPos, yPos, zPos + 1.0]
        } else { //"negZ"
            return [xPos, yPos, zPos - 1.0]
        }
    }
    
    func getHue() -> CGFloat {
        if color == "red" {
            return CGFloat(0.0)
            
        } else if color == "green" {
            return CGFloat(0.35)
            
        } else { // color == "blue"
            return CGFloat(0.66)
            
        }
    }
    
}
