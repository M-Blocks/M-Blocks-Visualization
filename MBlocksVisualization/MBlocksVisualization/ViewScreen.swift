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
    @IBOutlet weak var BlockNumberLabel: UILabel!
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    var lastTime: TimeInterval = 0
    var mainTimer = Timer()
    var mainTimerSeconds = 0
    var fps = 20
    var blockModels: [String:BlockModel] = [:]
    var totalRenders = 0
    var baseInitiated: Bool = false
    
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
        scnScene.physicsWorld.gravity = SCNVector3(0,0,0)
        scnView.scene = scnScene
    }

    // Sets up the camera to be used in our scene
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 20)
        
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    // FIX
    // Used to delete unnecessary objects
    func cleanScene() {
        for node in scnScene.rootNode.childNodes {
            if node.name == nil {
                continue
            }
            var exists = false
            for b in feedItems {
                let bl = b as! BlockModel
                if bl.blockNumber! == node.name! {
                    exists = true
                    break
                }
            }
            if !exists {
                print("\(node.name!) not exists")
                blockModels.removeValue(forKey: node.name!)
                node.removeFromParentNode()
            }
        }
        
    }
    
    // FIX
    // Handles what happens when a block is touched
    func handleTouchFor(node: SCNNode) {

        let box = blockModels[node.name!]!
        print("You touched: \(box.blockNumber), x: \(box.xPos), y: \(box.yPos), z: \(box.zPos)")
        //sendMyRequest(box)
        
    }
    
    // Finds out what block is touched and calls the function that deals with it
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: scnView)
        let hitResults = scnView.hitTest(location, options: nil)
        if hitResults.count > 0 {
            let result = hitResults.first!
            if result.node.name != nil {
                handleTouchFor(node: result.node)
                
                let material = result.node.geometry!.materials[result.geometryIndex]
                print("Side touched: \(material.name)")
            }
            
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
        BlockNumberLabel.text = "Blocks Avalaible: \(feedItems.count)"
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
        let urlWithParams = scriptUrl + "?cubeNumber=\(block.blockNumber!)&xPos=\(block.xPos)&yPos=\(block.yPos)&zPos=\(block.zPos)&xOri=\(block.xOri)&yOri=\(block.yOri)&zOri=\(block.zOri)&color=\(color)&colorGoal=\(color)"
        
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
        if !baseInitiated {
            setupBase()
        }
        
        for item in feedItems {
            let b = item as! BlockModel
            let cubeNum = b.blockNumber!
            let oldCube = blockModels[cubeNum]
            
            if oldCube != nil {
                /* first need to check if that blockModel even exists) */
                /* PROBABLY NEVER NEEDS RE RENDERING JUST TRANSLATION */
                /*if needsReRendering(old: oldCube!, new: b) {
                    print("Update old cube")
                    oldCube!.sceneNode?.removeFromParentNode()
                    addBlock(block: b, blockNum: cubeNum)
                } else {
                    
                }*/
                if needsReRendering(old: oldCube!, new: b) { // FIX: actually checking if needs update, not if needs rerendering
                    updateBlock(old: oldCube!, new: b)
                }
            } else {
                print("Add new cube")
                addBlock(block: b, blockNum: cubeNum)
            }
            
        }
        //print(totalRenders)
        
    }
    
    func setupBase() {
        var geometry:SCNGeometry
        geometry = SCNBox(width: 20.0, height: 1.0, length: 20.0, chamferRadius: 0.0)
        
        let color = UIColor.lightGray
        
        geometry.materials.first?.diffuse.contents = color
        
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = SCNVector3(x: 0, y: -1, z: 0)
        
        geometryNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        
        scnScene.rootNode.addChildNode(geometryNode)
        
        
        /*
        // new try
        let myFloor = SCNFloor()
        let myFloorNode = SCNNode(geometry: myFloor)
        myFloorNode.position = SCNVector3(x: 0, y: -0.5, z: 0)
        myFloor.reflectivity = 0.9
        myFloor.reflectionResolutionScaleFactor = 1.0
        myFloor.reflectionFalloffStart = 2.0
        myFloor.reflectionFalloffEnd = 10.0
        scnScene.rootNode.addChildNode(myFloorNode)
        //
         */
        
        baseInitiated = true
    }
    
    func addBlock(block: BlockModel, blockNum: String) {
        blockModels.updateValue(block, forKey: blockNum)
        
        var geometry:SCNGeometry
        geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.1)
        
        var color = UIColor.orange
        var hue = CGFloat(0.0)
        if block.color == "green" {
            color = UIColor.green
            hue = CGFloat(0.4)
        } else {
            color = UIColor.red
            hue = CGFloat(1.0)
        }
        geometry.materials.first?.diffuse.contents = color
        
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = SCNVector3(x: Float(block.xPos), y: Float(block.yPos), z: Float(block.zPos))
        geometryNode.name = block.blockNumber
        
        let sideOne = SCNMaterial()
        sideOne.diffuse.contents = UIColor(hue: 0.1, saturation: 0.7, brightness: CGFloat(Float(arc4random_uniform(128))/Float(128.0)), alpha: 1.0)
        sideOne.name = "sideOne"
        let sideTwo = SCNMaterial()
        sideTwo.diffuse.contents = UIColor(hue: 0.3, saturation: 0.7, brightness: CGFloat(Float(arc4random_uniform(128))/Float(128.0)), alpha: 1.0)
        sideTwo.name = "sideTwo"
        let sideThree = SCNMaterial()
        sideThree.diffuse.contents = UIColor(hue: 0.5, saturation: 0.7, brightness: CGFloat(Float(arc4random_uniform(128))/Float(128.0)), alpha: 1.0)
        sideThree.name = "sideThree"
        let sideFour = SCNMaterial()
        sideFour.diffuse.contents = UIColor(hue: 0.7, saturation: 0.7, brightness: CGFloat(Float(arc4random_uniform(128))/Float(128.0)), alpha: 1.0)
        sideFour.name = "sidefour"
        let sideFive = SCNMaterial()
        sideFive.diffuse.contents = UIColor(hue: 0.85, saturation: 0.7, brightness: CGFloat(Float(arc4random_uniform(128))/Float(128.0)), alpha: 1.0)
        sideFive.name = "sideFive"
        let sideSix = SCNMaterial()
        sideSix.diffuse.contents = UIColor(hue: 1.0, saturation: 0.7, brightness: CGFloat(Float(arc4random_uniform(128))/Float(128.0)), alpha: 1.0)
        sideSix.name = "sideSix"
        geometry.materials = [sideOne, sideTwo, sideThree, sideFour, sideFive, sideSix]
        
        geometryNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        
        
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
    
    func updateBlock(old: BlockModel, new: BlockModel) {
        let variables = ["xPos", "yPos", "zPos", "xOri", "yOri", "zOri", "color", "xPosGoal", "yPosGoal", "zPosGoal", "xOriGoal", "yOriGoal", "zOriGoal", "colorGoal"]
        
       /* for v in variables {
            if v == "xPos" {
                if abs(Float(old.xPos!)! - Float(new.xPos!)!) < 0.01 {
                    old.setValue((new.value(forKey: v) as! String), forKey: v)
                } else {
                    let deltaX = 0.2 * (Float(new.xPos!)! - Float(old.xPos!)!)
                    let newX = Float(old.value(forKey: v) as! String)! + deltaX
                    old.setValue(String(newX), forKey: "xPos")
                }
            } else {
                old.setValue((new.value(forKey: v) as! String), forKey: v)
            }
        }*/
        for v in variables {
            if ["xPos", "yPos", "zPos"].contains(v) {
                
                if abs(Float((old.value(forKey: v) as! String))! - Float((new.value(forKey: v) as! String))!) < 0.01 {
                    old.setValue((new.value(forKey: v) as! String), forKey: v)
                } else {
                    let deltaX = 0.15 * (Float((new.value(forKey: v) as! String))! - Float((old.value(forKey: v) as! String))!)
                    let newX = Float(old.value(forKey: v) as! String)! + deltaX
                    old.setValue(String(newX), forKey: v)
                }
            } else {
                old.setValue((new.value(forKey: v) as! String), forKey: v)
            }
        }
        
        var hue = CGFloat(0.0)
        if old.color == "green" {
            hue = CGFloat(0.4)
        } else {
            hue = CGFloat(1.0)
        }
        
        let x = Float(old.xPos)
        let y = Float(old.yPos)
        let z = Float(old.zPos)
        old.sceneNode?.position = SCNVector3(x: x, y: y, z: z)
        
        
        // pivot in negative x direction
        //pivotTowards(block: old, axis: "x", direction: 1)
        /*let pq = Double((old.sceneNode?.rotation.w)!)
        old.sceneNode?.pivot = SCNMatrix4MakeTranslation(-0.5, -0.5, 0)
        old.sceneNode?.position = SCNVector3(x: x-0.5, y: y-0.5, z: z)
        old.sceneNode?.rotation = SCNVector4(0,0,1, pq + 90.degreesToRadians)*/
        //old.sceneNode?.pivot = SCNMatrix4MakeTranslation(0.5, 0.5, 0)
        //old.sceneNode?.position = SCNVector3(x: x+0.5, y: y+0.5, z: z)
        // FIX: NEED TO RESET PIVOT
        
        /*for x in (old.sceneNode?.geometry?.materials)! {
            x.diffuse.contents = UIColor(hue: hue, saturation: 0.7, brightness: CGFloat(Float(arc4random_uniform(128))/Float(128.0)), alpha: 1.0)
        }*/
    }
    
    func checkCamera() {
        //let ang = scnView.pointOfView?.eulerAngles
        let pos = scnView.pointOfView?.position
        
        //print(scnView.pointOfView?.eulerAngles)
        /*if ang != nil {
            if ang!.x > 0 {
                scnView.allowsCameraControl = false
                scnView.pointOfView?.eulerAngles = SCNVector3(x: ang!.x - ang!.x, y: ang!.y, z: ang!.z)
            }
        }
        
        
        if pos != nil {
            if pos!.y < 0 {
                scnView.allowsCameraControl = false
                scnView.pointOfView?.position = SCNVector3(x: pos!.x, y: 0.0, z: pos!.z)
            } else {
                scnView.allowsCameraControl = true
            }
        }*/
        
        
    }
    
    func pivotTowards(block: BlockModel, axis: String, direction: Int) {
        let pq = Double((block.sceneNode?.rotation.w)!)
        let dir = Double(direction/abs(direction))
        var trans = [0.0, 0.0, 0.0]
        if axis == "x" {
            trans = [0.5*dir, 0.5*dir, 0.0]
        } else if axis == "y" {
            trans = [0.0, 0.5*dir, 0.5*dir]
        } else {
            trans = [0.5*dir, 0.0, 0.5*dir]
        }
        let x = Float(block.xPos)
        let y = Float(block.yPos)
        let z = Float(block.zPos)
        block.sceneNode?.pivot = SCNMatrix4MakeTranslation(Float(trans[0]), Float(trans[1]), Float(trans[2]))
        block.sceneNode?.position = SCNVector3(x: x+Float(trans[0]), y: y+Float(trans[1]), z: z)
        
        if axis == "x" {
            block.sceneNode?.rotation = SCNVector4(0,0,1, pq + 45.degreesToRadians)
        } else if axis == "y" {
            block.sceneNode?.rotation = SCNVector4(1,0,0, pq + 45.degreesToRadians)
        } else {
            block.sceneNode?.rotation = SCNVector4(0,1,0, pq + 45.degreesToRadians)
        }
        
    }
    
}

extension ViewScreen: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        checkCamera()
        reRender()
        lastTime = time
        cleanScene()
    }
}





