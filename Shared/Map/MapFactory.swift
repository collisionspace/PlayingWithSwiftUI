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

struct MapRect {
    let origin: MapPoint
    let size: MapSize

    static let zero = MapRect(origin: .zero, size: .zero)
    static let world = MapRect(mkMapRect: .world)
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

    func contains(_ point: MapPoint) -> Bool {
        toMKMapRect().contains(MKMapPoint(CLLocationCoordinate2D(latitude: point.y, longitude: point.x)))
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

struct MapCoordinateRegion {
    let center: MapCoordinate
    let span: MapSpan

    static let zero = MapCoordinateRegion(center: .zero, span: .zero)
}

extension MapCoordinateRegion {
    init(region: MKCoordinateRegion) {
        self.center = MapCoordinate(clCoordinate: region.center)
        self.span = MapSpan(span: region.span)
    }

    func toMKCoordinateRegion() -> MKCoordinateRegion {
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: center.y, longitude: center.x), span: span.toMKCoordinateSpan())
    }
}

struct MapSpan {
    let latitudeDelta: Double
    let longitudeDelta: Double

    static let zero = MapSpan(latitudeDelta: .zero, longitudeDelta: .zero)
}

extension MapSpan {
    init(span: MKCoordinateSpan) {
        self.latitudeDelta = span.latitudeDelta
        self.longitudeDelta = span.longitudeDelta
    }

    func toMKCoordinateSpan() -> MKCoordinateSpan {
        MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    }
}
