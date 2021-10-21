//
//  MapSpan.swift
//  PlayingWithExamples
//
//  Created by Daniel Slone on 22/10/21.
//

import Foundation

struct MapSpan {
    let latitudeDelta: Double
    let longitudeDelta: Double

    static let zero = MapSpan(latitudeDelta: .zero, longitudeDelta: .zero)
}
