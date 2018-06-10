//
//  ViewController.swift
//  Eyes Tracking
//
//  Created by Virakri Jinangkul on 6/6/18.
//  Copyright © 2018 virakri. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import WebKit

class MLEyesTrackingViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var eyePositionIndicatorView: UIView!
    @IBOutlet weak var eyePositionIndicatorCenterView: UIView!
    @IBOutlet weak var blurBarView: UIVisualEffectView!
    @IBOutlet weak var lookAtPositionXLabel: UILabel!
    @IBOutlet weak var lookAtPositionYLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    let modelForRegressorX = regressorMinX()
    
    let modelForRegressorY = regressorMinY()
    
    var faceNode: SCNNode = SCNNode()
    
    var eyeLNode: SCNNode = {
        let geometry = SCNCone(topRadius: 0.005, bottomRadius: 0, height: 0.2)
        geometry.radialSegmentCount = 3
        geometry.firstMaterial?.diffuse.contents = UIColor.blue
        let node = SCNNode()
        node.geometry = geometry
        node.eulerAngles.x = -.pi / 2
        node.position.z = 0.1
        let parentNode = SCNNode()
        parentNode.addChildNode(node)
        return parentNode
    }()
    
    var eyeRNode: SCNNode = {
        let geometry = SCNCone(topRadius: 0.005, bottomRadius: 0, height: 0.2)
        geometry.radialSegmentCount = 3
        geometry.firstMaterial?.diffuse.contents = UIColor.blue
        let node = SCNNode()
        node.geometry = geometry
        node.eulerAngles.x = -.pi / 2
        node.position.z = 0.1
        let parentNode = SCNNode()
        parentNode.addChildNode(node)
        return parentNode
    }()
    
    var lookAtTargetEyeLNode: SCNNode = SCNNode()
    var lookAtTargetEyeRNode: SCNNode = SCNNode()
    var virtualPhoneNode: SCNNode = SCNNode()
    var virtualScreenNode: SCNNode = {
        
        let screenGeometry = SCNPlane(width: 1, height: 1)
        screenGeometry.firstMaterial?.isDoubleSided = true
        screenGeometry.firstMaterial?.diffuse.contents = UIColor.green
        
        return SCNNode(geometry: screenGeometry)
    }()
    
    // actual physical size of iPhoneX screen
    let phoneScreenSize = CGSize(width: 0.0623908297, height: 0.135096943231532)
    
    // actual point size of iPhoneX screen
    let phoneScreenPointSize = CGSize(width: 375, height: 812)
    
    var eyeLookAtPositionXs: [CGFloat] = []
    var eyeLookAtPositionYs: [CGFloat] = []
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let alert = UIAlertController(title: "Go to Main Menu", message: "Are you sure to go back to Main Menu.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Main Menu", style: .default, handler: { action in
                if let navigationController = self.navigationController {
                    navigationController.popViewController(animated: true)
                }
            }))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.load(URLRequest(url: URL(string: "https://www.apple.com")!))
        
        // Setup Design Elements
        eyePositionIndicatorView.layer.cornerRadius = eyePositionIndicatorView.bounds.width / 2
        sceneView.layer.cornerRadius = 28
        eyePositionIndicatorCenterView.layer.cornerRadius = 4
        
        blurBarView.layer.cornerRadius = 36
        blurBarView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        webView.layer.cornerRadius = 16
        webView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        
        // Setup Scenegraph
        sceneView.scene.rootNode.addChildNode(faceNode)
        sceneView.scene.rootNode.addChildNode(virtualPhoneNode)
        virtualPhoneNode.addChildNode(virtualScreenNode)
        faceNode.addChildNode(eyeLNode)
        faceNode.addChildNode(eyeRNode)
        eyeLNode.addChildNode(lookAtTargetEyeLNode)
        eyeRNode.addChildNode(lookAtTargetEyeRNode)
        
        // Set LookAtTargetEye at 2 meters away from the center of eyeballs to create segment vector
        lookAtTargetEyeLNode.position.z = 2
        lookAtTargetEyeRNode.position.z = 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Navigation Bar Setup
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        // Store isIdleTimerDisabled Value
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Create a session configuration
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        
        // Run the view's session
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        faceNode.transform = node.transform
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        update(withFaceAnchor: faceAnchor)
    }
    
    // MARK: - update(ARFaceAnchor)
    
    func update(withFaceAnchor anchor: ARFaceAnchor) {
        
        eyeRNode.simdTransform = anchor.rightEyeTransform
        eyeLNode.simdTransform = anchor.leftEyeTransform
        
        DispatchQueue.main.async {
            
            let dataSet = self.getDataSet(byFaceAnchor: anchor)
            
            
            guard let regressorX = try? self.modelForRegressorX.prediction(input: self.getRegressorXInput(by: dataSet)) else {
                fatalError("Unexpected error.")
            }
            
            guard let regressorY = try? self.modelForRegressorY.prediction(input: self.getRegressorYInput(by: dataSet)) else {
                fatalError("Unexpected error.")
            }
            
            var estimatedLookAt = CGPoint()
            estimatedLookAt.x = CGFloat(regressorX.lookAtPositionX) * self.phoneScreenPointSize.width
            estimatedLookAt.y = CGFloat(regressorY.lookAtPositionY) * self.phoneScreenPointSize.height
            
            // Add the latest position and keep up to 8 recent position to smooth with.
            let smoothThresholdNumber: Int = 4
            self.eyeLookAtPositionXs.append(estimatedLookAt.x)
            self.eyeLookAtPositionYs.append(estimatedLookAt.y)
            self.eyeLookAtPositionXs = Array(self.eyeLookAtPositionXs.suffix(smoothThresholdNumber))
            self.eyeLookAtPositionYs = Array(self.eyeLookAtPositionYs.suffix(smoothThresholdNumber))
            
            let smoothEyeLookAtPositionX = self.eyeLookAtPositionXs.average!
            let smoothEyeLookAtPositionY = self.eyeLookAtPositionYs.average!
            
            // update indicator position
            self.eyePositionIndicatorView.transform = CGAffineTransform(translationX: smoothEyeLookAtPositionX - self.phoneScreenPointSize.width / 2,
                                                                        y: smoothEyeLookAtPositionY - self.phoneScreenPointSize.height / 2)
            
            // update eye look at labels values
            self.lookAtPositionXLabel.text = "\(Int(round(smoothEyeLookAtPositionX)))"
            
            self.lookAtPositionYLabel.text = "\(Int(round(smoothEyeLookAtPositionY)))"
            
            // Calculate distance of the eyes to the camera
            let distanceL = self.eyeLNode.worldPosition - SCNVector3Zero
            let distanceR = self.eyeRNode.worldPosition - SCNVector3Zero
            
            // Average distance from two eyes
            let distance = (distanceL.length() + distanceR.length()) / 2
            
            // Update distance label value
            self.distanceLabel.text = "\(Int(round(distance * 100))) cm"
            
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        virtualPhoneNode.transform = (sceneView.pointOfView?.transform)!
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        faceNode.transform = node.transform
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        update(withFaceAnchor: faceAnchor)
    }
    
    private func getDataSet(byFaceAnchor anchor: ARFaceAnchor) -> EyeTrackingDataSet {
        
        var currentDataSet: EyeTrackingDataSet = EyeTrackingDataSet()
        
        // Add all blend shape values to the data set
        for blendShape in blendShapes {
            let value = clamp(anchor.blendShapes[blendShape] ?? 0)
            currentDataSet.assign(by: blendShape, with: Double(truncating: value))
        }
        
        // Add all positions and rotations of face and eyes to the data set
        for vectorProfileName in vectorProfileNames {
            switch vectorProfileName{
            case .facePosition:
                let value = getValuesFrom(anchor.transform).position
                currentDataSet.facePositionX = invertClamp(Double(value.x))
                currentDataSet.facePositionY = invertClamp(Double(value.y))
                currentDataSet.facePositionZ = invertClamp(Double(value.z))
            case .faceEulerAngles:
                let value = getValuesFrom(anchor.transform).eulerAngles
                currentDataSet.faceEulerAnglesX = invertClamp(Double(value.x))
                currentDataSet.faceEulerAnglesY = invertClamp(Double(value.y))
                currentDataSet.faceEulerAnglesZ = invertClamp(Double(value.z))
            case .leftEyePosition:
                let value = getValuesFrom(anchor.leftEyeTransform).position
                currentDataSet.leftEyePositionX = invertClamp(Double(value.x))
                currentDataSet.leftEyePositionY = invertClamp(Double(value.y))
                currentDataSet.leftEyePositionZ = invertClamp(Double(value.z))
            case .leftEyeEulerAngles:
                let value = getValuesFrom(anchor.leftEyeTransform).eulerAngles
                currentDataSet.leftEyeEulerAnglesX = invertClamp(Double(value.x))
                currentDataSet.leftEyeEulerAnglesY = invertClamp(Double(value.y))
                currentDataSet.leftEyeEulerAnglesZ = invertClamp(Double(value.z))
            case .rightEyePosition:
                let value = getValuesFrom(anchor.rightEyeTransform).position
                currentDataSet.rightEyePositionX = invertClamp(Double(value.x))
                currentDataSet.rightEyePositionY = invertClamp(Double(value.y))
                currentDataSet.rightEyePositionZ = invertClamp(Double(value.z))
            case .rightEyeEulerAngles:
                let value = getValuesFrom(anchor.rightEyeTransform).eulerAngles
                currentDataSet.rightEyeEulerAnglesX = invertClamp(Double(value.x))
                currentDataSet.rightEyeEulerAnglesY = invertClamp(Double(value.y))
                currentDataSet.rightEyeEulerAnglesZ = invertClamp(Double(value.z))
                
            }
        }
        return currentDataSet
    }
    
    private func getRegressorXInput(by dataSet: EyeTrackingDataSet) -> regressorMinXInput {
        return regressorMinXInput(
//            eyeBlinkLeft: dataSet.eyeBlinkLeft,
//                               eyeLookDownLeft: dataSet.eyeLookDownLeft,
//                               eyeLookInLeft: dataSet.eyeLookInLeft,
//                               eyeLookOutLeft: dataSet.eyeLookOutLeft,
//                               eyeLookUpLeft: dataSet.eyeLookUpLeft,
//                               eyeSquintLeft: dataSet.eyeSquintLeft,
//                               eyeWideLeft: dataSet.eyeWideLeft,
//                               eyeBlinkRight: dataSet.eyeBlinkRight,
//                               eyeLookDownRight: dataSet.eyeLookDownRight,
//                               eyeLookInRight: dataSet.eyeLookInRight,
//                               eyeLookOutRight: dataSet.eyeLookOutRight,
//                               eyeLookUpRight: dataSet.eyeLookUpRight,
//                               eyeSquintRight: dataSet.eyeSquintRight,
//                               eyeWideRight: dataSet.eyeWideRight,
//                               browDownLeft: dataSet.browDownLeft,
//                               browDownRight: dataSet.browDownRight,
//                               browInnerUp: dataSet.browInnerUp,
//                               browOuterUpLeft: dataSet.browOuterUpLeft,
//                               browOuterUpRight: dataSet.browOuterUpRight,
//                               cheekPuff: dataSet.cheekPuff,
//                               cheekSquintLeft: dataSet.cheekSquintLeft,
//                               cheekSquintRight: dataSet.cheekSquintRight,
//                               noseSneerLeft: dataSet.noseSneerLeft,
//                               noseSneerRight: dataSet.noseSneerRight,
                               facePositionX: dataSet.facePositionX,
                               facePositionY: dataSet.facePositionY,
                               facePositionZ: dataSet.facePositionZ,
                               faceEulerAnglesX: dataSet.faceEulerAnglesX,
                               faceEulerAnglesY: dataSet.faceEulerAnglesY,
                               faceEulerAnglesZ: dataSet.faceEulerAnglesZ,
                               leftEyePositionX: dataSet.leftEyePositionX,
                               leftEyePositionY: dataSet.leftEyePositionY,
                               leftEyePositionZ: dataSet.leftEyePositionZ,
                               leftEyeEulerAnglesX: dataSet.leftEyeEulerAnglesX,
                               leftEyeEulerAnglesY: dataSet.leftEyeEulerAnglesY,
                               leftEyeEulerAnglesZ: dataSet.leftEyeEulerAnglesZ,
                               rightEyePositionX: dataSet.rightEyePositionX,
                               rightEyePositionY: dataSet.rightEyePositionY,
                               rightEyePositionY_1: dataSet.rightEyePositionZ,
                               rightEyeEulerAnglesX: dataSet.rightEyeEulerAnglesX,
                               rightEyeEulerAnglesY: dataSet.rightEyeEulerAnglesY,
                               rightEyeEulerAnglesZ: dataSet.rightEyeEulerAnglesZ)
    }
    
    private func getRegressorYInput(by dataSet: EyeTrackingDataSet) -> regressorMinYInput {
        return regressorMinYInput(
//            eyeBlinkLeft: dataSet.eyeBlinkLeft,
//                               eyeLookDownLeft: dataSet.eyeLookDownLeft,
//                               eyeLookInLeft: dataSet.eyeLookInLeft,
//                               eyeLookOutLeft: dataSet.eyeLookOutLeft,
//                               eyeLookUpLeft: dataSet.eyeLookUpLeft,
//                               eyeSquintLeft: dataSet.eyeSquintLeft,
//                               eyeWideLeft: dataSet.eyeWideLeft,
//                               eyeBlinkRight: dataSet.eyeBlinkRight,
//                               eyeLookDownRight: dataSet.eyeLookDownRight,
//                               eyeLookInRight: dataSet.eyeLookInRight,
//                               eyeLookOutRight: dataSet.eyeLookOutRight,
//                               eyeLookUpRight: dataSet.eyeLookUpRight,
//                               eyeSquintRight: dataSet.eyeSquintRight,
//                               eyeWideRight: dataSet.eyeWideRight,
//                               browDownLeft: dataSet.browDownLeft,
//                               browDownRight: dataSet.browDownRight,
//                               browInnerUp: dataSet.browInnerUp,
//                               browOuterUpLeft: dataSet.browOuterUpLeft,
//                               browOuterUpRight: dataSet.browOuterUpRight,
//                               cheekPuff: dataSet.cheekPuff,
//                               cheekSquintLeft: dataSet.cheekSquintLeft,
//                               cheekSquintRight: dataSet.cheekSquintRight,
//                               noseSneerLeft: dataSet.noseSneerLeft,
//                               noseSneerRight: dataSet.noseSneerRight,
                               facePositionX: dataSet.facePositionX,
                               facePositionY: dataSet.facePositionY,
                               facePositionZ: dataSet.facePositionZ,
                               faceEulerAnglesX: dataSet.faceEulerAnglesX,
                               faceEulerAnglesY: dataSet.faceEulerAnglesY,
                               faceEulerAnglesZ: dataSet.faceEulerAnglesZ,
                               leftEyePositionX: dataSet.leftEyePositionX,
                               leftEyePositionY: dataSet.leftEyePositionY,
                               leftEyePositionZ: dataSet.leftEyePositionZ,
                               leftEyeEulerAnglesX: dataSet.leftEyeEulerAnglesX,
                               leftEyeEulerAnglesY: dataSet.leftEyeEulerAnglesY,
                               leftEyeEulerAnglesZ: dataSet.leftEyeEulerAnglesZ,
                               rightEyePositionX: dataSet.rightEyePositionX,
                               rightEyePositionY: dataSet.rightEyePositionY,
                               rightEyePositionY_1: dataSet.rightEyePositionZ,
                               rightEyeEulerAnglesX: dataSet.rightEyeEulerAnglesX,
                               rightEyeEulerAnglesY: dataSet.rightEyeEulerAnglesY,
                               rightEyeEulerAnglesZ: dataSet.rightEyeEulerAnglesZ)
    }
    
    private func getValuesFrom(_ simdTransform: simd_float4x4) -> (eulerAngles: SCNVector3, position: SCNVector3) {
        let node = SCNNode()
        node.simdTransform = simdTransform
        return (eulerAngles: node.eulerAngles, position: node.position)
    }
    
    private func clamp(_ value: NSNumber) -> NSNumber {
        let floatValue = Float(truncating: value)
        return NSNumber(value: max(min(floatValue, 1), 0))
    }
    
    private func invertClamp(_ value: Double) -> Double {
        return max(min((value + 1) / 2, 1), 0)
    }
}
