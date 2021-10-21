//
//  BikeShareViewModel.swift
//  BikeShareViewModel
//
//  Created by Daniel Slone on 5/9/21.
//

import Foundation
import MapKit
import SwiftUI
import Combine

struct ClusterableAnnotation: Annotatable {
    let id: UUID
    let title: String
    let point: Coordinate
    let iconName: String?
    
    init(id: UUID = UUID(), title: String, point: Coordinate, iconName: String? = nil) {
        self.id = id
        self.title = title
        self.point = point
        self.iconName = iconName
    }
    
    init(clusterable: Clusterable) {
        self.id = UUID()
        self.title = clusterable.title
        self.point = clusterable.point
        self.iconName = clusterable.iconName
    }
    
    var mapPoint: MapPoint {
        MapPoint(x: point.x, y: point.y)
    }
}

final class BikeShareViewModel: ObservableObject {
    
    @Published var region: MapCoordinateRegion = .zero
    @Published var rect: MapRect = .world
    @Published var annotations = [ClusterableAnnotation]()
    @Published var visibleItems = [ClusteredAnnotation]()
    
    
    private var cancellable: AnyCancellable? = nil
    private var quadTree = QuadTree()
    private var minLatitude = 0.0
    private var maxLatitude = 0.0
    private var minLongitude = 0.0
    private var maxLongitude = 0.0
    private var shouldCheck = true
    var backgroundQueue = OperationQueue()
    var mainQueue = OperationQueue.main
    
    init(cities: [City]) {
        let annotations = cities.map { ClusterableAnnotation(title: $0.name, point: MapCoordinate(clCoordinate: $0.coordinate)) }
        self.annotations = annotations
        cancellable = AnyCancellable(
            $rect.debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
                .sink { [weak self] rect in
                    // Block operations off the main thread
                    self?.generateQuadTreeWithMarkers(annotations, forVisibleArea: rect)
                }
        )
    }
    
    private var currentZoomLevel: CGFloat {
        let mkMapRect = rect.toMKMapRect()
        let region = MKCoordinateRegion(mkMapRect)
        let scale = region.span.longitudeDelta * 85445659.44705395 * Double.pi / (180 * UIScreen.main.bounds.size.width)
        let level = 20 - log2(scale)
        return level
    }
    
    func generateQuadTreeWithMarkers(_ array: [ClusterableAnnotation], forVisibleArea visibleMap: MapRect) {
        let mkMapRect = rect.toMKMapRect()
        let bottomLeft = MKMapPoint(x: rect.origin.x, y: mkMapRect.maxY)
        let topRight = MKMapPoint(x: mkMapRect.maxX, y: rect.origin.y)
        
        let sw = bottomLeft.coordinate
        let ne = topRight.coordinate
        let boundingBox = quadTree.boundingBoxForCoordinates(ne, southWestCoord: sw)
        
        quadTree = QuadTree(boundingBox: boundingBox)
        
        let currentZoom = currentZoomLevel
        
        var objectArray = [ClusteredAnnotation]()
        
        backgroundQueue.maxConcurrentOperationCount = 1
        
        let operationBlock = BlockOperation { [unowned self] in
            for item in array {
                self.quadTree.insert(item, checkMinMax: self.shouldCheck)
            }
            
            if self.shouldCheck == true {
                self.minLatitude = self.quadTree.minLat
                self.maxLatitude = self.quadTree.maxLat
                self.minLongitude = self.quadTree.minLong
                self.maxLongitude = self.quadTree.maxLong
                self.shouldCheck = false
            }
            
            let coordinateNE = CLLocationCoordinate2DMake(self.maxLatitude, self.maxLongitude)
            let coordinateSW = CLLocationCoordinate2DMake(self.minLatitude, self.minLongitude)
            
            objectArray = self.clusteredAnnotationsWithinMapRect(
                self.quadTree,
                zoomLevel: currentZoom,
                boundaryNE: coordinateNE,
                boundarySW: coordinateSW,
                boundingBox: boundingBox
            )
        }
        
        let mainOperationBlock = BlockOperation { [unowned self] in
            self.visibleItems = objectArray.map { item in
                ClusteredAnnotation(
                    title: item.title,
                    point: item.point,
                    clusterCount: item.clusterCount, image:  UIImage(systemName: "00.circle.fill")!
                )
            }
        }
        mainOperationBlock.addDependency(operationBlock)
        backgroundQueue.addOperation(operationBlock)
        mainQueue.addOperation(mainOperationBlock)
    }
    
    func clusteredAnnotationsWithinMapRect(_ quadTree: QuadTree, zoomLevel: Double, boundaryNE: CLLocationCoordinate2D, boundarySW: CLLocationCoordinate2D, boundingBox: BoundingBox) -> [ClusteredAnnotation] {
        let minLat = floor(boundarySW.latitude)
        let maxLat = ceil(boundaryNE.latitude)
        
        let minLong = floor(boundarySW.longitude)
        let maxLong = ceil(boundaryNE.longitude)
        
        var clusteredMapMarkers = [ClusteredAnnotation]()
        var coordinateAreaSize: Double = (pow(2, 15) / (256 * pow(2, zoomLevel)))
        
        if zoomLevel > 10 { //The area becomes too small at this point so increase it
            coordinateAreaSize = 1
        }
        
        var i = minLong
        while i < maxLong + coordinateAreaSize {
            
            var j = minLat
            while j < maxLat + coordinateAreaSize {
                
                let northEastCoord: CLLocationCoordinate2D = CLLocationCoordinate2DMake(j + coordinateAreaSize, i + coordinateAreaSize)
                let southWestCoord: CLLocationCoordinate2D = CLLocationCoordinate2DMake(j, i)
                
                let areaBox: BoundingBox = quadTree.boundingBoxForCoordinates(northEastCoord, southWestCoord: southWestCoord) //An area within the boundary to cluster
                
                var totalLatitude: Double = 0
                var totalLongitude: Double = 0
                var mapMarkers = [ClusterableAnnotation]()
                
                let objectArray = quadTree.queryRegion(areaBox, region: areaBox)
                
                for object in objectArray {
                    totalLatitude += object.point.y
                    totalLongitude += object.point.x
                    mapMarkers.append(ClusterableAnnotation(clusterable: object))
                }
                
                let count = mapMarkers.count
                
                if count > 1 {
                    let coordinate = CLLocationCoordinate2D(
                        latitude: CLLocationDegrees(totalLatitude)/CLLocationDegrees(count),
                        longitude: CLLocationDegrees(totalLongitude)/CLLocationDegrees(count)
                    )
                    
                    let cluster = ClusteredAnnotation(title: "Marker Count: \(count)", point: MapCoordinate(clCoordinate: coordinate), clusterCount: count)
                    clusteredMapMarkers.append(cluster)
                } else {
                    clusteredMapMarkers.append(contentsOf: mapMarkers.map { ClusteredAnnotation(
                        title: $0.title,
                        point: $0.point,
                        clusterCount: 1)
                        
                    })
                }
                
                j += coordinateAreaSize
            }
            
            i += coordinateAreaSize
        }
        
        return clusteredMapMarkers
    }
}

protocol Clustered: Clusterable {
    var clusterCount: Int { get }
    var image: UIImage? { get }
}
struct ClusteredAnnotation: Identifiable, Clustered {
    let id: UUID
    let title: String
    let point: Coordinate
    let iconName: String?
    let clusterCount: Int
    let image: UIImage?
    
    init(id: UUID = UUID(), title: String, point: Coordinate, iconName: String? = nil, clusterCount: Int, image: UIImage? = nil) {
        self.id = id
        self.title = title
        self.point = point
        self.iconName = iconName
        self.clusterCount = clusterCount
        self.image = image
    }
}