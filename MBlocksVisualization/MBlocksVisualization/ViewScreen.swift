//
//  ViewScreen.swift
//  MBlocksVisualization
//
//  Created by Mateo Correa on 9/21/16.
//  Copyright © 2016 CSAIL. All rights reserved.
//

import UIKit
import SceneKit

class ViewScreen: UIViewController, HomeModelProtocal {

    @IBOutlet weak var scnView: SCNView!
    //var scnView: SCNView!
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    var lastTime: TimeInterval = 0
    var mainTimer = Timer()
    var mainTimerSeconds = 0
    var fps = 20
    var blockModels: [String:BlockModel] = [:]
    var totalRenders = 0
    
    // NETWORKING
    var feedItems: NSArray = NSArray()
    var selectedBlock : BlockModel = BlockModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // GRAPHICS SETUP
        setupView()
        setupScene()
        setupCamera()
        
        // NETWORKING
        let homeModel = HomeModel()
        homeModel.delegate = self
        homeModel.downloadItems()
        
        // Sets up a 1 second timer that calls timerActions()
        mainTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ViewScreen.timerActions), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func timerActions() {
        mainTimerSeconds += 1 /// keeps track of time
        
        downloadData() // downloads cube data
    }

    // Sets up the options of the SceneView
    func setupView() {
        scnView.showsStatistics = true
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.delegate = self
        scnView.isPlaying = true
    }
    
    // Sets up the sceen that will be placed in the SceneView
    func setupScene() {
        scnScene = SCNScene()
        scnScene.background.contents = "Resources/Background_Diffuse.png"
        
        scnView.scene = scnScene
    }

    // Sets up the camera to be used in our scene
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: -5)
        
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    // FIX
    // Used to delete unnecessary objects
    func cleanScene() {
        for node in scnScene.rootNode.childNodes {
            if node.presentation.position.y < -2 {
                node.removeFromParentNode()
            }
        }
    }
    
    // FIX
    // Handles what happens when a block is touched
    func handleTouchFor(node: SCNNode) {
        let box = blockModels[node.name!]!
        
        print("You touched: \(box.cubeNumber), x: \(box.xPos), y: \(box.yPos), z: \(box.zPos)")
        sendMyRequest(box)
    }
    
    // Finds out what block is touched and calls the function that deals with it
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: scnView)
        let hitResults = scnView.hitTest(location, options: nil)
        if hitResults.count > 0 {
            let result = hitResults.first!
            handleTouchFor(node: result.node)
        }
    }
    
    
    // NETWORKING
    func downloadData() {
        let homeModel = HomeModel()
        homeModel.delegate = self
        homeModel.downloadItems()
    }
    func itemsDownloaded(_ items: NSArray) {
        feedItems = items
    }
    // Sends updated Block data to the database
    func sendMyRequest(_ block: BlockModel) {
        print("sending a reqeust")
        
        let scriptUrl = "http://mitmblocks.com/database_editor.php"
        
        var color = "white"
        if block.color == "green" {
            color = "red"
        } else {
            color = "green"
        }
        
        //FIX currently is sending color for color, but color should be sent for colorGoal, the
        // cube should then change it's color to colorGoal and it should edit the color in the database
        let urlWithParams = scriptUrl + "?cubeNumber=\(block.cubeNumber!)&xPos=\(block.xPos!)&yPos=\(block.yPos!)&zPos=\(block.zPos!)&xOri=\(block.xOri!)&yOri=\(block.yOri!)&zOri=\(block.zOri!)&color=\(color)&xPosGoal=\(block.xPosGoal!)&yPosGoal=\(block.yPosGoal!)&zPosGoal=\(block.zPosGoal!)&xOriGoal=\(block.xOriGoal!)&yOriGoal=\(block.yOriGoal!)&zOriGoal=\(block.zOri!)&colorGoal=\(color)&blockType=\(block.blockType!)"
        
        print(urlWithParams)
        
        let myUrl = URL(string: urlWithParams);
        
        let task = URLSession.shared.dataTask(with: myUrl!) { data, response, error in
            guard error == nil else {
                print(error)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
        }
        
        task.resume()
    }
    
    func reRender() {
        for item in feedItems {
            let b = item as! BlockModel
            let cubeNum = b.cubeNumber!
            let oldCube = blockModels[cubeNum]
            
            if oldCube != nil {
                /* first need to check if that blockModel even exists) */
                /* PROBABLY NEVER NEEDS RE RENDERING JUST TRANSLATION */
                if needsReRendering(old: oldCube!, new: b) {
                    print("Update old cube")
                    oldCube!.sceneNode?.removeFromParentNode()
                    addBlock(block: b, blockNum: cubeNum)
                } else {
                    
                }
            } else {
                print("Add new cube")
                addBlock(block: b, blockNum: cubeNum)
            }
            
        }
        print(totalRenders)
        
    }
    
    func addBlock(block: BlockModel, blockNum: String) {
        blockModels.updateValue(block, forKey: blockNum)
        
        var geometry:SCNGeometry
        geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.1)
        
        var color = UIColor.orange
        if block.color == "green" {
            color = UIColor.green
        } else {
            color = UIColor.red
        }
        geometry.materials.first?.diffuse.contents = color
        
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = SCNVector3(x: Float(block.xPos!)!, y: Float(block.yPos!)!, z: Float(block.zPos!)!)
        
        geometryNode.name = block.cubeNumber
        
        scnScene.rootNode.addChildNode(geometryNode)
        totalRenders = totalRenders+1
        block.setNode(node: geometryNode)
    }
    
    // Determines if a block needs to be moved/rerendered (aka if its data has changed)
    func needsReRendering(old: BlockModel, new: BlockModel) -> Bool {
        let variables = ["xPos", "yPos", "zPos", "xOri", "yOri", "zOri", "color", "xPosGoal", "yPosGoal", "zPosGoal", "xOriGoal", "yOriGoal", "zOriGoal", "colorGoal"]
        
        for v in variables {
            if (old.value(forKey: v) as! String) != (new.value(forKey: v) as! String) {
                print("\(v) is outdated. ReRendering/Translation needed.")
                return true
            }
        }
        return false
    }
    
}

extension ViewScreen: SCNSceneRendererDelegate {
    // 2
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        reRender()
        lastTime = time
        cleanScene()
    }
}





