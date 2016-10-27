//
//  NewPositionCalculator.swift
//  MBlocksVisualization
//
//  Created by Mateo Correa on 10/20/16.
//  Copyright © 2016 CSAIL. All rights reserved.
//

import Foundation


class PositionCalculator: NSObject {
    
    var blocks: [String: BlockModel]! = [String: BlockModel]()
    
    let rotations = [1:[180,90,0,270],
                     2:[270,180,90,0],
                     3:[0,270,180,90],
                     4:[90,0,270,180]]
    var first: BlockModel?
    var setBase = false
    
    init(list: [BlockModel]) {
        for x in list {
            blocks[x.blockNumber!] = x
            if first == nil {
                first = x
            }
        }
    }
    
    
    func position(block: BlockModel) {
        if !setBase {
            
            block.xPos = 0.0
            block.yPos = 0.0
            block.zPos = 0.0
            block.setXZOri()
            block.yOri = 0
            block.located = true
            setBase = true
            recursivelyLocateConnections(block: block)
            
        } else {
            
            
            let sides = ["cOne", "cTwo", "cThree", "cFour", "cFive", "cSix"]
            var guessAvailable = false
            var guessList = [String: Any]()
            for side in sides {
                let x = (block.value(forKey: side) as! String)
                if  x != "" {
                    
                    let info = x.components(separatedBy: "-")
                    
                    // if this is null(because the cube was turned off), then the connection should be deleted
                    if let connected = blocks[info[0]] {
                        let thisSide = getSideNum(side: side)
                        let thatSide = Int(info[1])!
                        if (thatSide == connected.faceDown()) || (thatSide == connected.upFace) {
                            guessAvailable = true
                            guessList["rel"] = connected
                            guessList["a"] = thisSide
                            guessList["b"] = thatSide
                            continue
                        }
                        if connected.located == true {
                            locate(block: block, relativeTo: connected, a: thisSide, b: thatSide)
                            //print("should immediately break")
                            break
                        }
                    } else {
                        block.setValue("", forKey: side)
                        continue
                    }
                    /* old code
                    let connected = blocks[info[0]]!
                    let thisSide = getSideNum(side: side)
                    let thatSide = Int(info[1])!
                    if connected.located == true {
                        locate(block: block, relativeTo: connected, a: thisSide, b: thatSide)
                        //print("should immediately break")
                        break
                    }*/
                }
                //print("still looping")
                if side == "cSix" {
                    if guessAvailable {
                        locate(block: block, relativeTo: guessList["rel"] as! BlockModel, a: guessList["a"] as! Int, b: guessList["b"] as! Int)
                    }
                }
            }
            //print("break")
            
            
            // CONTINUE IN THIS PLACE SOMWHERE ABOVE THIS
            // Check its neighbors
            
            // loop through neighbors
            // If neighbor is located
                // use it to locate X
                //break
            // Else
                // don't do anything
        }
    }
    
    func locate(block: BlockModel, relativeTo: BlockModel, a: Int, b: Int) {
        block.xPos = relativeTo.xPos
        block.yPos = relativeTo.yPos
        block.zPos = relativeTo.zPos
        
        if (b != relativeTo.upFace) && (b != relativeTo.faceDown()) {
            //print("b is \(b)")
            //print("a is \(a)")
            // FIX MIGHT BE FLIPPED
            //print(block.relativeSideFaces())
            //print(relativeTo.relativeSideFaces())
            let firstIndex = block.relativeSideFaces().index(of: a)
            let secondIndex = relativeTo.relativeSideFaces().index(of: b)
            //print(firstIndex)
            //print(secondIndex)
            
            let turn = rotations[firstIndex! + 1]?[secondIndex!].degreesToRadians
            /*print(rotations[firstIndex!]?[secondIndex!])
            print("first index \(firstIndex!)")
            print("second index \(secondIndex!)")
            print("turn is \(turn)")*/
            block.yOri = (relativeTo.yOri + turn!) - (((relativeTo.yOri + turn!) / 360.degreesToRadians)*360.degreesToRadians)

        }
        
        
        let facing = relativeTo.getDirFacing(side: b)
        
        if facing == "posX" {
            block.xPos = block.xPos + 1.0
            //block.turnToFace(side: a, dir: "negX")
        } else if facing == "negX" {
            block.xPos = block.xPos - 1.0
            //block.turnToFace(side: a, dir: "posX")
        } else if facing == "posY" {
            block.yPos = block.yPos + 1.0
            //block.turnToFace(side: a, dir: "negY")
        } else if facing == "negY" {
            block.yPos = block.yPos - 1.0
            //block.turnToFace(side: a, dir: "posY")
        } else if facing == "posZ" {
            block.zPos = block.zPos + 1.0
            //block.turnToFace(side: a, dir: "negZ")
        } else if facing == "negZ" {
            block.zPos = block.zPos - 1.0
            //block.turnToFace(side: a, dir: "posZ")
        }
        
        if (b != relativeTo.upFace) && (b != relativeTo.faceDown()) {
            block.located = true
        }
    }
    
    
    /*
     *
     *
     */
    func recursivelyLocateConnections(block: BlockModel) {
        
        var connections = [BlockModel]()
        
        let sides = ["cOne", "cTwo", "cThree", "cFour", "cFive", "cSix"]
        
        for side in sides {
            let x = (block.value(forKey: side) as! String)
            if  x != "" {
                let info = x.components(separatedBy: "-")
                let connected = blocks[info[0]]!
                let thisSide = getSideNum(side: side)
                let thatSide = Int(info[1])!
                if connected.located == false {
                    locate(block: connected, relativeTo: block, a: thatSide, b: thisSide)
                    connections.append(connected)
                }
            }
        }
        
        if connections.count > 0 {
            for bl in connections {
                recursivelyLocateConnections(block: bl)
            }
        }
    }
    
    func getSideNum(side: String) -> Int {
        if side == "cOne" {
            return 1
        } else if side == "cTwo" {
            return 2
        } else if side == "cThree" {
            return 3
        } else if side == "cFour" {
            return 4
        } else if side == "cFive" {
            return 5
        } else { //side == "cSix" {
            return 6
        }
    }
    
    func getSideName(side: Int) -> String {
        if side == 1 {
            return "cOne"
        } else if side == 2 {
            return "cTwo"
        } else if side == 3 {
            return "cThree"
        } else if side == 4 {
            return "cFour"
        } else if side == 5 {
            return "cFive"
        } else { //side == "cSix" {
            return "cSix"
        }
    }
}
