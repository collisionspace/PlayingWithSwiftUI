//
//  BikeShareWorker.swift
//  BikeShareWorker
//
//  Created by Daniel Slone on 14/8/21.
//

import Foundation

private extension String {
    static let bikeNetworks = "/v2/networks"
}

struct BikeShareWorker: BikeShareService {

    @Endpoint(.cityBikesBaseEndpoint, path: .bikeNetworks)
    private var endpoint: URLComponents

    func fetchBikes() async -> BikeListResponse {
        await Networking.request(url: endpoint.url)
    }
}
