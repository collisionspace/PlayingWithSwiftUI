//
//  QuadTree.swift
//  QuadTree
//
//  Created by Daniel Slone on 4/9/21.
//

import Foundation
import CoreLocation
import CoreGraphics

final class QuadTree {
    let nodeCapacity = 4

    var objects: [Clusterable] = []

    var northWest: QuadTree? = nil
    var northEast: QuadTree? = nil
    var southWest: QuadTree? = nil
    var southEast: QuadTree? = nil

    var boundingBox: BoundingBox? = nil

    var minLat: Double = 0
    var maxLat: Double = 0
    var minLong: Double = 0
    var maxLong: Double = 0

    init() { }
    
    init(boundingBox box: BoundingBox) {
        self.boundingBox = box
        self.objects = [Clusterable]()
    }

    @discardableResult
    func insert(_ object: Clusterable, checkMinMax: Bool) -> Bool {
        if checkMinMax {
            if object.point.y > maxLat {
                maxLat = object.point.y
            } else if object.point.y < minLat {
                minLat = object.point.y
            }

            if object.point.x > maxLong {
                maxLong = object.point.x
            } else if object.point.x < minLong {
                minLong = object.point.x
            }
        }

        if !boundingBox.contains(point: object.point) {
            return false
        }

        if objects.count < nodeCapacity {
            objects.append(object)
            return true
        }
  
        //Otherwise, subdivide and add the marker to whichever child will accept it
        if northWest == nil {
            subdivide()
        }
        
        if let northWest = northWest, northWest.insert(object, checkMinMax: checkMinMax) {
            return true
        } else if let northEast = northEast, northEast.insert(object, checkMinMax: checkMinMax) {
            return true
        } else if let southWest = southWest, southWest.insert(object, checkMinMax: checkMinMax) {
            return true
        } else if let southEast = southEast, southEast.insert(object, checkMinMax: checkMinMax) {
            return true
        }

        return false
    }

    func queryRegion(_ box: BoundingBox, region: BoundingBox) -> [Clusterable] {
        var objectsInRegion = [Clusterable]()
        if !box.intersects(with: region) {
            return objectsInRegion
        }

        for object in objects {
            if region.contains(object.point) {
                objectsInRegion.append(object)
            }
        }

        if northWest == nil {
            return objectsInRegion
        }

        if let northWest = northWest {
            objectsInRegion.append(contentsOf: northWest.queryRegion(box, region: region))
        }
        if let northEast = northEast {
            objectsInRegion.append(contentsOf: northEast.queryRegion(box, region: region))
        }
        if let southWest = southWest{
            objectsInRegion.append(contentsOf: southWest.queryRegion(box, region: region))
        }
        if let southEast = southEast {
            objectsInRegion.append(contentsOf: southEast.queryRegion(box, region: region))
        }

        return objectsInRegion
    }

    func boundingBoxForCoordinates(_ northEastCoord: CLLocationCoordinate2D, southWestCoord: CLLocationCoordinate2D) -> BoundingBox {
        let minLat: CLLocationDegrees = southWestCoord.latitude
        let maxLat: CLLocationDegrees = northEastCoord.latitude
        
        let minLong: CLLocationDegrees = southWestCoord.longitude
        let maxLong: CLLocationDegrees = northEastCoord.longitude
        
        return BoundingBox(minX: CGFloat(minLong), minY: CGFloat(minLat), maxX: CGFloat(maxLong), maxY: CGFloat(maxLat))
    }

    private func subdivide() {
        northEast = QuadTree()
        northWest = QuadTree()
        southEast = QuadTree()
        southWest = QuadTree()

        guard let box = boundingBox else {
            // TODO: throw an error here
            return
        }
        
        let midX: CGFloat = (box.maxX + box.minX) / 2.0
        let midY: CGFloat = (box.maxY + box.minY) / 2.0
        
        northWest?.boundingBox = BoundingBox(minX: box.minX, minY: midY, maxX: midX, maxY: box.maxY)
        northEast?.boundingBox = BoundingBox(minX: midX, minY: midY, maxX: box.maxX, maxY: box.maxY)
        southWest?.boundingBox = BoundingBox(minX: box.minX, minY: box.minY, maxX: midX, maxY: midY)
        southEast?.boundingBox = BoundingBox(minX: midX, minY: box.minY, maxX: box.maxX, maxY: midY)
    }
}

struct BoundingBox {
    let minX, minY, maxX, maxY: CGFloat
}

extension BoundingBox {
    func contains(_ point: Coordinate) -> Bool {
        minX <= point.x && point.x <= maxX &&
        minY <= point.y && point.y <= maxY
    }

    func intersects(with box: BoundingBox) -> Bool {
        minX <= box.maxX && maxX >= box.minX &&
        minY <= box.maxY && maxY >= minY
    }
}

extension Optional where Wrapped == BoundingBox {
    func contains(point: Coordinate) -> Bool {
        self?.contains(point) ?? false
    }

    func intersects(with box: BoundingBox) -> Bool {
        self?.intersects(with: box) ?? false
    }
}
