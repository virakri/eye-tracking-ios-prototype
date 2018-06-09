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

class MLDataDisplayViewController: UIViewController, ARSessionDelegate {
    
    @IBOutlet weak var mainStackView: UIStackView!
    
    let session = ARSession()
    
    var frame: ARFrame?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session.delegate = self
        
        // Setup StackView to display bar chart
        for _ in blendShapes {
            addNewBarView()
        }
        
        for _ in vectorProfileNames {
            addNewBarView(withColor: .red)
            addNewBarView(withColor: .green)
            addNewBarView(withColor: .blue)
        }
    }
    
    private func addNewBarView(withColor color: UIColor = .gray) {
        let barView = UIView()
        barView.backgroundColor = color
        barView.heightAnchor.constraint(equalToConstant: 4).isActive = true
        mainStackView.addArrangedSubview(barView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        
        // Run the view's session
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        session.pause()
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
    }
    
    // MARK: - update(ARFaceAnchor)
    
    func update(withFaceAnchor anchor: ARFaceAnchor) {
        
        var index = 0
        
        for blendShape in blendShapes {
            let value = clamp(anchor.blendShapes[blendShape] ?? 0)
            mainStackView.arrangedSubviews[index].transform = CGAffineTransform(scaleX: CGFloat(truncating: value), y: 1)
            index += 1
        }
        
        for vectorProfileName in vectorProfileNames {
            switch vectorProfileName{
            case .facePosition:
                let value = getValuesFrom(anchor.transform).position
                mainStackView.arrangedSubviews[index].transform = CGAffineTransform(scaleX: CGFloat(value.x), y: 1)
                mainStackView.arrangedSubviews[index + 1].transform = CGAffineTransform(scaleX: CGFloat(value.y), y: 1)
                mainStackView.arrangedSubviews[index + 2].transform = CGAffineTransform(scaleX: CGFloat(value.z), y: 1)
            case .faceEulerAngles:
                let value = getValuesFrom(anchor.transform).eulerAngles
                mainStackView.arrangedSubviews[index].transform = CGAffineTransform(scaleX: CGFloat(value.x), y: 1)
                mainStackView.arrangedSubviews[index + 1].transform = CGAffineTransform(scaleX: CGFloat(value.y), y: 1)
                mainStackView.arrangedSubviews[index + 2].transform = CGAffineTransform(scaleX: CGFloat(value.z), y: 1)
            case .leftEyePosition:
                let value = getValuesFrom(anchor.leftEyeTransform).position
                mainStackView.arrangedSubviews[index].transform = CGAffineTransform(scaleX: CGFloat(value.x), y: 1)
                mainStackView.arrangedSubviews[index + 1].transform = CGAffineTransform(scaleX: CGFloat(value.y), y: 1)
                mainStackView.arrangedSubviews[index + 2].transform = CGAffineTransform(scaleX: CGFloat(value.z), y: 1)
            case .leftEyeEulerAngles:
                let value = getValuesFrom(anchor.leftEyeTransform).eulerAngles
                mainStackView.arrangedSubviews[index].transform = CGAffineTransform(scaleX: CGFloat(value.x), y: 1)
                mainStackView.arrangedSubviews[index + 1].transform = CGAffineTransform(scaleX: CGFloat(value.y), y: 1)
                mainStackView.arrangedSubviews[index + 2].transform = CGAffineTransform(scaleX: CGFloat(value.z), y: 1)
            case .rightEyePosition:
                let value = getValuesFrom(anchor.rightEyeTransform).position
                mainStackView.arrangedSubviews[index].transform = CGAffineTransform(scaleX: CGFloat(value.x), y: 1)
                mainStackView.arrangedSubviews[index + 1].transform = CGAffineTransform(scaleX: CGFloat(value.y), y: 1)
                mainStackView.arrangedSubviews[index + 2].transform = CGAffineTransform(scaleX: CGFloat(value.z), y: 1)
            case .rightEyeEulerAngles:
                let value = getValuesFrom(anchor.rightEyeTransform).eulerAngles
                mainStackView.arrangedSubviews[index].transform = CGAffineTransform(scaleX: CGFloat(value.x), y: 1)
                mainStackView.arrangedSubviews[index + 1].transform = CGAffineTransform(scaleX: CGFloat(value.y), y: 1)
                mainStackView.arrangedSubviews[index + 2].transform = CGAffineTransform(scaleX: CGFloat(value.z), y: 1)
            }
            
            index += 3
            
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
}
