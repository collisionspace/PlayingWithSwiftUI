//
//  BikeShare.swift
//  BikeShare
//
//  Created by Daniel Slone on 14/8/21.
//

import Foundation

struct BikeShare: Codable, Equatable {
    let href: String
    let id: String
    let location: BikeShareLocation
    let name: String
}
