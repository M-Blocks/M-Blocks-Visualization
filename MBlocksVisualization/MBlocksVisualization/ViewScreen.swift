//
//  ViewScreen.swift
//  MBlocksVisualization
//
//  Created by Mateo Correa on 9/21/16.
//  Copyright © 2016 CSAIL. All rights reserved.
//

import UIKit
import SceneKit

class ViewScreen: UIViewController, HomeModelProtocal, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // GUI
    @IBOutlet weak var colView: UICollectionView!
    @IBOutlet weak var scnView: SCNView!
    @IBOutlet weak var BlockNumberLabel: UILabel!
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    var blockModels: [String:BlockModel] = [:]
    var totalRenders = 0
    var baseInitiated: Bool = false
    var posCalc: PositionCalculator?
    var firstTouch = ""
    let commands = ["Green", "Blue", "Red", "Flip", "Traverse", "Climb", "Jump", "Spin", "360"]
    
    // NETWORKING
    var feedItems: NSArray = NSArray()
    var downloadRate = 2.0 //Hertz
    var lastTime: TimeInterval = 0
    var mainTimer = Timer()
    var mainTimerSeconds = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // GRAPHICS SETUP
        setupView()
        setupScene()
        setupCamera()
        colView.delegate = self
        colView.dataSource = self
        
        // NETWORKING
        let homeModel = HomeModel()
        homeModel.delegate = self
        homeModel.downloadItems()
        
        // Sets up a 1 second timer that calls timerActions()
        mainTimer = Timer.scheduledTimer(timeInterval: 1.0/downloadRate, target: self, selector: #selector(ViewScreen.timerActions), userInfo: nil, repeats: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override var shouldAutorotate: Bool { return true }
    override var prefersStatusBarHidden: Bool { return true }
    
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    /////////////////// GRAPHICS //////////////////////
    // Sets up the options of the SceneView
    func setupView() {
        scnView.showsStatistics = false
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
    func reRender() {
        if !baseInitiated {
            setupBase()
        }
        for item in feedItems {
            let b = item as! BlockModel
            let cubeNum = b.blockNumber!
            let oldCube = blockModels[cubeNum]
            if oldCube != nil {
                if needsUpdate(old: oldCube!, new: b) {
                    updateBlock(old: oldCube!, new: b)
                }
            } else {
                print("Add new cube")
                addBlock(block: b, blockNum: cubeNum)
            }
            
        }
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
        baseInitiated = true
    }
    func addBlock(block: BlockModel, blockNum: String) {
        
        posCalc?.position(block: block)
        blockModels.updateValue(block, forKey: blockNum)
        
        var geometry:SCNGeometry
        geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.1)
        
        var color = UIColor.orange
        var hue = CGFloat(0.0) // FIX: ACTUALLY USE HUE
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
        sideOne.diffuse.contents = UIColor(hue: 0.1, saturation: 0.7, brightness: CGFloat(Float(block.lOne)/Float(128.0)), alpha: 1.0)
        sideOne.name = "sideOne"
        let sideTwo = SCNMaterial()
        sideTwo.diffuse.contents = UIColor(hue: 0.3, saturation: 0.7, brightness: CGFloat(Float(block.lTwo)/Float(128.0)), alpha: 1.0)
        sideTwo.name = "sideTwo"
        let sideThree = SCNMaterial()
        sideThree.diffuse.contents = UIColor(hue: 0.5, saturation: 0.7, brightness: CGFloat(Float(block.lThree)/Float(128.0)), alpha: 1.0)
        sideThree.name = "sideThree"
        let sideFour = SCNMaterial()
        sideFour.diffuse.contents = UIColor(hue: 0.7, saturation: 0.7, brightness: CGFloat(Float(block.lFour)/Float(128.0)), alpha: 1.0)
        sideFour.name = "sidefour"
        let sideFive = SCNMaterial()
        sideFive.diffuse.contents = UIColor(hue: 0.85, saturation: 0.7, brightness: CGFloat(Float(block.lFive)/Float(128.0)), alpha: 1.0)
        sideFive.name = "sideFive"
        let sideSix = SCNMaterial()
        sideSix.diffuse.contents = UIColor(hue: 1.0, saturation: 0.7, brightness: CGFloat(Float(block.lSix)/Float(128.0)), alpha: 1.0)
        sideSix.name = "sideSix"
        geometry.materials = [sideOne, sideTwo, sideThree, sideFour, sideFive, sideSix]
        
        geometryNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        
        geometryNode.position = SCNVector3(x: Float(block.xPos), y: Float(block.yPos), z: Float(block.zPos))
        geometryNode.eulerAngles = SCNVector3(x: Float(block.xOri), y: Float(block.yOri), z: Float(block.zOri))
        scnScene.rootNode.addChildNode(geometryNode)
        totalRenders = totalRenders+1
        block.setNode(node: geometryNode)
    }
    // Determines if a block needs to be moved/rerendered (aka if its data has changed)
    func needsUpdate(old: BlockModel, new: BlockModel) -> Bool {
        let strs = ["cOne", "cTwo", "cThree", "cFour", "cFive", "cSix"]
        let ints = ["upFace", "lOne", "lTwo", "lThree", "lFour", "lFive", "lSix"]
        for v in strs {
            if (old.value(forKey: v) as! String) != (new.value(forKey: v) as! String) {
                print("\(v) is outdated. Translation/Rotation needed. ")
                return true
            }
        }
        for v in ints {
            if (old.value(forKey: v) as! Int) != (new.value(forKey: v) as! Int) {
                print("\(v) is outdated. Translation/Rotation/ReRendering needed.")
                return true
            }
        }
        return false
    }
    // FIX, MAKE SURE TO UPDATE SIDE LIGHTING
    func updateBlock(old: BlockModel, new: BlockModel) {
        let variables = ["upFace", "cOne", "cTwo", "cThree", "cFour", "cFive", "cSix", "lOne", "lTwo", "lThree", "lFour", "lFive", "lSix"]
        for v in variables {
            old.setValue(new.value(forKey: v), forKey: v)
        }
        old.setXZOri()
        old.located = false
        posCalc?.position(block: old)
        
        let mat = old.sceneNode?.geometry!.materials
        let lights = [old.lOne, old.lTwo, old.lThree, old.lFour, old.lFive, old.lSix]
        // FIX, SET HUE AND SATURATION AND USE IT
        var hue = CGFloat(0.0)
        if old.color == "green" {
            hue = CGFloat(0.4)
        } else {
            hue = CGFloat(1.0)
        }
        for i in 0..<5 {
            mat?[i].diffuse.contents = UIColor(hue: 0.5, saturation: 0.7, brightness: CGFloat(Float(lights[i])/Float(128.0)), alpha: 1.0)
        }
        old.sceneNode?.position = SCNVector3(x: Float(old.xPos), y: Float(old.yPos), z: Float(old.zPos))
        old.sceneNode?.eulerAngles = SCNVector3(x: Float(old.xOri), y: Float(old.yOri), z: Float(old.zOri))
        print(old.sceneNode?.position as Any)
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
    // Handles what happens when a block is touched
    func handleTouchFor(node: SCNNode, sideName: String) {
        let box = blockModels[node.name!]!
        print("You touched: Block \(box.blockNumber!)(\(box.xPos),\(box.yPos),\(box.zPos)) on side \(sideName)")
        print("Fully positioned: \(box.located)")
        
        if firstTouch == "" {
            firstTouch = box.blockNumber!
            box.highlight()
        } else {
            if box.blockNumber! == firstTouch {
                firstTouch = ""
                box.highlight(false)
            } else {
                if box.located == true {
                    let side = getSideNum(side: sideName)
                    let first = blockModels[firstTouch]!
                    sendMyRequest(first, pos: box.getNeighboringPos(side: side))
                    first.highlight(false)
                    firstTouch = ""
                } else {
                    print("Can't use this side because it's position isn't completely constrained")
                }
            }
        }
    }
    // Finds out what block is touched and calls the function that deals with it
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: scnView)
        let hitResults = scnView.hitTest(location, options: nil)
        if hitResults.count > 0 {
            let result = hitResults.first!
            if result.node.name != nil {
                let material = result.node.geometry!.materials[result.geometryIndex]
                handleTouchFor(node: result.node, sideName: material.name!)
            }
        }
    }
    // COLLECTION ROW STUFF
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return commands.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "commandCell", for: indexPath) as! CommandCell
        cell.commandButton.setTitle(commands[indexPath.item], for: UIControlState.normal)
        cell.commandButton.setBackgroundImage(UIImage(named: "selected.png"), for: UIControlState.highlighted)
        cell.delegate = self
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow:CGFloat = 8
        let hardCodedPadding:CGFloat = 5
        let itemWidth = (collectionView.bounds.width / itemsPerRow) - hardCodedPadding
        let itemHeight = collectionView.bounds.height - (2 * hardCodedPadding)
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    /////////////////// NETWORKING //////////////////////
    func timerActions() {
        mainTimerSeconds += 1.0/downloadRate /// keeps track of time
        downloadData() // downloads cube data
    }
    // Downloads data from database
    func downloadData() {
        let homeModel = HomeModel()
        homeModel.delegate = self
        homeModel.downloadItems()
    }
    // Updates app's list of blocks
    func itemsDownloaded(_ items: NSArray) {
        feedItems = items
        BlockNumberLabel.text = "Blocks Avalaible: \(feedItems.count)"
        if posCalc == nil {
            posCalc = PositionCalculator(list: items as! [BlockModel])
        }
    }
    // Sends request to follow a certain command
    func sendCommand(_ command: String) {
        if blockModels[firstTouch] != nil {
            let b = blockModels[firstTouch]!
            print("Sending a request for Block \(b.blockNumber!)  to \(command)")
            let scriptUrl = "http://mitmblocks.com/goals_database_editor.php"
            let urlWithParams = scriptUrl + "?blockNumber=\(b.blockNumber!)&xPos=\(b.xPos)&yPos=\(b.yPos)&zPos=\(b.zPos)&command=\(command)"
            print(urlWithParams)
            
            let myUrl = URL(string: urlWithParams);
            let task = URLSession.shared.dataTask(with: myUrl!) { data, response, error in
                guard error == nil else {
                    print(error as Any)
                    return
                }
                guard data != nil else {
                    print("Data is empty")
                    return
                }
            }
            b.highlight(false)
            firstTouch = ""
            task.resume()
        }
    }
    // Sends request to move to a certain position
    func sendMyRequest(_ block: BlockModel, pos: [Double]) {
        print("Sending a request to move block \(block.blockNumber) to \(pos)")
        
        let scriptUrl = "http://mitmblocks.com/goals_database_editor.php"
        let urlWithParams = scriptUrl + "?blockNumber=\(block.blockNumber!)&xPos=\(pos[0])&yPos=\(pos[1])&zPos=\(pos[2])&command=\(block.color)"
        print(urlWithParams)
        
        let myUrl = URL(string: urlWithParams);
        let task = URLSession.shared.dataTask(with: myUrl!) { data, response, error in
            guard error == nil else {
                print(error as Any)
                return
            }
            guard data != nil else {
                print("Data is empty")
                return
            }
        }
        task.resume()
    }
    
    func getSideNum(side: String) -> Int {
        if side == "sideOne" {
            return 1
        } else if side == "sideTwo" {
            return 2
        } else if side == "sideThree" {
            return 3
        } else if side == "sideFour" {
            return 4
        } else if side == "sideFive" {
            return 5
        } else { //side == "cSix" {
            return 6
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
