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
    
    let urlPath: String = "http://mitmblocks.com/third_service.php"
    
    
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
            //print("Data downloaded")
            self.parseJSON()
        }
        
    }
    
    func parseJSON() {
        
        var jsonResult: Any
        var newJSONResult: NSArray = NSArray()
        do {
            jsonResult = try JSONSerialization.jsonObject(with: self.data as Data, options:JSONSerialization.ReadingOptions.allowFragments)//as! NSMutableArray
            newJSONResult = jsonResult as! NSArray
        } catch let error as NSError {
            print(error)
        }
        
        var jsonElement: NSDictionary = NSDictionary()
        let blocks: NSMutableArray = NSMutableArray()
        for thing in newJSONResult {
            jsonElement = thing as! NSDictionary
            
            let block = BlockModel()
            
            //the following insures none of the JsonElement values are nil through optional binding
            if  let blockNumber = (jsonElement["blockNumber"] as? String),
                let xPos = Int((jsonElement["xPos"] as? String)!),
                let yPos = Int((jsonElement["yPos"] as? String)!),
                let zPos = Int((jsonElement["zPos"] as? String)!),
                let xOri = Int((jsonElement["xOri"] as? String)!),
                let yOri = Int((jsonElement["yOri"] as? String)!),
                let zOri = Int((jsonElement["zOri"] as? String)!),
                let color = jsonElement["color"] as? String,
                let upFace = Int((jsonElement["upFace"] as? String)!)
            {
                block.blockNumber = blockNumber
                block.color = color
                block.xPos = Double(xPos)
                block.yPos = Double(yPos)
                block.zPos = Double(zPos)
                block.xOri = Double(xOri).degreesToRadians
                block.yOri = Double(yOri).degreesToRadians
                block.zOri = Double(zOri).degreesToRadians
                block.upFace = upFace
                
                let extras = ["lOne", "lTwo", "lThree", "lFour", "lFive", "lSix"]
                
                for e in extras {
                    if (jsonElement[e] as? String) != nil {
                        let l = (Int(jsonElement[e] as! String) == 0) ? 64 : Int(jsonElement[e] as! String)
                        block.setValue(l, forKey: e)
                    } else {
                        block.setValue(64, forKey: e)
                    }
                }
                
            }
            
            blocks.add(block)
        }
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.delegate.itemsDownloaded(blocks)
        })
    }
}
