//
//  Cube.swift
//
//
//  Created by Min Seong Kang on 1/25/24.
//

import Foundation
import SceneKit
import CoreGraphics





/// Essentially a 2D array of nodes that represent axes of
/// the cube. This abstraction is needed to manipulate
/// rows and columns in a single action.
/// - horiz: array horizontal axes
/// - vert: array vertical axes
struct Axes {
  var horiz: [SCNNode]
  var vert: [SCNNode]
  init(){
    horiz = [SCNNode]()
    vert = [SCNNode]()
  }
}



/*
 Represents Cube in the Home Screen. Contains all the
 SCNNodes that comprise the Cube.
 - metaData: data about rotation motion
 - frame_dim: vector defining dimension of space
 in View designated for cube
 - cube_dim: size of cube
 - boxes: matrix of boxes that comprise the cube
 - moveLock: to prevent race condition in action sequence
 
 */
class Cube: SCNNode, Cuboid {
  
  var metaData: MoveMetaData
  var frameDim: CGPoint
  let cubeDim: Int
  let boxes: [SCNNode]
  let axes: Axes
  let moveLock = NSLock()
  
  init(frameDim: CGPoint, cubeDim: Int) {
    self.frameDim = frameDim
    self.metaData = MoveMetaData()
    self.cubeDim = cubeDim
    self.boxes = Cube.initBoxes(cubeDim)
    self.axes = Cube.initAxes(cubeDim)
    super.init()
    addNodes()
  }
  
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  /*
   ******************************
   ****** PUBLIC FUNCTIONS ******
   ******************************
   */
  
  /// Initializes rotation of a row/column.
  /// 1) Determine the direction
  /// 2) Determing the axis
  /// 3) Add the nodes in the axis to the actual Axis node
  /// 4) Record the meta data
  /// - Parameters:
  ///   - start: start point in Cube space
  ///   - pos: current point in Cube space
  func startDrag(start: CGPoint, pos: CGPoint) {
    moveLock.lock()
    assert(!metaData.isActive)
    let x_trans = pos.x - start.x
    let y_trans = pos.y - start.y
    if abs(x_trans) > abs(y_trans) {
      let axis = self.axes.horiz[coordToIndex(coord: start.y, frame: self.frameDim.x, cubeDim: self.cubeDim)]
      metaData.axis = axis
      metaData.dir = Direction.HORIZ
      let planeY = axis.position.y
      for box in boxes {
        if box.position.y == planeY {
          box.removeFromParentNode()
          axis.addChildNode(box)
          box.position.y -= planeY
        }
      }
    } else {
      let axis = self.axes.vert[coordToIndex(coord: start.x, frame: self.frameDim.y, cubeDim: self.cubeDim)]
      metaData.axis = axis
      metaData.dir = Direction.VERT
      let planeX = axis.position.x
      for box in boxes {
        if box.position.x == planeX {
          axis.addChildNode(box)
          box.position.x -= planeX
        }
      }
    }
    metaData.axis!.runAction(SCNAction.scale(by: FIT_SCALE, duration: 0.1))
    metaData.currPos = start
    metaData.isActive = true
    moveLock.unlock()
  }
  
  
  /// Rotate one of a Cube's row or column
  /// 1) Determine how the translation from the last point
  /// 2) Calculate fraction of movement and determine the angle of roatation
  /// 3) Rotate the axis
  /// - Parameters:
  ///   - pos: current position
  ///   - start: start position
  func rotate(pos: CGPoint) {
    moveLock.lock()
    defer {
      moveLock.unlock()
    }
    if (!metaData.isActive) {fatalError("rotate called when not active")}
    guard let currPos = metaData.currPos else {fatalError("currPos not set in rotate")}
    guard let axis = metaData.axis else {fatalError("axis not set in rotate")}
    var action: SCNAction? = nil
    if metaData.dir == .HORIZ {
      let magn = (pos.x - currPos.x)/frameDim.x
      let rotation = Double.pi/2*magn
      metaData.cumRotation += rotation
      action = SCNAction.rotate(by:rotation, around: SCNVector3(0,1,0), duration: TimeInterval(0))
    } else if metaData.dir == .VERT {
      let magn = (pos.y - currPos.y)/frameDim.y
      let rotation = -Double.pi/2*magn
      metaData.cumRotation += rotation
      action = SCNAction.rotate(by:rotation, around: SCNVector3(1,0,0), duration: TimeInterval(0))
    } else {
      fatalError("direction is unset")
    }
    axis.runAction(action!)
    metaData.currPos = pos
  }
  
  
  /// This finalizes the rotation/drag.
  /// 1) Determine whether the rotation exceeded the half of 90 degrees
  /// 2) Finish the rotation by either turning full 90 degrees or turning back to the orignal position
  /// 3) Call clearMoveMeta() that solves rotational miscellany and clear the meta data
  func settle() {
    moveLock.lock()
    let remRotation = metaData.cumRotation.truncatingRemainder(dividingBy: RIGHT_ANGLE)
    let finalRotation: Double
    if (remRotation >= 0) {
      if (remRotation >= RIGHT_ANGLE/2) {
        finalRotation = RIGHT_ANGLE - remRotation
        metaData.cumRotation = RIGHT_ANGLE
      } else {
        finalRotation = Double(-remRotation)
        metaData.cumRotation = 0
      }
    } else {
      if (abs(remRotation) >= RIGHT_ANGLE/2) {
        finalRotation = abs(remRotation) - RIGHT_ANGLE
        metaData.cumRotation = -RIGHT_ANGLE
      } else {
        finalRotation = abs(remRotation)
        metaData.cumRotation = 0
      }
    }
    guard let axis = metaData.axis else {
      fatalError("axis is nil")
    }
    var action1: SCNAction
    if metaData.dir == .HORIZ {
      action1 = SCNAction.rotate(by:finalRotation, around: SCNVector3(0,1,0), duration: TimeInterval(0.23))
    } else if metaData.dir == .VERT {
      action1 = SCNAction.rotate(by:finalRotation, around: SCNVector3(1,0,0), duration: TimeInterval(0.23))
    } else {
      fatalError("direction is unset")
    }
    let action2 = SCNAction.scale(by: REFIT_SCALE, duration: 0.08)
    let sequence = SCNAction.sequence([action1, action2])
    axis.runAction(sequence) {
      self.clearMoveMeta()
    }
  }
  
  
  /// Applies images on a entire face of the cube. No order guaranteed
  /// - Parameters:
  ///   - face: face of cube
  ///   - images: array of images to use as textures
  func applyImagesCubeFace(face: CubeFace, images: [UIImage]) {
    var posx: Float? = nil
    var posy: Float? = nil
    var posz: Float? = nil
    var tboxes = [SCNNode]()
    switch (face) {
    case .FRONT:
      posz = Float(self.cubeDim)/2-0.5
    case .BACK:
      posz = -Float(self.cubeDim)/2+0.5
    case .LEFT:
      posx = -Float(self.cubeDim)/2+0.5
    case .RIGHT:
      posx = Float(self.cubeDim)/2-0.5
    case .TOP:
      posy = Float(self.cubeDim)/2-0.5
    case .BOT:
      posy = -Float(self.cubeDim)/2+0.5
    default:
      fatalError("ENUM cubeFace malfunction")
    }
    
    for box in self.boxes {
      if let posx = posx {
        if (box.position.x == posx) {
          tboxes.append(box)
        }
        continue
      }
      if let posy = posy {
        if (box.position.y == posy) {
          tboxes.append(box)
        }
        continue
      }
      if let posz = posz {
        if (box.position.z == posz) {
          tboxes.append(box)
        }
        continue
      }
    }
    for i in 0..<min(tboxes.count, images.count) {
      let material = SCNMaterial()
      material.diffuse.contents = images[i]
      tboxes[i].geometry?.materials[face.rawValue] = material
    }
  }
  
  /*
   *******************************
   ****** PRIVATE FUNCTIONS ******
   *******************************
   */
  
  /// Imitates rotation by swapping textures of a box (horizontal)
  /// - Parameters:
  ///   - child: a box node
  ///   - dir: true for right, false for left
  private func rotateImagesHoriz(child: SCNNode, dir: Bool) {
    let arr = child.geometry?.materials
    if let arr = arr {
      var front = arr[3]
      var right = arr[0]
      var back =  arr[1]
      var left = arr[2]
      // left direction
      if (!dir) {
        front = arr[1]
        right = arr[2]
        back = arr[3]
        left = arr[0]
      }
      child.geometry?.materials = [front,right,back,left,arr[4],arr[5]]
    } else {
      fatalError()
    }
  }
  
  ///Imitates rotation by swapping textures of a box (vertical)
  /// - Parameters:
  ///   - child: a box node
  ///   - dir: true for innter, false for outer
  private func rotateImagesVert(child: SCNNode, dir: Bool) {
    let arr = child.geometry?.materials
    if let arr = arr {
      var front = arr[4]
      var top = arr[2]
      var back =  arr[5]
      var bot = arr[0]
      // left direction
      if (!dir) {
        front = arr[5]
        top = arr[0]
        back = arr[4]
        bot = arr[2]
      }
      child.geometry?.materials = [front,arr[1],back,arr[3],top,bot]
    } else {
      fatalError()
    }
  }
  
  /// Important logistics for finalizing the rotation
  /// 1) Transfer from Axis space to Cube space
  /// 2) Imitate rotation without actually rotating boxes
  /// 3) Cleanup data structures for future operations
  private func clearMoveMeta() {
    guard let axis = metaData.axis else {exit(1)}
    //adjustImageRotation(axis)
    for child in axis.childNodes {
      child.removeFromParentNode()
      self.addChildNode(child)
      if (metaData.dir == .HORIZ) {
        child.position.y += axis.position.y
        let x: Double = Double(child.position.x)
        let z: Double = Double(child.position.z)
        //rotation
        if (metaData.cumRotation != 0 ){
          child.position.x = Float(x * cos(metaData.cumRotation) + z * sin(metaData.cumRotation))
          child.position.z = Float(-x * sin(metaData.cumRotation) + z * cos(metaData.cumRotation))
          rotateImagesHoriz(child: child, dir: metaData.cumRotation>0)
        }
        
        //child.simdOrientation = simd_quatf(angle: Float(metaData.cumRotation), axis: SIMD3(x:0,y:1,z:0)) * child.simdOrientation
        

      } else if (metaData.dir == .VERT) {
        child.position.x += axis.position.x
        let y: Double = Double(child.position.y)
        let z: Double = Double(child.position.z)
        
        if (metaData.cumRotation != 0 ){
          child.position.y = Float(y * cos(metaData.cumRotation) - z * sin(metaData.cumRotation))
          child.position.z = Float(y * sin(metaData.cumRotation) + z * cos(metaData.cumRotation))
          //child.simdOrientation = simd_quatf(angle: Float(metaData.cumRotation), axis: SIMD3(x:1,y:0,z:0)) * child.simdOrientation
          rotateImagesVert(child: child, dir: metaData.cumRotation>0)
        }
      }
    }
    axis.eulerAngles = SCNVector3(0, 0, 0)
    metaData.axis = nil
    metaData.isActive = false
    metaData.currPos  = nil
    metaData.cumRotation = 0.0
    metaData.dir = Direction.UNSET
    moveLock.unlock()
  }
  
  /// Finds the index of Axis
  /// - Parameters:
  ///   - coord: coordinates in Cube space (either x or y)
  ///   - frame: width or height of Cube space
  ///   - cubeDim: size of Cube in terms boxes
  /// - Returns: an index of row or column in Axes
  private func coordToIndex(coord: Double, frame: Double, cubeDim: Int) -> Int{
    return Int(floor(coord/(frame/Double(cubeDim))))
  }
  
  /// Selx-explanatory
  private func addNodes() {
    for node in self.boxes{
      self.addChildNode(node)
    }
    for node in self.axes.horiz{
      self.addChildNode(node)
    }
    for node in self.axes.vert{
      self.addChildNode(node)
    }
  }
  
  /// Initializes boxes comprising Cube
  /// - Parameter cubeDim: size of cube in boxes
  /// - Returns: array of boxes
  static func initBoxes(_ cubeDim: Int) -> [SCNNode] {
    var newBoxes = [SCNNode]()
    let start = -(Double(cubeDim)/2-0.5)
    for i in 0..<cubeDim {
      for j in 0..<cubeDim {
        for k in 0..<cubeDim {
          let material = SCNMaterial()
          material.diffuse.contents = UIColor.black
          let geometry = SCNBox(width:1, height: 1, length: 1, chamferRadius: 0)
          geometry.materials = Array(repeating: material, count: 6)
          let node = SCNNode()
          node.geometry = geometry
          node.position = SCNVector3(start+Double(i), start+Double(j), start+Double(k))
          node.scale = SCNVector3(1,1,1)
          newBoxes.append(node)
        }
      }
    }
    return newBoxes
  }
  
  /// Initializes Axes
  /// - Parameter dim: size of Cube in boxes
  /// - Returns: Axes structure with Axis nodes
  static func initAxes(_ dim: Int) -> Axes {
    var newAxes = Axes()
    let start = -(Double(dim)/2-0.5)
    for i in 0..<dim {
      let row = SCNNode()
      let col = SCNNode()
      row.position.y = Float(start) + Float(i)
      col.position.x = Float(start) + Float(i)
      
      newAxes.horiz.append(row)
      newAxes.vert.append(col)
    }
    return newAxes
  }
  
}
