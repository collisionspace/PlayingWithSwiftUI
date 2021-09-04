//
//  BikeShareLocation.swift
//  BikeShareLocation
//
//  Created by Daniel Slone on 14/8/21.
//

import Foundation

struct BikeShareLocation: Codable, Equatable {
    let city: String
    let country: String
    let latitude: Double
    let longitude: Double
}
