//
//  Coordinate.swift
//  Coordinate
//
//  Created by Daniel Slone on 5/9/21.
//

import Foundation
import CoreGraphics

// X and Y represents any point so thusly
// X can be longitude
// Y can be latitude
protocol Coordinate {
    var x: CGFloat { get }
    var y: CGFloat { get }
}
