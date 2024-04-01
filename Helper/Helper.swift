//
//  Helper.swift
//  
//
//  Created by Min Seong Kang on 2/24/24.
//

import Foundation
import UIKit

/// Global helper functions
class Helper {
  static func loadImageSequential(common: String, count: Int) -> [UIImage]{
    var images: [UIImage] = []
    if (count == 1) {
      if let image = UIImage(named:common){
        return [image]
      } else {
        return []
      }
    }
    for index in 1...count {
      let name = "\(common)\(index)"
      if let image = UIImage(named: name) {
        images.append(image)
      } else {
        print("failed to import \(name)")
      }
    }
    return images
  }
}

