//
//  GameViewController.swift
//  Test-Game-SceneKit
//
//  Created by Nikolay Sorokin on 23.10.2020.
//

import SceneKit

class GameViewController: UIViewController {
    
    // MARK: - Outlets
    let label = UILabel()
    
    // MARK: - Properties
    var duration: TimeInterval = 5
    var score = 0 {
        didSet {
            label.text = "Варя ты сбила \(score)" // Sorry. String for daughter
        }
    }
    var ship: SCNNode!
    
    // MARK: - Methods
    func addLabel () {
        label.frame = CGRect(x: 0, y: 0, width: scnView.frame.width, height: 100)
        label.font = UIFont.systemFont(ofSize: 20)
        label.numberOfLines = 2
        label.textAlignment = .center
        scnView.addSubview(label)
        score = 0
    }
    
    func addShip() {
        // Move ship farther from view
        let x = Int.random(in: -25...25)
        let y = Int.random(in: -25...25)
        let z = -105
        ship.position = SCNVector3(x, y, z)
        
        // Move the ship look at given point
        ship.look(at: SCNVector3 (2 * x, 2 * y, 2 * z ))
        
        // Animate ship movement towards camera
        ship.runAction(.move(to: SCNVector3(), duration: duration)) {
        self.ship.removeFromParentNode()
            
            DispatchQueue.main.async {
                self.label.text = "Ты можешь лучше\nПродолжай = \(self.score)"
            }

        }
        // add ship to the scene
        scnView.scene?.rootNode.addChildNode(ship)
    }
    // TODO: Do something
    func getShip() -> SCNNode {
        // Get scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Retrieve the ship node
        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!.clone()
        return ship
    }
    func removeShip () {
        // Remove the ship
        scnView.scene?.rootNode.childNode(withName: "ship", recursively: true)?.removeFromParentNode()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // Create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // Create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // Set the scene to the view
        scnView.scene = scene
        
        // Allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // Show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // Configure the view
        scnView.backgroundColor = UIColor.black
        
        // Add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        // Remove the chip
        removeShip()
        
        // Get chip
        ship = getShip()
        
        // add ship
        addShip()
        
        // Add label
        addLabel()
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // Check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // Check that we clicked on at least one object
        if hitResults.count > 0 {
            // Retrieved the first clicked object
            let result = hitResults[0]
            
            // Get its material
            let material = result.node.geometry!.firstMaterial!
            
            // Highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.2
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                self.ship.removeFromParentNode()
                self.score += 1
                
                print(#line, #function, "The ship \(self.score) has been shot")
                
                self.duration *= 0.95
                self.ship = self.getShip()
                self.addShip()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    // MARK: - Computer Properties
    var scnView: SCNView {
        self.view as! SCNView
    }
    
    override var shouldAutorotate: Bool {
        true
    }
    
    override var prefersStatusBarHidden: Bool {
        true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}
