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

let vectorProfileNames: [VectorProfileName] = [.facePosition, .faceEulerAngles, .leftEyePosition, .leftEyeEulerAngles]
