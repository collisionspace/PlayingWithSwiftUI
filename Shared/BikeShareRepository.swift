//
//  BikeShareRepository.swift
//  BikeShareRepository
//
//  Created by Daniel Slone on 14/8/21.
//

import Foundation
import MapKit

final class BikeShareRepository: ObservableObject {
   @Published var annotations: [BikeShareAnnotation]

    private var response: BikeShareCityResponse = BikeShareCityResponse(shares: []) {
        willSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                self.annotations = self.response
                    .shares
                    .lazy
                    .map { City(
                        coordinate: CLLocationCoordinate2D(
                            latitude: $0.location.latitude,
                            longitude: $0.location.longitude
                        ),
                        name: $0.name
                    )}
                    .map { BikeShareAnnotation(city: $0) }
            }
        }
    }

//    private var cachedResponse: Result<BikeShareCityResponse, Error>?
    private let worker: BikeShareService

    init(worker: BikeShareService = BikeShareWorker()) {
        self.worker = worker
        self.annotations = []
    }

    func getBikeShareCities() async {
       let bikes = await worker.fetchBikes()
       switch bikes {
       case let .success(bikeShares):
           response = bikeShares
       case let .failure(error):
           response = BikeShareCityResponse(shares: [])
       }
   }
}
