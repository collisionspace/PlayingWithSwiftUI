//
//  BikeShareWorker.swift
//  BikeShareWorker
//
//  Created by Daniel Slone on 14/8/21.
//

import Foundation

final class BikeShareWorker: BikeShareService {

    // Url has been broken out into pieces
    private var urlComponents: URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.citybik.es"
        urlComponents.path = "/v2/networks"
        return urlComponents
    }

    func fetchBikes() async -> BikeListResponse {
        await Networking.request(url: urlComponents.url)
    }
}
