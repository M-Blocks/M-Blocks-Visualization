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
    
    // NETWORKING
    var feedItems: NSArray = NSArray()
    var selectedBlock : BlockModel = BlockModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
        setupScene()
        setupCamera()
        spawnShape()
        
        // NETWORKING
        let homeModel = HomeModel()
        homeModel.delegate = self
        homeModel.downloadItems()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var shouldAutorotate: Bool {
        return false
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
    
    func setupView() {
        //scnView = self.view as! SCNView
        
        // 1
        scnView.showsStatistics = true
        // 2
        scnView.allowsCameraControl = true
        // 3
        scnView.autoenablesDefaultLighting = true
        
        scnView.delegate = self
        scnView.isPlaying = true
        //scnView.playing = true
    }
    
    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene
        scnScene.background.contents = "Resources/Background_Diffuse.png"
    }

    func setupCamera() {
        // 1
        cameraNode = SCNNode()
        // 2
        cameraNode.camera = SCNCamera()
        // 3
        //cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 10)
        // 4
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    func spawnShape() {
        
        var geometry:SCNGeometry
        geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.2)
        
        let color = UIColor.orange
        geometry.materials.first?.diffuse.contents = color
        
        let geometryNode = SCNNode(geometry: geometry)
        
        /*geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        
        let force = SCNVector3(x: 0, y: 15, z: 0)
        let position = SCNVector3(x: 0.05, y: 0.05, z: 0.05)
        geometryNode.physicsBody?.applyForce(force, at: position, asImpulse: true)*/
        
        scnScene.rootNode.addChildNode(geometryNode)
    }
    
    func cleanScene() {
        // 1
        for node in scnScene.rootNode.childNodes {
            // 2
            if node.presentation.position.y < -2 {
                // 3
                node.removeFromParentNode()
            }
        }
    }
    
    func handleTouchFor(node: SCNNode) {
        
        // use node.name
        /*if node.name == "GOOD" {
            game.score += 1
            node.removeFromParentNode()
        } else if node.name == "BAD" {
            game.lives -= 1
            node.removeFromParentNode()
        }*/
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 1
        let touch = touches.first!
        // 2
        let location = touch.location(in: scnView)
        // 3
        let hitResults = scnView.hitTest(location, options: nil)
        // 4
        if hitResults.count > 0 {
            // 5
            let result = hitResults.first!
            // 6
            handleTouchFor(node: result.node)
        }
    }
    
    
    // NETWORKING
    func refresh() {
        let homeModel = HomeModel()
        homeModel.delegate = self
        homeModel.downloadItems()
    }
    func itemsDownloaded(_ items: NSArray) {
        feedItems = items
    }
    func sendMyRequest(_ data: String) {
        
        let scriptUrl = "http://mitmblocks.com/database_editor.php"
        var cubeNumber = "0"
        var xPos = "0"
        var yPos = "0"
        var zPos = "0"
        var xOri = "0"
        var yOri = "0"
        var zOri = "0"
        var color = "blue"
        
        
        
        if (data != "new") {
            var new_data = data.replacingOccurrences(of: "[", with: "")
            new_data = new_data.replacingOccurrences(of: "]", with: "")
            let usefulData = new_data.components(separatedBy: ", ")
            cubeNumber = usefulData[0]
            xPos = usefulData[1]
            yPos = usefulData[2]
            zPos = usefulData[3]
            xOri = usefulData[4]
            yOri = usefulData[5]
            zOri = usefulData[6]
            color = usefulData[7]
            if(color == "green") {
                color = "red"
            } else {
                color = "green"
            }
        } else {
            cubeNumber = String(Int(arc4random_uniform(UInt32(100))))
            xPos = String(Int(arc4random_uniform(UInt32(100))))
            yPos = String(Int(arc4random_uniform(UInt32(100))))
            zPos = String(Int(arc4random_uniform(UInt32(100))))
            xOri = String(Int(arc4random_uniform(UInt32(100))))
            yOri = String(Int(arc4random_uniform(UInt32(100))))
            zOri = String(Int(arc4random_uniform(UInt32(100))))
            color = "blue"
        }
        // Add one parameter
        //let urlWithParams = scriptUrl + "?cubeNumber=6&xPos=6&yPos=6&zPos=6&xOri=6&yOri=6&zOri=6"
        let urlWithParams = scriptUrl + "?cubeNumber=\(cubeNumber)&xPos=\(xPos)&yPos=\(yPos)&zPos=\(zPos)&xOri=\(xOri)&yOri=\(yOri)&zOri=\(zOri)&color=\(color)"
        
        print(urlWithParams)
        // Create NSURL Ibject
        let myUrl = URL(string: urlWithParams);
        
        // Creaste URL Request
        //let request = NSMutableURLRequest(url:myUrl!);
        
        // Set request HTTP method to GET. It could be POST as well
        //request.httpMethod = "GET"
        
        
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
    
}

extension ViewScreen: SCNSceneRendererDelegate {
    // 2
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        cleanScene()
        
    }
}



