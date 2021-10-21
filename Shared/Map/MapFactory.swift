//
//  MapWrapper.swift
//  MapWrapper
//
//  Created by Daniel Slone on 4/9/21.
//

import Foundation
import SwiftUI
import MapKit

struct MapFactory {
    
    enum MapProvider {
        case apple
        case google
        case mapbox
    }

    static func createView(provider: MapProvider, mapRect: Binding<MapRect>, visibleAnnotationItems: Binding<[ClusteredAnnotation]>) -> AnyView {
        switch provider {
        case .apple:
            return AnyView(
                Map(mapRect: mapRect.toMKMapRect(), annotationItems: visibleAnnotationItems.wrappedValue) { item in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: item.point.y, longitude: item.point.x)) {
                        Text("\(item.clusterCount)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                            .frame(width: 100, height: 100, alignment: .center)
                    }
                }
            )
        case .google, .mapbox:
            return AnyView(VStack{})
        }
    }
}

extension Binding where Value == MapRect {
    func toMKMapRect() -> Binding<MKMapRect> {
        Binding<MKMapRect>(
            get: wrappedValue.toMKMapRect,
            set: {
                self.wrappedValue = MapRect(mkMapRect: $0)
            }
        )
    }
}

extension Binding where Value == MapCoordinateRegion {
    func toMKCoordinateRegion() -> Binding<MKCoordinateRegion> {
        Binding<MKCoordinateRegion>(
            get: wrappedValue.toMKCoordinateRegion,
            set: {
                self.wrappedValue = MapCoordinateRegion(region: $0)
            }
        )
    }
}
