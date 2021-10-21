//
//  BikeShareRepository.swift
//  BikeShareRepository
//
//  Created by Daniel Slone on 14/8/21.
//

import Foundation
import MapKit

final class BikeShareRepository: ObservableObject {
   @Published var cities: [City]

    private var response: BikeShareCityResponse = BikeShareCityResponse(shares: []) {
        willSet {
            // Set to unowned as with the current setup this will never get dealloc
            DispatchQueue.main.async { [unowned self] in
                self.cities = self.response
                    .shares
                    .map { City(
                        coordinate: CLLocationCoordinate2D(
                            latitude: $0.location.latitude,
                            longitude: $0.location.longitude
                        ),
                        name: $0.name
                    )}
            }
        }
    }

//    private var cachedResponse: Result<BikeShareCityResponse, Error>?
    private let worker: BikeShareService

    init(worker: BikeShareService = BikeShareWorker()) {
        self.worker = worker
        self.cities = []
    }

    func getBikeShareCities() async {
       let bikes = await worker.fetchBikes()
       switch bikes {
       case let .success(bikeShares):
           response = bikeShares
       case .failure:
           break
       }
   }
}
