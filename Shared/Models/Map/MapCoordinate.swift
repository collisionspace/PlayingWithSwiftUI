//
//  MapCoordinate.swift
//  PlayingWithExamples
//
//  Created by Daniel Slone on 22/10/21.
//

import CoreGraphics

struct MapCoordinate: Coordinate {
    let x: CGFloat
    let y: CGFloat

    static let zero = MapCoordinate(x: .zero, y: .zero)
}
