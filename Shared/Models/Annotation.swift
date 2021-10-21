//
//  Annotation.swift
//  Annotation
//
//  Created by Daniel Slone on 5/9/21.
//

import Foundation

struct Annotation: Annotatable {
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
        self.iconName = nil
    }

    var mapPoint: MapPoint {
        MapPoint(x: point.x, y: point.y)
    }
}
