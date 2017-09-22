//
//  GameViewController.swift
//  SCNTechniqueTest
//
//  Created by Lachlan Hurst on 26/05/2016.
//  Copyright (c) 2016 Lachlan Hurst. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

struct node_uniforms {
    var emission_color:vector_float4
}

class GameViewController: UIViewController {

    var technique:SCNTechnique!

    override func viewDidLoad() {
        super.viewDidLoad()

        let program = SCNProgram()
        program.vertexFunctionName = "bloom_vertex"
        program.fragmentFunctionName = "bloom_fragment"


        // create a new scene
        let scene = SCNScene()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)

        let box = GeometryBuildTools.buildBox() //SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        box.firstMaterial?.diffuse.contents = UIColor.white

        //var uniforms = node_uniforms(emission_color: vector_float4(1.0,0.0,0.0,1.0))
        //let uniformsData = NSData(bytes: &uniforms, length: sizeof(node_uniforms))
        //box.firstMaterial?.setValue(uniformsData, forKey: "uniforms")
        //box.firstMaterial?.program = program


        let boxNode = SCNNode(geometry: box)
        //boxNode.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 2, z: 1, duration: 1)))
        scene.rootNode.addChildNode(boxNode)

        let sphere = GeometryBuildTools.buildSpiral() //SCNSphere(radius: 0.5)
        sphere.firstMaterial?.diffuse.contents = UIColor.red
        sphere.firstMaterial?.selfIllumination.contents = UIColor.red
        //sphere.firstMaterial?.setValue(uniformsData, forKey: "uniforms")
        //sphere.firstMaterial?.program = program

        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.opacity = 0.4
        scene.rootNode.addChildNode(sphereNode)


        /*let ambientLight = SCNLight()
        ambientLight.color = UIColor.whiteColor()
        ambientLight.type = SCNLightTypeAmbient
        let lightNode = SCNNode()
        lightNode.light = ambientLight
        scene.rootNode.addChildNode(lightNode)*/


        // retrieve the SCNView
        let scnView = self.view as! SCNView
        scnView.scene = scene
        scnView.isPlaying = true
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.showsStatistics = true
        scnView.backgroundColor = UIColor.lightGray
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)

        let techniqueName = "technique"
        //let techniqueName = "bloomRegions"
        if let path = Bundle.main.path(forResource: techniqueName, ofType: "plist") {
            if let dico1 = NSDictionary(contentsOfFile: path)  {
                let dico = dico1 as! [String : AnyObject]

                let technique = SCNTechnique(dictionary:dico)

                //let val = NSValue(CGSize: CGSizeMake(1, 1))
                //technique?.setObject(val, forKeyedSubscript: "radiusSymbol")

                //technique?.setValue(val, forKeyPath: "radiusSymbol")
                //technique?.setObject(NSNumber(float: 0.5), forKeyedSubscript: "radiusSymbol")
                /*technique?.handleBindingOfSymbol("radiusSymbol", usingBlock:
                    { programID, location, renderedNode, renderer in
                        print("loc \(location)")
                    }
                )*/

                scnView.technique = technique
                self.technique = technique


            }
        }
    }
    
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        if scnView.technique == nil {
            scnView.technique = technique
        } else {
            scnView.technique = nil
        }

    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
