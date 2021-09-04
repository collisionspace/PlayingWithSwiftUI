//
//  BikeShareMap.swift
//  BikeShareMap
//
//  Created by Daniel Slone on 14/8/21.
//

import SwiftUI
import MapKit

final class BikeShareViewModel: ObservableObject {

    @Published var rect: MapRect = .zero
    @Published var annotations = [BikeShareAnnotation]()

    init(annotations: [BikeShareAnnotation]) {
        self.annotations = annotations
    }

    var visibleAnnotationItems: [BikeShareAnnotation] {
        annotations.filter({ annotation in
            rect.contains(annotation.mapPoint)
        })
    }
}

struct BikeShareMap: View {

    @ObservedObject private var model: BikeShareViewModel

    init(annotations: Binding<[BikeShareAnnotation]>) {
        self.model = BikeShareViewModel(annotations: annotations.wrappedValue)
    }

    var body: some View {
        MapFactory.createView(
            provider: .apple,
            mapRect: $model.rect,
            visibleAnnotationItems: model.visibleAnnotationItems
        )
    }
}

struct BikeShareMap_Previews: PreviewProvider {
    static var previews: some View {
        BikeShareMap(annotations: .constant([]))
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
