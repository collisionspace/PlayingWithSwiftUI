//
//  QuadTree.swift
//  QuadTree
//
//  Created by Daniel Slone on 4/9/21.
//

import Foundation
import CoreLocation
import CoreGraphics

// X and Y represents any point so thusly
// X can be longitude
// Y can be latitude
protocol Coordinate {
    var x: CGFloat { get }
    var y: CGFloat { get }
}

protocol Clusterable {
    var point: Coordinate { get }
}

final class QuadTree {
    let nodeCapacity = 25

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
    func insertObject(_ object: Clusterable, atPoint point: CLLocationCoordinate2D, checkMinMax: Bool) -> Bool {
        // TODO: Probably not needed from the looks of wiki algo
        if checkMinMax {
            if object.point.y > maxLat {
                maxLat = object.point.y
            }
            else if object.point.y < minLat{
                minLat = object.point.y
            }

            if object.point.x > maxLong {
                maxLong = object.point.x
            }
            else if object.point.x < minLong {
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
        
        if let northWest = northWest, northWest.insertObject(object, atPoint: point, checkMinMax: checkMinMax) {
            return true
        } else if let northEast = northEast, northEast.insertObject(object, atPoint: point, checkMinMax: checkMinMax) {
            return true
        } else if let southWest = southWest, southWest.insertObject(object, atPoint: point, checkMinMax: checkMinMax) {
            return true
        } else if let southEast = southEast, southEast.insertObject(object, atPoint: point, checkMinMax: checkMinMax) {
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
        } else if let northEast = northEast {
            objectsInRegion.append(contentsOf: northEast.queryRegion(box, region: region))
        } else if let southWest = southWest{
            objectsInRegion.append(contentsOf: southWest.queryRegion(box, region: region))
        } else if let southEast = southEast {
            objectsInRegion.append(contentsOf: southEast.queryRegion(box, region: region))
        }

        return objectsInRegion
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
        
        let midX: CGFloat = (box.xf + box.x0) / 2.0
        let midY: CGFloat = (box.yf + box.y0) / 2.0
        
        northWest?.boundingBox = BoundingBox(x0: box.x0, y0: midY, xf: midX, yf: box.yf)
        northEast?.boundingBox = BoundingBox(x0: midX, y0: midY, xf: box.xf, yf: box.yf)
        southWest?.boundingBox = BoundingBox(x0: box.x0, y0: box.y0, xf: midX, yf: midY)
        southEast?.boundingBox = BoundingBox(x0: midX, y0: box.y0, xf: box.xf, yf: midY)
    }
}

struct BoundingBox {
    let x0, y0, xf, yf: CGFloat
}

extension BoundingBox {
    func contains(_ point: Coordinate) -> Bool {
        x0 <= point.x && point.x <= xf &&
        y0 <= point.y && point.y <= yf
    }

    func intersects(with box: BoundingBox) -> Bool {
        x0 <= box.xf && xf >= box.x0 &&
        y0 <= box.yf && yf >= y0
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
