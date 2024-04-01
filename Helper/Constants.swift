//
//  Constants.swift
//  
//
//  Created by Min Seong Kang on 1/14/24.
//

import Foundation
import SceneKit

/**
 This file contains some constant values and data structures
 */
let RIGHT_ANGLE = Double.pi/2
let FIT_SCALE = 0.7
let REFIT_SCALE = 1/FIT_SCALE

let BOUND_VIEW = Boundary(0, HEIGHT, 0, WIDTH)
let BOUND_TOP = Boundary(33, 130, 18, 362)
let BOUND_TOP_LEFT = Boundary(130.1, 306, 18, 188.5)
let BOUND_TOP_RIGHT = Boundary(130.1, 306, 188.6, 362)
let BOUND_CENTER = Boundary(306.1, 656.5, 18, 362)
let BOUND_BOT = Boundary(656.5,750, 18, 362)


enum Zone {
  case top
  case topLeft
  case topRight
  case center
  case bot
}

enum CubeFace: Int {
  case FRONT
  case RIGHT
  case BACK
  case LEFT
  case TOP
  case BOT
}

enum Direction {
  case HORIZ
  case VERT
  case UNSET
}

struct Boundary {
  var top: Double
  var bot: Double
  var left: Double
  var right: Double
  var HORIZRange: ClosedRange<Double>
  var VERTRange: ClosedRange<Double>
  
  init(_ top: Double, _ bot: Double, _ left: Double, _ right: Double) {
    self.top = top
    self.bot = bot
    self.left = left
    self.right = right
    self.HORIZRange = left...right
    self.VERTRange = top...bot
  }
}

struct MoveMetaData {
  var axis: SCNNode? = nil
  var isActive: Bool = false
  // if HORIZ - along x-axis, if vart - along y-axis
  var currPos: CGPoint? = nil
  var cumRotation = 0.0
  var dir = Direction.UNSET
}


