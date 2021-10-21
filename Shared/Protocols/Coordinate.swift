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

import CoreLocation

struct MapCoordinate: Coordinate {
    let x: CGFloat
    let y: CGFloat

    static let zero = MapCoordinate(x: .zero, y: .zero)
}

extension MapCoordinate {
    init(clCoordinate: CLLocationCoordinate2D) {
        self.x = clCoordinate.longitude
        self.y = clCoordinate.latitude
    }
}
