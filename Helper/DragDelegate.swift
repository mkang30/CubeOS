//
//  DragDelegate.swift
//  
//
//  Created by Min Seong Kang on 2/18/24.
//

import Foundation
import SceneKit
import SwiftUI


/// Controller for DragGesture
/// 1) Maps a gesture to a component on CubeScene
/// 2) Identifies edge cases and logically starts/ends motion
/// 3) Delegates the actions to components
///
class DragDelegate {
  private var botPrism: Cuboid
  private var topPrism: Cuboid
  private var topLeftCube: Cuboid
  private var topRightCube: Cuboid
  private var centerCube: Cuboid
  private var currCuboid: Cuboid? = nil
  private var isPremature = false
  init(botPrism: Cuboid, centerCube: Cuboid, topRightCube: Cuboid, topLeftCube: Cuboid, topPrism: Cuboid) {
    self.botPrism = botPrism
    self.topPrism = topPrism
    self.topLeftCube = topLeftCube
    self.topRightCube = topRightCube
    self.centerCube = centerCube
  }
  
  
  
  func onChanged(_ value: DragGesture.Value) {
    if (isPremature) {
      return
    }
    let (target, bound) = whichZone(value.location)
    let start = fromScreenToLocal(screenPos: value.startLocation, bound: bound)
    let pos = fromScreenToLocal(screenPos: value.location, bound: bound)
    
    if let curr = currCuboid {
      if let target = target {
        if (target as! SCNNode !== curr as! SCNNode) {
          curr.settle()
          currCuboid = nil
          isPremature = true
          return
        }
      } else {
        curr.settle()
        currCuboid = nil
        isPremature = true
        return
      }
    } else {
      //determines the currCuboid
      if let target = target {
        currCuboid = target
        target.startDrag(start: start, pos: pos)
      } else {
        isPremature = true
        return
      }
    }
    guard let currCuboid = currCuboid else {fatalError("onchanged")}
    currCuboid.rotate(pos: pos)
    
  }
  
  func onEnded(_ value: DragGesture.Value) {
    if (isPremature){
      isPremature = false
      return
    }
    guard let curr = currCuboid else {return}
    curr.settle()
    currCuboid = nil
    return
  }
  
  func fromScreenToLocal(screenPos: CGPoint, bound: Boundary) ->CGPoint {
    let y = bound.bot - screenPos.y
    let x = screenPos.x - bound.left
    return CGPoint(x:x, y:y)
  }
  
  func checkOnScreen(pos: CGPoint) -> Bool {
    if (!BOUND_VIEW.HORIZRange.contains(pos.x)) {
      return false
    }
    if (!BOUND_VIEW.VERTRange.contains(pos.y)) {
      return false
    }
    return true
  }
  
  
  func whichZone(_ pos: CGPoint) -> (Cuboid?, Boundary) {
    if (!checkOnScreen(pos: pos)) {
      return (nil, BOUND_VIEW)
    }
    switch (pos.x, pos.y) {
    case (BOUND_TOP.HORIZRange, BOUND_TOP.VERTRange):
      return (topPrism, BOUND_TOP)
    case (BOUND_TOP_LEFT.HORIZRange, BOUND_TOP_LEFT.VERTRange):
      return (topLeftCube, BOUND_TOP_LEFT)
    case (BOUND_TOP_RIGHT.HORIZRange, BOUND_TOP_RIGHT.VERTRange):
      return (topRightCube, BOUND_TOP_RIGHT)
    case (BOUND_CENTER.HORIZRange, BOUND_CENTER.VERTRange):
      return (centerCube, BOUND_CENTER)
    case (BOUND_BOT.HORIZRange, BOUND_BOT.VERTRange):
      return (botPrism, BOUND_BOT)
    default:
      return (nil, BOUND_VIEW)
    }
  }
}
