//
//  VectorProfileName.swift
//  Eyes Tracking
//
//  Created by Virakri Jinangkul on 6/8/18.
//  Copyright © 2018 virakri. All rights reserved.
//

import ARKit

enum VectorProfileName {
    case facePosition
    case faceEulerAngles
    case leftEyePosition
    case leftEyeEulerAngles
    case rightEyePosition
    case rightEyeEulerAngles
}

let blendShapes = [ARFaceAnchor.BlendShapeLocation.eyeBlinkLeft,
                   ARFaceAnchor.BlendShapeLocation.eyeLookDownLeft,
                   ARFaceAnchor.BlendShapeLocation.eyeLookInLeft,
                   ARFaceAnchor.BlendShapeLocation.eyeLookOutLeft,
                   ARFaceAnchor.BlendShapeLocation.eyeLookUpLeft,
                   ARFaceAnchor.BlendShapeLocation.eyeSquintLeft,
                   ARFaceAnchor.BlendShapeLocation.eyeWideLeft,
                   ARFaceAnchor.BlendShapeLocation.eyeBlinkRight,
                   ARFaceAnchor.BlendShapeLocation.eyeLookDownRight,
                   ARFaceAnchor.BlendShapeLocation.eyeLookInRight,
                   ARFaceAnchor.BlendShapeLocation.eyeLookOutRight,
                   ARFaceAnchor.BlendShapeLocation.eyeLookUpRight,
                   ARFaceAnchor.BlendShapeLocation.eyeSquintRight,
                   ARFaceAnchor.BlendShapeLocation.eyeWideRight,
                   ARFaceAnchor.BlendShapeLocation.browDownLeft,
                   ARFaceAnchor.BlendShapeLocation.browDownRight,
                   ARFaceAnchor.BlendShapeLocation.browInnerUp,
                   ARFaceAnchor.BlendShapeLocation.browOuterUpLeft,
                   ARFaceAnchor.BlendShapeLocation.browOuterUpRight,
                   ARFaceAnchor.BlendShapeLocation.cheekPuff,
                   ARFaceAnchor.BlendShapeLocation.cheekSquintLeft,
                   ARFaceAnchor.BlendShapeLocation.cheekSquintRight,
                   ARFaceAnchor.BlendShapeLocation.noseSneerLeft,
                   ARFaceAnchor.BlendShapeLocation.noseSneerRight]

let vectorProfileNames: [VectorProfileName] = [.facePosition, .faceEulerAngles, .leftEyePosition, .leftEyeEulerAngles,  .rightEyePosition, .rightEyeEulerAngles]

struct EyeTrackingDataSet {
    var eyeBlinkLeft: Double
    var eyeLookDownLeft: Double
    var eyeLookInLeft: Double
    var eyeLookOutLeft: Double
    var eyeLookUpLeft: Double
    var eyeSquintLeft: Double
    var eyeWideLeft: Double
    var eyeBlinkRight: Double
    var eyeLookDownRight: Double
    var eyeLookInRight: Double
    var eyeLookOutRight: Double
    var eyeLookUpRight: Double
    var eyeSquintRight: Double
    var eyeWideRight: Double
    var browDownLeft: Double
    var browDownRight: Double
    var browInnerUp: Double
    var browOuterUpLeft: Double
    var browOuterUpRight: Double
    var cheekPuff: Double
    var cheekSquintLeft: Double
    var cheekSquintRight: Double
    var noseSneerLeft: Double
    var noseSneerRight: Double
    var facePositionX: Double
    var facePositionY: Double
    var facePositionZ: Double
    var faceEulerAnglesX: Double
    var faceEulerAnglesY: Double
    var faceEulerAnglesZ: Double
    var leftEyePositionX: Double
    var leftEyePositionY: Double
    var leftEyePositionZ: Double
    var leftEyeEulerAnglesX: Double
    var leftEyeEulerAnglesY: Double
    var leftEyeEulerAnglesZ: Double
    var rightEyePositionX: Double
    var rightEyePositionY: Double
    var rightEyePositionZ: Double
    var rightEyeEulerAnglesX: Double
    var rightEyeEulerAnglesY: Double
    var rightEyeEulerAnglesZ: Double
    
    init() {
        eyeBlinkLeft = 0
        eyeLookDownLeft = 0
        eyeLookInLeft = 0
        eyeLookOutLeft = 0
        eyeLookUpLeft = 0
        eyeSquintLeft = 0
        eyeWideLeft = 0
        eyeBlinkRight = 0
        eyeLookDownRight = 0
        eyeLookInRight = 0
        eyeLookOutRight = 0
        eyeLookUpRight = 0
        eyeSquintRight = 0
        eyeWideRight = 0
        browDownLeft = 0
        browDownRight = 0
        browInnerUp = 0
        browOuterUpLeft = 0
        browOuterUpRight = 0
        cheekPuff = 0
        cheekSquintLeft = 0
        cheekSquintRight = 0
        noseSneerLeft = 0
        noseSneerRight = 0
        facePositionX = 0
        facePositionY = 0
        facePositionZ = 0
        faceEulerAnglesX = 0
        faceEulerAnglesY = 0
        faceEulerAnglesZ = 0
        leftEyePositionX = 0
        leftEyePositionY = 0
        leftEyePositionZ = 0
        leftEyeEulerAnglesX = 0
        leftEyeEulerAnglesY = 0
        leftEyeEulerAnglesZ = 0
        rightEyePositionX = 0
        rightEyePositionY = 0
        rightEyePositionZ = 0
        rightEyeEulerAnglesX = 0
        rightEyeEulerAnglesY = 0
        rightEyeEulerAnglesZ = 0
    }
    
    mutating func assign(by blendShape: ARFaceAnchor.BlendShapeLocation, with value: Double) {
        switch blendShape {
        case ARFaceAnchor.BlendShapeLocation.eyeBlinkLeft:
            eyeBlinkLeft = value
        case ARFaceAnchor.BlendShapeLocation.eyeLookDownLeft:
            eyeLookDownLeft = value
        case ARFaceAnchor.BlendShapeLocation.eyeLookInLeft:
            eyeLookInLeft = value
        case ARFaceAnchor.BlendShapeLocation.eyeLookOutLeft:
            eyeLookOutLeft = value
        case ARFaceAnchor.BlendShapeLocation.eyeLookUpLeft:
            eyeLookUpLeft = value
        case ARFaceAnchor.BlendShapeLocation.eyeSquintLeft:
            eyeSquintLeft = value
        case ARFaceAnchor.BlendShapeLocation.eyeWideLeft:
            eyeWideLeft = value
        case ARFaceAnchor.BlendShapeLocation.eyeBlinkRight:
            eyeBlinkRight = value
        case ARFaceAnchor.BlendShapeLocation.eyeLookDownRight:
            eyeLookDownRight = value
        case ARFaceAnchor.BlendShapeLocation.eyeLookInRight:
            eyeLookInRight = value
        case ARFaceAnchor.BlendShapeLocation.eyeLookOutRight:
            eyeLookOutRight = value
        case ARFaceAnchor.BlendShapeLocation.eyeLookUpRight:
            eyeLookUpRight = value
        case ARFaceAnchor.BlendShapeLocation.eyeSquintRight:
            eyeSquintRight = value
        case ARFaceAnchor.BlendShapeLocation.eyeWideRight:
            eyeWideRight = value
        case ARFaceAnchor.BlendShapeLocation.browDownLeft:
            browDownLeft = value
        case ARFaceAnchor.BlendShapeLocation.browDownRight:
            browDownRight = value
        case ARFaceAnchor.BlendShapeLocation.browInnerUp:
            browInnerUp = value
        case ARFaceAnchor.BlendShapeLocation.browOuterUpLeft:
            browOuterUpLeft = value
        case ARFaceAnchor.BlendShapeLocation.browOuterUpRight:
            browOuterUpRight = value
        case ARFaceAnchor.BlendShapeLocation.cheekPuff:
            cheekPuff = value
        case ARFaceAnchor.BlendShapeLocation.cheekSquintLeft:
            cheekSquintLeft = value
        case ARFaceAnchor.BlendShapeLocation.cheekSquintRight:
            cheekSquintRight = value
        case ARFaceAnchor.BlendShapeLocation.noseSneerLeft:
            noseSneerLeft = value
        case ARFaceAnchor.BlendShapeLocation.noseSneerRight:
            noseSneerRight = value
        default:
            break
        }
    }
}
