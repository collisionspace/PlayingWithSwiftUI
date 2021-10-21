//
//  MapRect.swift
//  PlayingWithExamples
//
//  Created by Daniel Slone on 22/10/21.
//

import Foundation

struct MapRect {
    let origin: MapPoint
    let size: MapSize

    static let zero = MapRect(origin: .zero, size: .zero)
}
