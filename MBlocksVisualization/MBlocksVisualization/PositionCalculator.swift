//
//  PositionCalculator.swift
//  MBlocksVisualization
//
//  Created by Mateo Correa on 10/19/16.
//  Copyright © 2016 CSAIL. All rights reserved.
//

import Foundation


class PositionCalculator: NSObject {
    
    var blocks: [String: BlockModel]! = [String: BlockModel]()
    
    let rotations = [1:[180,90,0,270],
                     2:[270,180,90,0],
                     3:[0,270,180,90],
                     4:[90,0,270,180]]
    let first: BlockModel?
    init(list: [BlockModel]) {
        for b in list {
            self.blocks[b.blockNumber!] = b
        }
        first = list[0]
    }
    
    func locateConnections(block: BlockModel, prevX: Double = 0, prevY: Double = 0, prevZ: Double = 0) {
        var connections = NSMutableArray()
        if(prevX == 0.0) && (prevY == 0.0) && (prevZ == 0.0) {
            block.xPos = 0.0
            block.yPos = 0.0
            block.zPos = 0.0
            
            // FIX 
            block.yOri = 0.0
            // set y as 0? everything else relative to this
        }
        let sides = ["cOne", "cTwo", "cThree", "cFour", "cFive", "cSix"]
        var connectedSides = NSMutableArray()
        
        for side in sides {
            if side != "" {
                connectedSides.add(side)
            }
        }
        for side in connectedSides {
            
            let info = (block.value(forKey: side as! String) as! String).components(separatedBy: ",")
            let blockNum = info[0]
            let sidePrimary = getSideNum(side: side as! String)
            let sideSecondary = Int(info[1])!
            let connected = blocks[blockNum]!
            
            if connected.located == true {
                continue
            }
            
            connected.xPos = prevX
            connected.yPos = prevY
            connected.zPos = prevZ
            
            
            // new useful code
            let firstIndex = block.relativeSideFaces().index(of: sidePrimary)
            let secondIndex = connected.relativeSideFaces().index(of: sideSecondary)
            let turn = rotations[firstIndex!]?[secondIndex!].degreesToRadians
            
            connected.yOri = (block.yOri + turn!) - (((block.yOri + turn!) / 360.degreesToRadians)*360.degreesToRadians)
            //
            
            let facing = block.getDirFacing(side: sidePrimary)
            
            if facing == "posX" {
                connected.xPos = prevX + 1.0
                connected.turnToFace(side: sideSecondary, dir: "negX")
            } else if facing == "negX" {
                connected.xPos = prevX - 1.0
                connected.turnToFace(side: sideSecondary, dir: "posX")
            } else if facing == "posY" {
                connected.yPos = prevY + 1.0
                connected.turnToFace(side: sideSecondary, dir: "negY")
            } else if facing == "negY" {
                connected.yPos = prevY - 1.0
                connected.turnToFace(side: sideSecondary, dir: "posY")
            } else if facing == "posZ" {
                connected.zPos = prevZ + 1.0
                connected.turnToFace(side: sideSecondary, dir: "negZ")
            } else if facing == "negZ" {
                connected.zPos = prevZ - 1.0
                connected.turnToFace(side: sideSecondary, dir: "posZ")
            }
            
           /* if sidePrimary == 1 {
                if block.faceUp == 1 {
                    if abs(block.yOri).radiansToDegrees == 90 {
                        
                    }
                } else if block.faceUp == 2 {
                    
                } else if block.faceUp == 5 {
                    let currentZ = prevZ + 1.0
                    connected.zPos = currentZ
                    /*if connected.faceUp == 1 {
                        if sideSecondary == 2 {
                            connected.yOri = 90.degreesToRadians
                        } else if sideSecondary == 4 {
                            connected.yOri = 270.degreesToRadians
                        } else if sideSecondary == 5 {
                            connected.yOri = 0.degreesToRadians
                        }  else if sideSecondary == 6 {
                            connected.yOri = 180.degreesToRadians
                        }
                    } else if connected.faceUp == 2 {
                        if sideSecondary == 1 {
                            connected.yOri = 180.degreesToRadians
                        } else if sideSecondary == 3 {
                            connected.yOri = 0.degreesToRadians
                        } else if sideSecondary == 5 {
                            connected.yOri = 270.degreesToRadians
                        }  else if sideSecondary == 6 {
                            connected.yOri = 90.degreesToRadians
                        }
                    } else if connected.faceUp == 3 {
                        if sideSecondary == 2 {
                            connected.yOri = 90.degreesToRadians
                        } else if sideSecondary == 4 {
                            connected.yOri = 270.degreesToRadians
                        } else if sideSecondary == 5 {
                            connected.yOri = 180.degreesToRadians
                        }  else if sideSecondary == 6 {
                            connected.yOri = 0.degreesToRadians
                        }
                    } else if connected.faceUp == 4 {
                        if sideSecondary == 1 {
                            connected.yOri = 180.degreesToRadians
                        } else if sideSecondary == 3 {
                            connected.yOri = 0.degreesToRadians
                        } else if sideSecondary == 5 {
                            connected.yOri = 90.degreesToRadians
                        }  else if sideSecondary == 6 {
                            connected.yOri = 270.degreesToRadians
                        }
                    } else if connected.faceUp == 5 {
                        if sideSecondary == 1 {
                            connected.yOri = 180.degreesToRadians
                        } else if sideSecondary == 2 {
                            connected.yOri = 90.degreesToRadians
                        } else if sideSecondary == 3 {
                            connected.yOri = 0.degreesToRadians
                        } else if sideSecondary == 4 {
                            connected.yOri = 270.degreesToRadians
                        }
                    } else if connected.faceUp == 6 {
                        if sideSecondary == 1 {
                            connected.yOri = 0.degreesToRadians
                        } else if sideSecondary == 2 {
                            connected.yOri = 90.degreesToRadians
                        } else if sideSecondary == 3 {
                            connected.yOri = 180.degreesToRadians
                        } else if sideSecondary == 4 {
                            connected.yOri = 270.degreesToRadians
                        }
                    }*/
                }
            } else if sidePrimary == 2 {
                
            } else if sidePrimary == 3 {
                
            } else if sidePrimary == 4 {
                
            } else if sidePrimary == 5 {
                
            } else if sidePrimary == 6 {
                
            }*/
            connected.located = true
            connections.add(connected)
        }
        
        if connections.count > 0 {
            for cube in connections {
                let newBlock = cube as! BlockModel
                locateConnections(block: newBlock, prevX: newBlock.xPos, prevY: newBlock.yPos, prevZ: newBlock.zPos)
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
        } else {// if side == "cSix" {
            return 6
        }
    
    }
    
}
