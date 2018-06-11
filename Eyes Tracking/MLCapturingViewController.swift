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
import Firebase

class MLCapturingViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet weak var lookAtPositionView: UIView!
    
    @IBOutlet weak var lookAtScaleView: UIView!
    
    @IBOutlet weak var lookAtCenterView: UIView!
    
    let session = ARSession()
    
    var frame: ARFrame?
    
    var currentDataSet: [Float] = []
    
    var isARAnchorAvailable = false
    
    var previousARAnchorTransform = simd_float4x4()
    
    var lookAtPosition = CGPoint()
    
    var timer = Timer()
    
    var subTimer = Timer()
    
    var subTimerIntervalCount = 0 {
        didSet {
            if subTimerIntervalCount >= 10 {
                subTimerIntervalCount = 0
            }
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            timer.invalidate()
            subTimer.invalidate()
            
            // Pause the view's session
            session.pause()
            
            let alert = UIAlertController(title: "Menu", message: "What do you want to do?", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                self.resetSession()
            }))
//            alert.addAction(UIAlertAction(title: "Go to menu (no upload)", style: .default, handler: { action in
//                self.dataSets = []
//                self.navigationController?.popViewController(animated: true)
//            }))
            alert.addAction(UIAlertAction(title: "Upload & go to menu", style: .default, handler: { action in
                self.saveToCloud()
                self.navigationController?.popViewController(animated: true)
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session.delegate = self
        
        view.backgroundColor = .red
        
        lookAtScaleView.layer.cornerRadius = lookAtScaleView.bounds.width / 2
        lookAtCenterView.layer.cornerRadius = lookAtCenterView.bounds.width / 2
        
        setLookAtViewDefaultColor()
        
        lookAtScaleView.transform = CGAffineTransform(scaleX: 0, y: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Navigation Bar Setup
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        // Store isIdleTimerDisabled Value
        UIApplication.shared.isIdleTimerDisabled = true
        
        resetSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        session.pause()
    }
    
    private func resetSession() {
        // Create a session configuration
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        
        // Run the view's session
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // MARK: - session delegate
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.first as? ARFaceAnchor else { return }
        update(withFaceAnchor: faceAnchor)
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.first as? ARFaceAnchor else { return }
        update(withFaceAnchor: faceAnchor)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        self.frame = frame
        
        if let faceAnchor = frame.anchors.first as? ARFaceAnchor {
            
            // Compare if the ARAnchor transform still remains the same that means the face isn't detected, so red screen will be displayed, and the data-capturing stops. When ARAnchor transform starts changing again, the screen turns black, and the data-capturing starts to work.
            if faceAnchor.transform == previousARAnchorTransform {
                if isARAnchorAvailable {
                    UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.allowUserInteraction], animations: {
                        self.view.backgroundColor = .red
                        self.lookAtScaleView.transform = CGAffineTransform(scaleX: 0, y: 0)
                    }, completion: nil)
                    timer.invalidate()
                    subTimer.invalidate()
                    subTimerIntervalCount = 0
                }
                isARAnchorAvailable = false
            } else {
                
                if !isARAnchorAvailable {
                    UIView.animate(withDuration: 0.175, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.allowUserInteraction], animations: {
                        self.view.backgroundColor = .black
                    }, completion: nil)
                    changeIndicatorPosition()
                    runTimer()
                    runSubTimer()
                }
                isARAnchorAvailable = true
            }
            previousARAnchorTransform = faceAnchor.transform
        }
    }
    
    private func randomPosition() {
        let isExtrema = Int.random(in: 0...1) == 1 ? true : false
        let isHorizontalExtrema = Int.random(in: 0...1) == 1 ? true : false
        let extremaValue = CGFloat(Int.random(in: 0 ... 1))
        let x = CGFloat(Float.random(in: 0 ... 1))
        let y = CGFloat(Float.random(in: 0 ... 1))
        lookAtPosition = isExtrema ? CGPoint(x: isHorizontalExtrema ? extremaValue : x , y: isHorizontalExtrema ? y : extremaValue ) : CGPoint(x: x, y: y)
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 3, target: self,   selector: (#selector(changeIndicatorPosition)), userInfo: nil, repeats: true)
    }
    
    func runSubTimer() {
        subTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self,   selector: (#selector(intervalAction)), userInfo: nil, repeats: true)
    }
    
    // MARK: - changeIndicatorPosition()
    // To change the position of look-at-indicator
    
    @objc func changeIndicatorPosition() {
        
        subTimerIntervalCount = 0
        
        randomPosition()
        
        lookAtScaleView.alpha = 0.5
        lookAtScaleView.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
        
        let transformX = (lookAtPosition.x - 0.5) * UIScreen.main.bounds.width // Screen size width
        let transformY = (lookAtPosition.y - 0.5) * UIScreen.main.bounds.height // Screen size height
        
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            self.lookAtScaleView.alpha = 1
            self.lookAtScaleView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: nil)
        
        let isHorizontalCurve = Int.random(in: 0...1) == 1 ? true : false
        
        let springVelocity: CGPoint = isHorizontalCurve ? CGPoint(x: 1, y: 10) : CGPoint(x: 10, y: 1)
        
        UIView.animate(withDuration: 0.7,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: springVelocity.x,
                       options: [],
                       animations: {
                        self.lookAtPositionView.transform.tx = transformX
        }, completion: nil)
        
        UIView.animate(withDuration: 0.7,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: springVelocity.y,
                       options: [],
                       animations: {
                        self.lookAtPositionView.transform.ty = transformY
        }, completion: nil)
        
        
        
    }
    
    // MARK: - intervalAction()
    // To provide feedback when data is captured
    
    @objc func intervalAction() {
        
        // Perform bouncing animation every 1 sec to remind to be ready
        if Double(subTimerIntervalCount).remainder(dividingBy: 2) == 0 && subTimerIntervalCount != 0 && subTimerIntervalCount < 5 {
            
            lookAtScaleView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.lookAtScaleView.alpha = 0.5
            
            UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
                self.lookAtScaleView.alpha = 1
            }, completion: nil)
            
            UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1, options: [], animations: {
                self.lookAtScaleView.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
        }
        
        // Perform bouncing animation and flash animation every 0.5 sec to inform that data is being captured
        if subTimerIntervalCount >= 5 {
            lookAtScaleView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            setLookAtViewFlashColor()
            
            UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
                self.setLookAtViewDefaultColor()
            }, completion: nil)
            
            UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1, options: [], animations: {
                self.lookAtScaleView.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
            
            storeDataSet(dataSet: currentDataSet)
        }
        
        // Count interval up
        subTimerIntervalCount += 1
    }
    
    // MARK: -
    private func setLookAtViewDefaultColor() {
        lookAtScaleView.backgroundColor = UIColor.yellow.withAlphaComponent(0.2)
        lookAtCenterView.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
    }
    
    // MARK: -
    private func setLookAtViewFlashColor() {
        lookAtScaleView.backgroundColor = .white
        lookAtCenterView.backgroundColor = .white
    }
    
    // MARK: - update(ARFaceAnchor)
    
    private func update(withFaceAnchor anchor: ARFaceAnchor) {
        
        currentDataSet = []
        
        // Add position of the look at indicator to the data set
        currentDataSet.append(Float(lookAtPosition.x))
        currentDataSet.append(Float(lookAtPosition.y))
        
        // Add all blend shape values to the data set
        for blendShape in blendShapes {
            let value = clamp(anchor.blendShapes[blendShape] ?? 0)
            currentDataSet.append(Float(truncating: value))
        }
        
        // Add all positions and rotations of face and eyes to the data set
        for vectorProfileName in vectorProfileNames {
            switch vectorProfileName{
            case .facePosition:
                let value = getValuesFrom(anchor.transform).position
                currentDataSet.append(invertClamp(Float(value.x)))
                currentDataSet.append(invertClamp(Float(value.y)))
                currentDataSet.append(invertClamp(Float(value.z)))
            case .faceEulerAngles:
                let value = getValuesFrom(anchor.transform).eulerAngles
                currentDataSet.append(invertClamp(Float(value.x)))
                currentDataSet.append(invertClamp(Float(value.y)))
                currentDataSet.append(invertClamp(Float(value.z)))
            case .leftEyePosition:
                let value = getValuesFrom(anchor.leftEyeTransform).position
                currentDataSet.append(invertClamp(Float(value.x)))
                currentDataSet.append(invertClamp(Float(value.y)))
                currentDataSet.append(invertClamp(Float(value.z)))
            case .leftEyeEulerAngles:
                let value = getValuesFrom(anchor.leftEyeTransform).eulerAngles
                currentDataSet.append(invertClamp(Float(value.x)))
                currentDataSet.append(invertClamp(Float(value.y)))
                currentDataSet.append(invertClamp(Float(value.z)))
            case .rightEyePosition:
                let value = getValuesFrom(anchor.rightEyeTransform).position
                currentDataSet.append(invertClamp(Float(value.x)))
                currentDataSet.append(invertClamp(Float(value.y)))
                currentDataSet.append(invertClamp(Float(value.z)))
            case .rightEyeEulerAngles:
                let value = getValuesFrom(anchor.rightEyeTransform).eulerAngles
                currentDataSet.append(invertClamp(Float(value.x)))
                currentDataSet.append(invertClamp(Float(value.y)))
                currentDataSet.append(invertClamp(Float(value.z)))
                
            }
        }
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
    
    private func invertClamp(_ value: Float) -> Float {
        return max(min((value + 1) / 2, 1), 0)
    }
    
    var dataSets = [String]()
    // TODO: Store data set to somewhere
    private func storeDataSet(dataSet: [Float]) {
        /* DATA SET LABEL
         [lookAtPositionX,
         lookAtPositionY,
         eyeBlinkLeft,
         eyeLookDownLeft,
         eyeLookInLeft,
         eyeLookOutLeft,
         eyeLookUpLeft,
         eyeSquintLeft,
         eyeWideLeft,
         eyeBlinkRight,
         eyeLookDownRight,
         eyeLookInRight,
         eyeLookOutRight,
         eyeLookUpRight,
         eyeSquintRight,
         eyeWideRight,
         browDownLeft,
         browDownRight,
         browInnerUp,
         browOuterUpLeft,
         browOuterUpRight,
         cheekPuff,
         cheekSquintLeft,
         cheekSquintRight,
         noseSneerLeft,
         noseSneerRight,
         facePositionX,
         facePositionY,
         facePositionZ,
         faceEulerAnglesX,
         faceEulerAnglesY,
         faceEulerAnglesZ,
         leftEyePositionX,
         leftEyePositionY,
         leftEyePositionZ,
         leftEyeEulerAnglesX,
         leftEyeEulerAnglesY,
         leftEyeEulerAnglesZ,
         rightEyePositionX,
         rightEyePositionY,
         rightEyePositionZ,
         rightEyeEulerAnglesX,
         rightEyeEulerAnglesY,
         rightEyeEulerAnglesZ]
         */
        // [lookAtPositionX, lookAtPositionY, ]
        dataSets.append(dataSet.map { "\($0)" }.joined(separator: ","))
    }
    
    var filename: String {
        let date = Date().timeIntervalSince1970
        return "\(Int(date)).csv"
        
    }
    
    
    func saveToCloud() {
        let storage = Storage.storage()
        let ref = storage.reference(withPath: "data-set/\(filename)")
        let legend = "lookAtPositionX,lookAtPositionY,eyeBlinkLeft,eyeLookDownLeft,eyeLookInLeft,eyeLookOutLeft,eyeLookUpLeft,eyeSquintLeft,eyeWideLeft,eyeBlinkRight,eyeLookDownRight,eyeLookInRight,eyeLookOutRight,eyeLookUpRight,eyeSquintRight,eyeWideRight,browDownLeft,browDownRight,browInnerUp,browOuterUpLeft,browOuterUpRight,cheekPuff,cheekSquintLeft,cheekSquintRight,noseSneerLeft,noseSneerRight,facePositionX,facePositionY,facePositionZ,faceEulerAnglesX,faceEulerAnglesY,faceEulerAnglesZ,leftEyePositionX,leftEyePositionY,leftEyePositionZ,leftEyeEulerAnglesX,leftEyeEulerAnglesY,leftEyeEulerAnglesZ,rightEyePositionX,rightEyePositionY,rightEyePositionZ,rightEyeEulerAnglesX,rightEyeEulerAnglesY,rightEyeEulerAnglesZ"
        let ds = [legend, dataSets.joined(separator: "\n")].joined(separator: "\n")
        let data = ds.data(using: .utf8)!
        ref.putData(data, metadata: nil) { (_, error) in
            if let error = error {
                print(error)
            }
        }
    }
}
