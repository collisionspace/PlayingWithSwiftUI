//
//  MapKit+Extensions.swift
//  PlayingWithExamples
//
//  Created by Daniel Slone on 22/10/21.
//

import Foundation
import MapKit

// MARK: - MapSpan

extension MapSpan {
    init(span: MKCoordinateSpan) {
        self.latitudeDelta = span.latitudeDelta
        self.longitudeDelta = span.longitudeDelta
    }

    func toMKCoordinateSpan() -> MKCoordinateSpan {
        MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    }
}

// MARK: - MapRect

extension MapRect {
    static let world = MapRect(mkMapRect: .world)

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

// MARK: - MapCoordinateRegion

extension MapCoordinateRegion {
    init(region: MKCoordinateRegion) {
        self.center = MapCoordinate(clCoordinate: region.center)
        self.span = MapSpan(span: region.span)
    }

    func toMKCoordinateRegion() -> MKCoordinateRegion {
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: center.y, longitude: center.x), span: span.toMKCoordinateSpan())
    }
}

// MARK: - MapPoint

extension MapPoint {
    init(mkMapPoint: MKMapPoint) {
        self.x = mkMapPoint.x
        self.y = mkMapPoint.y
    }

    func toMKMapPoint() -> MKMapPoint {
        MKMapPoint(x: x, y: y)
    }
}

// MARK: - MapSize

extension MapSize {
    init(mkMapSize: MKMapSize) {
        self.width = mkMapSize.width
        self.height = mkMapSize.height
    }

    func toMKMapSize() -> MKMapSize {
        MKMapSize(width: width, height: height)
    }
}

// MARK: - MapCoordinate

extension MapCoordinate {
    init(clCoordinate: CLLocationCoordinate2D) {
        self.x = clCoordinate.longitude
        self.y = clCoordinate.latitude
    }
}
