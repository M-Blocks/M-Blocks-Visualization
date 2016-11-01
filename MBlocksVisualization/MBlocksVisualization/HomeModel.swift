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
    
    let urlPath: String = "http://mitmblocks.com/new_service.php"
    
    
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
        do{
            jsonResult = try JSONSerialization.jsonObject(with: self.data as Data, options:JSONSerialization.ReadingOptions.allowFragments)//as! NSMutableArray
            newJSONResult = jsonResult as! NSArray
        } catch let error as NSError {
            print(error)
            
        }
        
        var jsonElement: NSDictionary = NSDictionary()
        let blocks: NSMutableArray = NSMutableArray()
        //print(newJSONResult)
        for thing in newJSONResult {
            jsonElement = thing as! NSDictionary
            
            let block = BlockModel()
            
            //the following insures none of the JsonElement values are nil through optional binding
            if  let blockNumber = jsonElement["blockNumber"] as? String,
                let upFace = Int((jsonElement["upFace"] as? String)!),
                let cOne = jsonElement["cOne"] as? String,
                let cTwo = jsonElement["cTwo"] as? String,
                let cThree = jsonElement["cThree"] as? String,
                let cFour = jsonElement["cFour"] as? String,
                let cFive = jsonElement["cFive"] as? String,
                let cSix = jsonElement["cSix"] as? String
            {
                block.blockNumber = blockNumber
                block.upFace = upFace
                block.cOne = cOne
                block.cTwo = cTwo
                block.cThree = cThree
                block.cFour = cFour
                block.cFive = cFive
                block.cSix = cSix
                block.setXZOri()
                
                let extras = ["lOne", "lTwo", "lThree", "lFour", "lFive", "lSix"]
                
                for e in extras {
                    if (jsonElement[e] as? String) != nil {
                        block.setValue(Int(jsonElement[e] as! String), forKey: e)
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
