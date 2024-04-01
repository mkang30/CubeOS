//
//  RectPrism.swift
//  
//
//  Created by Min Seong Kang on 2/17/24.
//

import Foundation
import SceneKit

/// Represents rectangular prisms in the CubeScene. Essentially Cube with horizontal
/// rotation only
class RectPrism: SCNNode, Cuboid {
  var metaData: MoveMetaData
  let frameDim: CGPoint
  let cubeDim: Int
  let boxes: [SCNNode]
  let moveLock = NSLock()
  let isBox: Bool
  
  
  init(frameDim: CGPoint, cubeDim: Int ,isBox: Bool = false) {
    self.frameDim = frameDim
    self.metaData = MoveMetaData()
    self.metaData.dir = .HORIZ
    self.cubeDim = cubeDim
    self.isBox = isBox
    self.boxes = RectPrism.initBoxes(isBox: isBox, cubeDim: cubeDim)
    super.init()
    addNodes()
  }
  
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  
  /// Starts rotation
  /// - Parameters:
  ///   - start: start pos in local space
  ///   - pos: current pos in local space
  func startDrag(start: CGPoint, pos: CGPoint) {
    moveLock.lock()
    defer {
      moveLock.unlock()
    }
    assert(!metaData.isActive)
    metaData.currPos = start
    metaData.isActive = true
  }
  
  
  /// Rotate left or right
  /// - Parameters:
  ///   - pos: current pos in local space
  func rotate(pos: CGPoint) {
    moveLock.lock()
    defer {
      moveLock.unlock()
    }
    if (!metaData.isActive) {fatalError("rotate called when not active")}
    guard let currPos = metaData.currPos else {fatalError("currPos not set in rotate")}
    var action: SCNAction? = nil
    if metaData.dir == .HORIZ {
      let magn = (pos.x - currPos.x)/frameDim.x
      let rotation = Double.pi/2*magn
      metaData.cumRotation += rotation
      action = SCNAction.rotate(by:rotation, around: SCNVector3(0,1,0), duration: TimeInterval(0))
    } else {
      fatalError("direction is unset")
    }
    self.runAction(action!)
    metaData.currPos = pos
  }
  
  
  /// Finalizes rotation. Much simpler than Cube.settle(), since this does't involve Axis logistics
  func settle() {
    moveLock.lock()
    let remRotation = metaData.cumRotation.truncatingRemainder(dividingBy: RIGHT_ANGLE)
    let finalRotation: Double
    if (remRotation >= 0) {
      if (remRotation >= RIGHT_ANGLE/2) {
        finalRotation = RIGHT_ANGLE - remRotation
      } else {
        finalRotation = Double(-remRotation)
      }
    } else {
      if (abs(remRotation) >= RIGHT_ANGLE/2) {
        finalRotation = abs(remRotation) - RIGHT_ANGLE
      } else {
        finalRotation = abs(remRotation)
      }
    }
    var action1: SCNAction? = nil
    if metaData.dir == .HORIZ {
      action1 = SCNAction.rotate(by:finalRotation, around: SCNVector3(0,1,0), duration: TimeInterval(0.3))
    } else {
      fatalError("direction is unset")
    }
    self.runAction(action1!) {
      self.clearMoveMeta()
    }
  }
  
  
  /// Helper
  /// - Parameter images: texture images
  func applyImages(images: [UIImage]) {
    let box = self.boxes[0]
    for i in 0..<4 {
      let material = SCNMaterial()
      material.diffuse.contents = images[i]
      box.geometry?.materials[i] = material
    }
  }
  
  /// Helper
  /// - Parameter images: texture images
  func applyTopImagesBoxes(images: [UIImage]) {
    if (!self.isBox) {
      fatalError("the prism doesnt have boxes")
    }
    var i = 0
    for box in self.boxes {
      let material = SCNMaterial()
      material.diffuse.contents = images[i]
      i += 1
      box.geometry?.materials[CubeFace.TOP.rawValue] = material
    }
  }
  
  /// Helper
  /// - Parameter images: texture images
  func applyImagesBoxes(images: [UIImage]) {
    if (!self.isBox) {
      fatalError("the prism doesnt have boxes")
    }
    let loc = Float(self.cubeDim)/2-0.5
    var i = 0
    for box in self.boxes {
      if (box.position.z == loc) {
        let material = SCNMaterial()
        material.diffuse.contents = images[i]
        i += 1
        box.geometry?.materials[0] = material
      }
    }
    for box in self.boxes {
      if (box.position.x == -loc) {
        let material = SCNMaterial()
        material.diffuse.contents = images[i]
        i += 1
        box.geometry?.materials[3] = material
      }
    }
    for box in self.boxes {
      if (box.position.x == loc) {
        let material = SCNMaterial()
        material.diffuse.contents = images[i]
        i += 1
        box.geometry?.materials[1] = material
      }
    }
    for box in self.boxes {
      if (box.position.z == -loc) {
        let material = SCNMaterial()
        material.diffuse.contents = images[i]
        i += 1
        box.geometry?.materials[2] = material
      }
    }
    
  }
  
  /// SE
  private func clearMoveMeta() {
    metaData.isActive = false
    metaData.currPos  = nil
    metaData.cumRotation = 0.0
    moveLock.unlock()
  }
  
  /// SE
  private func addNodes() {
    for node in self.boxes{
      self.addChildNode(node)
    }
  }
  
  /// SE
  /// - Parameters:
  ///   - isBox: whether to tessellate into boxes or use a single rectangular box
  ///   - cubeDim: size in boxes
  /// - Returns: array of nodes comprising RectPrism
  static private func initBoxes(isBox: Bool, cubeDim: Int) -> [SCNNode] {
    var newBoxes = [SCNNode]()
    if (isBox) {
      let start = -(Double(cubeDim)/2-0.5)
      for i in 0..<cubeDim {
        for j in 0..<cubeDim {
          let material = SCNMaterial()
          material.diffuse.contents = UIColor.white
          
          
          material.transparency = 1
          let geometry = SCNBox(width:1, height: 1, length: 1, chamferRadius: 0)
          geometry.materials = Array(repeating: material, count: 6)
          let node = SCNNode()
          node.geometry = geometry
          node.position = SCNVector3(start+Double(i), 0 ,start+Double(j))
          newBoxes.append(node)
        }
      }
    } else {
      let material = SCNMaterial()
      material.diffuse.contents = UIColor.white
      material.transparency = 1
      let geometry = SCNBox(width:4, height: 1, length: 4, chamferRadius: 0)
      geometry.materials = Array(repeating: material, count: 6)
      let node = SCNNode()
      node.geometry = geometry
      newBoxes.append(node)
    }
    return newBoxes;
  }
}
