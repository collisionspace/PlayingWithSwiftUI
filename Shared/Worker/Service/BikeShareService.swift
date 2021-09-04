//
//  BikeShareService.swift
//  BikeShareService
//
//  Created by Daniel Slone on 14/8/21.
//

import Foundation

protocol BikeShareService {
    typealias BikeListResponse = Result<BikeShareCityResponse, Error>

    func fetchBikes() async -> BikeListResponse
}
