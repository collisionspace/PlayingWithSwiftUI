//
//  BikeShareCityResponse.swift
//  BikeShareCityResponse
//
//  Created by Daniel Slone on 14/8/21.
//

import Foundation

struct BikeShareCityResponse: Codable {
    let shares: [BikeShare]

    enum CodingKeys: String, CodingKey {
        case shares = "networks"
    }
}
