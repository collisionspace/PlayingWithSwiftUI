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

    static func createView(provider: MapProvider, mapRect: Binding<MapRect>, visibleAnnotationItems: [BikeShareAnnotation]) -> AnyView {
        switch provider {
        case .apple:
            return AnyView(
                Map(mapRect: mapRect.toMKMapRect(), annotationItems: visibleAnnotationItems) { item in
                    MapAnnotation(coordinate: item.city.coordinate) {
                        Image(systemName: "bicycle")
                        .onTapGesture(count: 1, perform: {
                            print("IT WORKS")
                      })
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

struct MapRect {
    let origin: MapPoint
    let size: MapSize

    static let zero = MapRect(origin: .zero, size: .zero)
}

extension MapRect {
    init(mkMapRect: MKMapRect) {
        self.origin = MapPoint(mkMapPoint: mkMapRect.origin)
        self.size = MapSize(mkMapSize: mkMapRect.size)
    }

    func toMKMapRect() -> MKMapRect {
        MKMapRect(
            origin: origin.toMKMapPoint(),
            size: size.toMKMapSize()
        )
    }

    // TODO: Instead of transforming to mapkit look at writing own
    func contains(_ point: MapPoint) -> Bool {
        toMKMapRect().contains(point.toMKMapPoint())
    }
}

struct MapPoint {
    let x: Double
    let y: Double

    static let zero = MapPoint(x: .zero, y: .zero)
}

extension MapPoint {
    init(mkMapPoint: MKMapPoint) {
        self.x = mkMapPoint.x
        self.y = mkMapPoint.y
    }

    func toMKMapPoint() -> MKMapPoint {
        MKMapPoint(x: x, y: y)
    }
}

struct MapSize {
    let width: Double
    let height: Double

    static let zero = MapSize(width: .zero, height: .zero)
}

extension MapSize {
    init(mkMapSize: MKMapSize) {
        self.width = mkMapSize.width
        self.height = mkMapSize.height
    }

    func toMKMapSize() -> MKMapSize {
        MKMapSize(width: width, height: height)
    }
}
