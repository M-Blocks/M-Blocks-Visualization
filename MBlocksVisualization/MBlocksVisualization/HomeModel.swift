//
//  HomeModel.swift
//  MBlocksVisualization
//
//  Created by Mateo Correa on 9/21/16.
//  Copyright © 2016 CSAIL. All rights reserved.
//

import Foundation

protocol HomeModelProtocal: class {
    func itemsDownloaded(_ items: NSArray)
}

class HomeModel: NSObject, URLSessionDataDelegate {
    
    //properties
    
    weak var delegate: HomeModelProtocal!
    
    var data : NSMutableData = NSMutableData()
    
    let urlPath: String = "http://mitmblocks.com/service.php"
    
    
    func downloadItems() {
        
        let url: URL = URL(string: urlPath)!
        var session: Foundation.URLSession!
        let configuration = URLSessionConfiguration.default
        
        session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        let task = session.dataTask(with: url)
        
        task.resume()
        
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.data.append(data);
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            print("Failed to download data")
        }else {
            print("Data downloaded")
            self.parseJSON()
        }
        
    }
    
    func parseJSON() {
        
        var jsonResult: Any
        var newJSONResult: NSArray = NSArray()
        do{
            jsonResult = try JSONSerialization.jsonObject(with: self.data as Data, options:JSONSerialization.ReadingOptions.allowFragments)//as! NSMutableArray
            newJSONResult = jsonResult as! NSArray
        } catch let error as NSError {
            print(error)
            
        }
        
        print(newJSONResult)
        var jsonElement: NSDictionary = NSDictionary()
        let blocks: NSMutableArray = NSMutableArray()
        
        for thing in newJSONResult {
            jsonElement = thing as! NSDictionary
            
            let block = BlockModel()
            
            //the following insures none of the JsonElement values are nil through optional binding
            if  let cubeNumber = jsonElement["cubeNumber"] as? String,
                let xPos = jsonElement["xPos"] as? String,
                let yPos = jsonElement["yPos"] as? String,
                let zPos = jsonElement["zPos"] as? String,
                let xOri = jsonElement["xOri"] as? String,
                let yOri = jsonElement["zOri"] as? String,
                let zOri = jsonElement["zOri"] as? String,
                let color = jsonElement["color"] as? String,
                let blockType = jsonElement["blockType"] as? String,
                let xPosGoal = jsonElement["xPosGoal"] as? String,
                let yPosGoal = jsonElement["yPosGoal"] as? String,
                let zPosGoal = jsonElement["zPosGoal"] as? String,
                let xOriGoal = jsonElement["xOriGoal"] as? String,
                let yOriGoal = jsonElement["zOriGoal"] as? String,
                let zOriGoal = jsonElement["zOriGoal"] as? String
            {
                block.cubeNumber = cubeNumber
                block.xPos = xPos
                block.yPos = yPos
                block.zPos = zPos
                block.xOri = xOri
                block.yOri = yOri
                block.zOri = zOri
                block.color = color
                block.cubeType = blockType
                block.xPosGoal = xPosGoal
                block.yPosGoal = yPosGoal
                block.zPosGoal = zPosGoal
                block.xOriGoal = xOriGoal
                block.yOriGoal = yOriGoal
                block.zOriGoal = zOriGoal
                
            }
            
            blocks.add(block)
        }
        
        DispatchQueue.main.async(execute: { () -> Void in
            
            self.delegate.itemsDownloaded(blocks)
            
        })
    }
}
