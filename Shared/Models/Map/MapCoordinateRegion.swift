//
//  MapCoordinateRegion.swift
//  PlayingWithExamples
//
//  Created by Daniel Slone on 22/10/21.
//

import Foundation

struct MapCoordinateRegion {
    let center: MapCoordinate
    let span: MapSpan

    static let zero = MapCoordinateRegion(center: .zero, span: .zero)
}
