//
//  Cuboid.swift
//  
//
//  Created by Min Seong Kang on 2/18/24.
//

import Foundation


/// Describes components in the CubeScene
protocol Cuboid {
  func startDrag(start: CGPoint, pos: CGPoint)
  func rotate(pos: CGPoint)
  func settle()
}

