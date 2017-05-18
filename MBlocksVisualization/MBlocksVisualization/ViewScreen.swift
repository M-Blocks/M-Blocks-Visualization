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
    var firstTouch = ""
    let commands = ["Green", "Blue", "Red", "dance", "light", "climb", "sleep", "arrange"]
    var update = true
    
    // NETWORKING
    var feedItems: NSArray? = NSArray()
    var downloadRate = 4.0 //Hertz
    var lastTime: TimeInterval = 0
    var mainTimer = Timer()
    var mainTimerSeconds = 0.0
    var xOriBias: Float = 0.0;
    var yOriBias: Float = 0.0;
    var zOriBias: Float = 0.0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // GRAPHICS SETUP
        setupView()
        setupScene()
        setupCamera()
        setupBase()
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
        if feedItems != nil {
            for item in feedItems! {
                let b = item as! BlockModel
                let cubeNum = b.blockNumber
                let oldCube = blockModels[cubeNum]
                if (oldCube != nil) {
                    if needsUpdate(old: oldCube!, new: b)  && (update == true) {
                        updateBlock(old: oldCube!, new: b)
                    }
                } else {
                    print("Add new cube")
                    addBlock(block: b, blockNum: cubeNum)
                }
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
        
        blockModels.updateValue(block, forKey: blockNum)
        
        var geometry:SCNGeometry
        geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.1)
        
        var color = UIColor.orange
        geometry.materials.first?.diffuse.contents = color
        
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = SCNVector3(x: Float(block.xPos), y: Float(block.yPos), z: Float(block.zPos))
        geometryNode.name = block.blockNumber
        
        let sideOne = SCNMaterial()
        sideOne.diffuse.contents = UIColor(hue: 0.1, saturation: 1.0, brightness: CGFloat(Float(block.lOne)/Float(128.0)), alpha: 1.0)
        sideOne.name = "sideOne"
        let sideTwo = SCNMaterial()
        sideTwo.diffuse.contents = UIColor(hue: 0.3, saturation: 1.0, brightness: CGFloat(Float(block.lTwo)/Float(128.0)), alpha: 1.0)
        sideTwo.name = "sideTwo"
        let sideThree = SCNMaterial()
        sideThree.diffuse.contents = UIColor(hue: 0.5, saturation: 1.0, brightness: CGFloat(Float(block.lThree)/Float(128.0)), alpha: 1.0)
        sideThree.name = "sideThree"
        let sideFour = SCNMaterial()
        sideFour.diffuse.contents = UIColor(hue: 0.7, saturation: 1.0, brightness: CGFloat(Float(block.lFour)/Float(128.0)), alpha: 1.0)
        sideFour.name = "sidefour"
        let sideFive = SCNMaterial()
        sideFive.diffuse.contents = UIColor(hue: 0.85, saturation: 1.0, brightness: CGFloat(Float(block.lFive)/Float(128.0)), alpha: 1.0)
        sideFive.name = "sideFive"
        let sideSix = SCNMaterial()
        sideSix.diffuse.contents = UIColor(hue: 1.0, saturation: 1.0, brightness: CGFloat(Float(block.lSix)/Float(128.0)), alpha: 1.0)
        sideSix.name = "sideSix"
        geometry.materials = [sideOne, sideTwo, sideThree, sideFour, sideFive, sideSix]
        
        geometryNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        
        geometryNode.position = SCNVector3(x: Float(block.xPos), y: Float(block.yPos), z: Float(block.zPos))
        geometryNode.eulerAngles = SCNVector3(x: Float(block.xOri)+xOriBias.degreesToRadians, y: Float(block.yOri)+yOriBias.degreesToRadians, z: Float(block.zOri)+zOriBias.degreesToRadians)
        scnScene.rootNode.addChildNode(geometryNode)
        totalRenders = totalRenders+1
        block.setNode(node: geometryNode)
    }
    // Determines if a block needs to be moved/rerendered (aka if its data has changed)
    func needsUpdate(old: BlockModel, new: BlockModel) -> Bool {
        let ints = ["xPos", "yPos", "zPos", "xOri", "yOri", "zOri"]
        /*if (old.value(forKey: "color") as! String) != (new.value(forKey: "color") as! String) {
            print("Color is outdated (for cube \(old.blockNumber)). Update needed. ")
            return true
        }*/
        for v in ints {
            if (old.value(forKey: v) as! Int) != (new.value(forKey: v) as! Int) {
                print("\(v) is outdated. Translation/Rotation/ReRendering needed.")
                return true
            }
        }
        return false
    }
    func updateBlock(old: BlockModel, new: BlockModel) {
        
        let newPosition: [Int] = [new.value(forKey:"xPos") as! Int,new.value(forKey:"yPos") as! Int,new.value(forKey:"zPos") as! Int]
        let oldPosition: [Int] = [old.value(forKey:"xPos") as! Int,new.value(forKey:"yPos") as! Int,new.value(forKey:"zPos") as! Int]
        var animate = false
        if newPosition != oldPosition {
            var diff = 0
            if (newPosition[0] == oldPosition[0]+1) || (newPosition[0] == oldPosition[0]-1) {
                diff += 1
            } else if (newPosition[1] == oldPosition[1]+1) || (newPosition[1] == oldPosition[1]-1) {
                diff += 1
            } else if (newPosition[1] == oldPosition[1]+1) || (newPosition[1] == oldPosition[1]-1) {
                diff += 1
            }
            
            if diff < 3 {
                animate = true
            }
        }
        
        if animate == true {
            old.positionQueue.append(newPosition)
        } else {
            let variables = ["xPos", "yPos", "zPos", "xOri", "yOri", "zOri"]
            for v in variables {
                old.setValue(new.value(forKey: v), forKey: v)
            }
        }
        
        old.sceneNode?.position = SCNVector3(x: Float(old.xPos), y: Float(old.yPos), z: Float(old.zPos))
        old.sceneNode?.eulerAngles = SCNVector3(x: Float(old.xOri), y: Float(old.yOri), z: Float(old.zOri))
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
            for b in feedItems! {
                let bl = b as! BlockModel
                if bl.blockNumber == node.name! {
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
        print("You touched: Block \(box.blockNumber)(\(box.xPos),\(box.yPos),\(box.zPos))[\(box.xOri.radiansToDegrees),\(box.yOri.radiansToDegrees),\(box.zOri.radiansToDegrees)] on side \(sideName)")
        
        if firstTouch == "" {
            firstTouch = box.blockNumber
            box.highlight()
        } else {
            if box.blockNumber == firstTouch {
                firstTouch = ""
                box.highlight(false)
            } else {
                let side = getSideNum(side: sideName)
                let first = blockModels[firstTouch]!
                sendMyRequest(first, pos: box.getNeighboringPos(side: side))
                first.highlight(false)
                firstTouch = ""
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
        //cell.commandButton.setBackgroundImage(UIImage(named: "selected.png"), for: UIControlState.highlighted)
        cell.commandButton.setTitleColor(UIColor.white, for: UIControlState.highlighted)
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
        BlockNumberLabel.text = "Blocks Avalaible: \(feedItems!.count)"
    }
    // sends command for reset
    func resetDatabase() {
        print("Sending a request for reset")
        let scriptUrl = "http://mitmblocks.com/reset.php"
        let urlWithParams = scriptUrl
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
        
        let scriptUrl2 = "http://mitmblocks.com/commands_editor.php"
        let urlWithParams2 = scriptUrl2 + "?blockNum=\(0)&command=find_connections"
        let myUrl2 = URL(string: urlWithParams2);
        let task2 = URLSession.shared.dataTask(with: myUrl2!) { data, response, error in
            guard error == nil else {
                print(error as Any)
                return
            }
            guard data != nil else {
                print("Data is empty")
                return
            }
        }
        firstTouch = ""
        task2.resume()
    }
    // Sends request to follow a certain command
    func sendCommand(_ command: String) {
        if blockModels[firstTouch] != nil {
            let b = blockModels[firstTouch]!
            
            let colors = ["green", "blue", "red"]
            if colors.contains(command.lowercased()) {
                b.color = command.lowercased()
                print(b.color)
                print("changing color")
            }
            
            print("Sending a request for Block \(b.blockNumber)  to \(command)")
            let scriptUrl = "http://mitmblocks.com/commands_editor.php"
            let urlWithParams = scriptUrl + "?blockNum=\(b.blockNumber)&command=\(command)"
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
        
        let scriptUrl = "http://mitmblocks.com/commands_editor.php"
        let urlWithParams = scriptUrl + "?blockNum=\(block.blockNumber)&command=\(block.color)"
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
    @IBAction func clickResetButton(_ sender: Any) {
        resetDatabase()
    }
    @IBAction func clickXButton(_ sender: Any) {
        xOriBias += 1
        if(xOriBias == 4) {
            xOriBias = 0
        }
        for c in scnScene.rootNode.childNodes {
            if (c.name != nil) { // has a name, is a cube, probably HAVE TO FIX THIS
                var flip: Float = 1.0
                if(Int(xOriBias) % 2 == 0) {
                    flip = -1.0
                }
                print("//////")
                print("old: \(c.position) and \(c.eulerAngles)")
                //c.position = SCNVector3(x: c.position.x, y: c.position.z*flip, z: c.position.y)
                /*c.eulerAngles = SCNVector3(x: Float(((Int(c.eulerAngles.x.radiansToDegrees) + 90)%360).degreesToRadians), y:c.eulerAngles.y, z: c.eulerAngles.z)
                print("new: \(c.position) and \(c.eulerAngles)")
                scnScene.rootNode.ch*/
                
                /*let animation = CABasicAnimation(keyPath: "transform.scale.x")
                animation.isRemovedOnCompletion = false
                animation.fillMode = kCAFillModeForwards
                animation.fromValue = 1
                animation.toValue = 2
                c.addAnimation(animation, forKey: "");*/
                
                var spin = CABasicAnimation(keyPath: "rotation")
                //spin.fromValue = NSValue(scnVector4: SCNVector4(x: 1, y: 0, z: 0, w: 0))
                //spin.toValue = NSValue(scnVector4: SCNVector4(x: 1, y: 0, z: 0, w: Float(M_PI)))

                //print(c.orientation)
                //spin.fromValue = NSValue(scnVector4: c.orientation)
                var xx = c.position.x
                var yy = c.position.y
                var zz = c.position.z
                c.position = SCNVector3(xx+0, yy-0.5, zz+0.5)
                c.pivot = SCNMatrix4MakeTranslation(0, -0.5, 0.5)
                spin.byValue = NSValue(scnVector4: SCNVector4(x: 1, y: 0, z: 0, w: Float(M_PI/2)))
                spin.duration = 1
                spin.repeatCount = 0
                spin.isRemovedOnCompletion = false
                spin.fillMode = kCAFillModeForwards
                c.addAnimation(spin, forKey: "spin around")
                //c.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float(M_PI/2))
                
                
                /*let pyramid = SCNPyramid(width: 1.0, height: 1.0, length: 1.0)
                let pyramidNode = SCNNode(geometry: pyramid)
                pyramidNode.position = SCNVector3(x: 0, y: 0, z: 0)
                pyramidNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float(M_PI / 2))
                scnScene.rootNode.addChildNode(pyramidNode)
                
                // But the animation seems to rotate aroun 2 axis and not just z
                var spin = CABasicAnimation(keyPath: "rotation")
                spin.byValue = NSValue(scnVector4: SCNVector4(x: 0, y: 0, z: 1, w: 2*Float(M_PI)))
                spin.duration = 3
                spin.repeatCount = 0
                pyramidNode.addAnimation(spin, forKey: "spin around")*/
                
            }
            
        }
    }
    @IBAction func clickYButton(_ sender: Any) {
        yOriBias += 1
        if(yOriBias == 4) {
            yOriBias = 0
        }
        for c in scnScene.rootNode.childNodes {
            if (c.name != nil) { // has a name, is a cube, probably HAVE TO FIX THIS
                var flip: Float = 1.0
                if(Int(yOriBias) % 2 == 0) {
                    flip = -1.0
                }
                c.position = SCNVector3(x: c.position.z, y: c.position.y, z: c.position.x*flip)
                c.eulerAngles = SCNVector3(x: c.eulerAngles.x, y:c.eulerAngles.y + Float(90).degreesToRadians, z: c.eulerAngles.z)
            }
        }
    }
    @IBAction func clickZButton(_ sender: Any) {
        zOriBias += 1
        if(zOriBias == 4) {
            zOriBias = 0
        }
        for c in scnScene.rootNode.childNodes {
            if (c.name != nil) { // has a name, is a cube, probably HAVE TO FIX THIS
                var flip: Float = 1.0
                if(Int(zOriBias) % 2 == 0) {
                    flip = -1.0
                }
                print("//////")
                print("old: \(c.position) and \(c.eulerAngles)")
                c.position = SCNVector3(x: c.position.y, y: c.position.x*flip, z: c.position.z)
                c.eulerAngles = SCNVector3(x: c.eulerAngles.x, y:c.eulerAngles.y, z: c.eulerAngles.z + Float(90).degreesToRadians)
                print("new: \(c.position) and \(c.eulerAngles)")
            }
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
