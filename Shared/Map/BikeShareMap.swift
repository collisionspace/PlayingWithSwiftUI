//
//  BikeShareMap.swift
//  BikeShareMap
//
//  Created by Daniel Slone on 14/8/21.
//

import SwiftUI
import MapKit

struct BikeShareMap: View {

    @ObservedObject private var model: BikeShareViewModel
    private let mapProvider: MapFactory.MapProvider

    init(cities: Binding<[City]>, mapProvider: MapFactory.MapProvider = .apple) {
        self.model = BikeShareViewModel(cities: cities.wrappedValue)
        self.mapProvider = mapProvider
    }

    var body: some View {
        MapFactory.createView(
            provider: mapProvider,
            mapRect: $model.rect,
            visibleAnnotationItems: $model.visibleItems
        )
    }
}

struct BikeShareMap_Previews: PreviewProvider {
    static var previews: some View {
        BikeShareMap(cities: .constant([]))
    }
}

struct BikeShareAnnotation: Identifiable {
    let id = UUID()
    let city: City
    let mapPoint: MapPoint

    init(city: City) {
        self.city = city
        // TODO: look into MKMapPoint a bit more
        self.mapPoint = MapPoint(mkMapPoint: MKMapPoint(city.coordinate))
    }
}

struct City: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let name: String
}
