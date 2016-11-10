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
    
    func setList(list: [BlockModel]) {
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
            /*first = block
            blocks[(first?.blockNumber)!] = first*/
            recursivelyLocateConnections(block: block)
        } else {
            let sides = ["cOne", "cTwo", "cThree", "cFour", "cFive", "cSix"]
            var guessAvailable = false
            var guessList = [String: Any]()
            for side in sides {
                let x = (block.value(forKey: side) as! String)
                if  x != "" {
                    
                    let info = x.components(separatedBy: "-")
                    print(info)
                    // if this is null(because the cube was turned off), then the connection should be deleted
                    if let connected = blocks[info[0]] {
                        let thisSide = getSideNum(side: side)
                        let thatSide = Int(info[1])!
                        if (thatSide == connected.downFace()) || (thatSide == connected.upFace) {
                            print("setting as guess")
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
                        } else {
                            print("connected cube is not located")
                            print(connected.located)
                            print(blocks["7"]!.located)
                        }
                    } else {
                        print("Didn't find cube this was connected to")
                        block.setValue("", forKey: side)
                        continue
                    }
                }
                //print("still looping")
                if side == "cSix" {
                    if guessAvailable {
                        locate(block: block, relativeTo: guessList["rel"] as! BlockModel, a: guessList["a"] as! Int, b: guessList["b"] as! Int)
                    }
                }
            }
            //print("break")
        }
    }
    
    func locate(block: BlockModel, relativeTo: BlockModel, a: Int, b: Int) {
        block.xPos = relativeTo.xPos
        block.yPos = relativeTo.yPos
        block.zPos = relativeTo.zPos
        
        if (b != relativeTo.upFace) && (b != relativeTo.downFace()) {
            let firstIndex = block.relativeSideFaces().index(of: a)
            let secondIndex = relativeTo.relativeSideFaces().index(of: b)
            
            let turn = rotations[firstIndex! + 1]?[secondIndex!].degreesToRadians
            block.yOri = (relativeTo.yOri + turn!) - (((relativeTo.yOri + turn!) / 360.degreesToRadians)*360.degreesToRadians)
        }
        
        let facing = relativeTo.getDirFacing(side: b)
        
        if facing == "posX" {
            block.xPos = block.xPos + 1.0
        } else if facing == "negX" {
            block.xPos = block.xPos - 1.0
        } else if facing == "posY" {
            block.yPos = block.yPos + 1.0
        } else if facing == "negY" {
            block.yPos = block.yPos - 1.0
        } else if facing == "posZ" {
            block.zPos = block.zPos + 1.0
        } else if facing == "negZ" {
            block.zPos = block.zPos - 1.0
        }
        
        if (b != relativeTo.upFace) && (b != relativeTo.downFace()) {
            block.located = true
            print("Block \(block.blockNumber) located and oriented")
        } else {
            print("Block \(block.blockNumber) located but not oriented")
        }
    }
    
    func recursivelyLocateConnections(block: BlockModel) {
        
        var connections = [BlockModel]()
        
        let sides = ["cOne", "cTwo", "cThree", "cFour", "cFive", "cSix"]
        
        for side in sides {
            let x = (block.value(forKey: side) as! String)
            if  x != "" {
                let info = x.components(separatedBy: "-")
                if let connected = blocks[info[0]] {
                    let thisSide = getSideNum(side: side)
                    let thatSide = Int(info[1])!
                    if connected.located == false {
                        locate(block: connected, relativeTo: block, a: thatSide, b: thisSide)
                        connections.append(connected)
                    }
                } else {
                    print("Didn't find cube this was connected to")
                    block.setValue("", forKey: side)
                    continue
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
        } else {
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
        } else {
            return "cSix"
        }
    }
}
